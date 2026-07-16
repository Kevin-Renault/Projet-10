package com.openclassrooms.yourwayapi.service;

import com.openclassrooms.yourwayapi.dto.chat.AddChatParticipantRequest;
import com.openclassrooms.yourwayapi.dto.chat.ChatDto;
import com.openclassrooms.yourwayapi.dto.chat.ChatParticipantDto;
import com.openclassrooms.yourwayapi.dto.chat.ChatTextDto;
import com.openclassrooms.yourwayapi.dto.chat.CreateChatRequest;
import com.openclassrooms.yourwayapi.dto.chat.SendChatTextRequest;
import com.openclassrooms.yourwayapi.entity.YourWayUserEntity;
import com.openclassrooms.yourwayapi.entity.chat.ChatEntity;
import com.openclassrooms.yourwayapi.entity.chat.ChatContentType;
import com.openclassrooms.yourwayapi.entity.chat.ChatRole;
import com.openclassrooms.yourwayapi.entity.chat.ChatParticipantEntity;
import com.openclassrooms.yourwayapi.entity.chat.ChatTextEntity;
import com.openclassrooms.yourwayapi.entity.chat.ChatTextStatus;
import com.openclassrooms.yourwayapi.entity.chat.ChatStatus;
import com.openclassrooms.yourwayapi.repository.YourWayUserRepository;
import com.openclassrooms.yourwayapi.repository.chat.ChatParticipantRepository;
import com.openclassrooms.yourwayapi.repository.chat.ChatRepository;
import com.openclassrooms.yourwayapi.repository.chat.ChatTextRepository;
import java.time.Instant;
import java.util.List;
import java.util.Objects;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class ChatService {

    private static final String AGENT_ROLE = "agent";

    private final ChatRepository chatRepository;
    private final ChatParticipantRepository participantRepository;
    private final ChatTextRepository textRepository;
    private final YourWayUserRepository userRepository;
    private final ChatEventService chatEventService;

    public ChatService(ChatRepository chatRepository, ChatParticipantRepository participantRepository,
            ChatTextRepository textRepository, YourWayUserRepository userRepository,
            ChatEventService chatEventService) {
        this.chatRepository = chatRepository;
        this.participantRepository = participantRepository;
        this.textRepository = textRepository;
        this.userRepository = userRepository;
        this.chatEventService = chatEventService;
    }

    @Transactional
    public ChatDto create(YourWayUserEntity principal, CreateChatRequest request) {
        Long currentUserId = currentUserId(principal);
        ChatEntity chat = new ChatEntity();
        chat.setChatUuid(UUID.randomUUID());
        chat.setSubject(request.subject());
        chat.setBookingId(request.bookingId());
        chat.setCreatedBy(currentUserId);
        chat.setStatus(ChatStatus.open);
        chat.setCreatedAt(Instant.now());
        chat.setUpdatedAt(Instant.now());
        ChatDto result = toDto(chatRepository.save(chat));

        addParticipantInternal(chat.getId(), currentUserId);
        if (request.participantIds() != null) {
            request.participantIds().stream().distinct()
                    .filter(id -> !id.equals(currentUserId))
                    .forEach(id -> addParticipantInternal(chat.getId(), id));
        }
        chatEventService.publish("chat-created", chat.getId(), result);
        return result;
    }

    @Transactional(readOnly = true)
    public List<ChatDto> list(YourWayUserEntity principal) {
        Long userId = currentUserId(principal);
        List<Long> chatIds = participantRepository.findAllByUserId(userId).stream()
                .filter(participant -> participant.getLeftAt() == null)
                .map(ChatParticipantEntity::getChatId)
                .distinct()
                .toList();
        return chatRepository.findAllById(chatIds).stream().map(this::toDto).toList();
    }

    @Transactional(readOnly = true)
    public List<ChatDto> openChats(YourWayUserEntity principal) {
        requireAgent(principal);
        return chatRepository.findAllByOrderByUpdatedAtDesc().stream()
                .filter(chat -> chat.getStatus() == ChatStatus.open
                        || chat.getStatus() == ChatStatus.waiting_reassignment)
                .filter(chat -> !participantRepository.existsByChatIdAndUserId(chat.getId(), principal.getId()))
                .map(this::toDto)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<ChatDto> agentView(YourWayUserEntity principal, String filter) {
        requireAgent(principal);
        String normalizedFilter = filter == null ? "all" : filter.toLowerCase();
        if (!List.of("all", "closed", "mine", "waiting", "assigned").contains(normalizedFilter)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unknown agent chat filter");
        }

        return chatRepository.findAllByOrderByUpdatedAtDesc().stream()
                .filter(chat -> switch (normalizedFilter) {
                    case "closed" -> chat.getStatus() == ChatStatus.closed
                            || chat.getStatus() == ChatStatus.archived;
                    case "mine" -> hasActiveAgent(chat.getId(), principal.getId());
                    case "waiting" -> chat.getStatus() == ChatStatus.open
                            || chat.getStatus() == ChatStatus.waiting_reassignment;
                    case "assigned" -> chat.getStatus() == ChatStatus.assigned;
                    default -> true;
                })
                .map(this::toDto)
                .toList();
    }

    @Transactional
    public ChatDto claim(YourWayUserEntity principal, Long chatId) {
        requireAgent(principal);
        ChatEntity chat = findChat(chatId);
        if (chat.getStatus() != ChatStatus.open && chat.getStatus() != ChatStatus.waiting_reassignment) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Chat is no longer open");
        }
        boolean activeAgentParticipant = participantRepository.findByChatIdAndUserId(chatId, principal.getId())
                .filter(participant -> participant.getLeftAt() == null && participant.getRole() == ChatRole.agent)
                .isPresent();
        if (!activeAgentParticipant) {
            addParticipantInternal(chatId, principal.getId(), AGENT_ROLE);
        }
        chat.setStatus(ChatStatus.assigned);
        chat.setUpdatedAt(Instant.now());
        ChatDto result = toDto(chatRepository.save(chat));
        chatEventService.publish("chat-claimed", chatId, result);
        return result;
    }

    @Transactional
    public ChatDto release(YourWayUserEntity principal, Long chatId) {
        requireAgent(principal);
        ChatEntity chat = findChat(chatId);
        ChatParticipantEntity participant = participantRepository.findByChatIdAndUserId(chatId, principal.getId())
                .filter(item -> item.getLeftAt() == null && item.getRole() == ChatRole.agent)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN,
                        "Agent is not an active participant"));
        participant.setLeftAt(Instant.now());
        participantRepository.save(participant);
        chat.setStatus(ChatStatus.waiting_reassignment);
        chat.setUpdatedAt(Instant.now());
        ChatDto result = toDto(chatRepository.save(chat));
        chatEventService.publish("chat-without-agent", chatId, result);
        return result;
    }

    @Transactional
    public ChatDto close(YourWayUserEntity principal, Long chatId) {
        ChatEntity chat = requireParticipant(principal, chatId);
        if (isAgent(principal)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the client can close the chat");
        }
        if (chat.getStatus() == ChatStatus.closed || chat.getStatus() == ChatStatus.archived) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Chat is already closed");
        }
        chat.setStatus(ChatStatus.closed);
        chat.setUpdatedAt(Instant.now());
        ChatDto result = toDto(chatRepository.save(chat));
        chatEventService.publish("chat-closed", chatId, result);
        return result;
    }

    @Transactional(readOnly = true)
    public ChatDto get(YourWayUserEntity principal, Long chatId) {
        requireParticipant(principal, chatId);
        return toDto(findChat(chatId));
    }

    @Transactional(readOnly = true)
    public List<ChatParticipantDto> participants(YourWayUserEntity principal, Long chatId) {
        requireParticipant(principal, chatId);
        return participantRepository.findAllByChatId(chatId).stream().map(this::toDto).toList();
    }

    @Transactional
    public ChatParticipantDto addParticipant(YourWayUserEntity principal, Long chatId,
            AddChatParticipantRequest request) {
        ChatEntity chat = requireParticipant(principal, chatId);
        // FR : seuls le créateur du chat ou un agent peuvent gérer ses participants.
        // EN: only the chat creator or an agent may manage its participants.
        if (!Objects.equals(chat.getCreatedBy(), principal.getId()) && !isAgent(principal)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "User cannot manage participants");
        }
        return toDto(addParticipantInternal(chatId, request.userId(), request.role()));
    }

    @Transactional(readOnly = true)
    public List<ChatTextDto> messages(YourWayUserEntity principal, Long chatId) {
        requireParticipant(principal, chatId);
        return textRepository.findAllByChatIdOrderByCreatedAtAsc(chatId).stream().map(this::toDto).toList();
    }

    @Transactional
    public ChatTextDto sendMessage(YourWayUserEntity principal, Long chatId, SendChatTextRequest request) {
        Long senderId = currentUserId(principal);
        ChatEntity chat = requireParticipant(principal, chatId);
        if (chat.getStatus() == ChatStatus.closed || chat.getStatus() == ChatStatus.archived) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Chat is closed");
        }
        ChatTextEntity text = new ChatTextEntity();
        text.setChatId(chatId);
        text.setSenderId(senderId);
        text.setContentType(ChatContentType.valueOf(request.contentType() == null ? "text" : request.contentType()));
        text.setContent(request.content());
        text.setStatus(ChatTextStatus.sent);
        text.setCreatedAt(Instant.now());
        text.setUpdatedAt(Instant.now());
        ChatTextDto result = toDto(textRepository.save(text));
        chat.setUpdatedAt(Instant.now());
        chatRepository.save(chat);
        chatEventService.publish("message-created", chatId, result);
        return result;
    }

    private ChatParticipantEntity addParticipantInternal(Long chatId, Long userId) {
        return addParticipantInternal(chatId, userId, null);
    }

    private ChatParticipantEntity addParticipantInternal(Long chatId, Long userId, String requestedRole) {
        YourWayUserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        if (participantRepository.existsByChatIdAndUserId(chatId, userId)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "User is already a participant");
        }
        String role = requestedRole == null ? roleForUser(user) : requestedRole;
        if (!role.equals(roleForUser(user))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Participant role does not match user role");
        }
        ChatParticipantEntity participant = new ChatParticipantEntity();
        participant.setChatId(chatId);
        participant.setUserId(userId);
        participant.setRole(ChatRole.valueOf(role));
        participant.setJoinedAt(Instant.now());
        return participantRepository.save(participant);
    }

    public void requireParticipantAccess(YourWayUserEntity principal, Long chatId) {
        requireParticipant(principal, chatId);
    }

    public void requireAgentAccess(YourWayUserEntity principal) {
        requireAgent(principal);
    }

    private ChatEntity requireParticipant(YourWayUserEntity principal, Long chatId) {
        Long userId = currentUserId(principal);
        ChatEntity chat = findChat(chatId);
        participantRepository.findByChatIdAndUserId(chatId, userId)
                .filter(participant -> participant.getLeftAt() == null)
                .orElseThrow(
                        () -> new ResponseStatusException(HttpStatus.FORBIDDEN, "User is not an active participant"));
        return chat;
    }

    private ChatEntity findChat(Long chatId) {
        return chatRepository.findById(chatId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Chat not found"));
    }

    private static String roleForUser(YourWayUserEntity user) {
        return AGENT_ROLE.equalsIgnoreCase(user.getUserRole()) ? AGENT_ROLE : "client";
    }

    private boolean hasActiveAgent(Long chatId, Long userId) {
        return participantRepository.findByChatIdAndUserId(chatId, userId)
                .filter(participant -> participant.getLeftAt() == null && participant.getRole() == ChatRole.agent)
                .isPresent();
    }

    private static boolean isAgent(YourWayUserEntity user) {
        return AGENT_ROLE.equalsIgnoreCase(user.getUserRole());
    }

    private static void requireAgent(YourWayUserEntity principal) {
        currentUserId(principal);
        if (!isAgent(principal)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Agent role required");
        }
    }

    private static Long currentUserId(YourWayUserEntity principal) {
        if (principal == null || principal.getId() == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Unauthorized");
        }
        return principal.getId();
    }

    private ChatDto toDto(ChatEntity chat) {
        return new ChatDto(chat.getId(), chat.getChatUuid(), chat.getSubject(), chat.getBookingId(),
                chat.getCreatedBy(), chat.getStatus().name(), chat.getCreatedAt(), chat.getUpdatedAt());
    }

    private ChatParticipantDto toDto(ChatParticipantEntity participant) {
        return new ChatParticipantDto(participant.getId(), participant.getChatId(), participant.getUserId(),
                participant.getRole().name(), participant.getJoinedAt(), participant.getLeftAt());
    }

    private ChatTextDto toDto(ChatTextEntity text) {
        return new ChatTextDto(text.getId(), text.getChatId(), text.getSenderId(), text.getContentType().name(),
                text.getContent(), text.getStatus().name(), text.getCreatedAt(), text.getUpdatedAt());
    }
}
