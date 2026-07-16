package com.openclassrooms.yourwayapi.controller;

import com.openclassrooms.yourwayapi.dto.chat.AddChatParticipantRequest;
import com.openclassrooms.yourwayapi.dto.chat.ChatDto;
import com.openclassrooms.yourwayapi.dto.chat.ChatParticipantDto;
import com.openclassrooms.yourwayapi.dto.chat.ChatTextDto;
import com.openclassrooms.yourwayapi.dto.chat.CreateChatRequest;
import com.openclassrooms.yourwayapi.dto.chat.SendChatTextRequest;
import com.openclassrooms.yourwayapi.entity.YourWayUserEntity;
import com.openclassrooms.yourwayapi.service.ChatService;
import com.openclassrooms.yourwayapi.service.ChatEventService;
import com.openclassrooms.yourwayapi.ApiEndpoints;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

@RestController
@RequestMapping(ApiEndpoints.CHATS)
public class ChatController {

    private final ChatService chatService;
    private final ChatEventService chatEventService;

    public ChatController(ChatService chatService, ChatEventService chatEventService) {
        this.chatService = chatService;
        this.chatEventService = chatEventService;
    }

    @PostMapping
    public ChatDto create(@AuthenticationPrincipal YourWayUserEntity principal,
            @Valid @RequestBody CreateChatRequest request) {
        return chatService.create(principal, request);
    }

    @GetMapping
    public List<ChatDto> list(@AuthenticationPrincipal YourWayUserEntity principal) {
        return chatService.list(principal);
    }

    @GetMapping("/open")
    public List<ChatDto> openChats(@AuthenticationPrincipal YourWayUserEntity principal) {
        return chatService.openChats(principal);
    }

    @GetMapping("/agent-view")
    public List<ChatDto> agentView(@AuthenticationPrincipal YourWayUserEntity principal,
            @RequestParam(defaultValue = "all") String filter) {
        return chatService.agentView(principal, filter);
    }

    @GetMapping(value = "/agent-events", produces = "text/event-stream")
    public SseEmitter agentEvents(@AuthenticationPrincipal YourWayUserEntity principal) {
        chatService.requireAgentAccess(principal);
        return chatEventService.subscribeAsAgent();
    }

    @GetMapping(value = "/{chatId}/events", produces = "text/event-stream")
    public SseEmitter chatEvents(@AuthenticationPrincipal YourWayUserEntity principal,
            @PathVariable Long chatId) {
        chatService.requireParticipantAccess(principal, chatId);
        return chatEventService.subscribeToChat(chatId);
    }

    @GetMapping("/{chatId}")
    public ChatDto get(@AuthenticationPrincipal YourWayUserEntity principal, @PathVariable Long chatId) {
        return chatService.get(principal, chatId);
    }

    @PostMapping("/{chatId}/claim")
    public ChatDto claim(@AuthenticationPrincipal YourWayUserEntity principal, @PathVariable Long chatId) {
        return chatService.claim(principal, chatId);
    }

    @PostMapping("/{chatId}/release")
    public ChatDto release(@AuthenticationPrincipal YourWayUserEntity principal, @PathVariable Long chatId) {
        return chatService.release(principal, chatId);
    }

    @PostMapping("/{chatId}/close")
    public ChatDto close(@AuthenticationPrincipal YourWayUserEntity principal, @PathVariable Long chatId) {
        return chatService.close(principal, chatId);
    }

    @GetMapping("/{chatId}/participants")
    public List<ChatParticipantDto> participants(@AuthenticationPrincipal YourWayUserEntity principal,
            @PathVariable Long chatId) {
        return chatService.participants(principal, chatId);
    }

    @PostMapping("/{chatId}/participants")
    public ChatParticipantDto addParticipant(@AuthenticationPrincipal YourWayUserEntity principal,
            @PathVariable Long chatId, @Valid @RequestBody AddChatParticipantRequest request) {
        return chatService.addParticipant(principal, chatId, request);
    }

    @GetMapping("/{chatId}/messages")
    public List<ChatTextDto> messages(@AuthenticationPrincipal YourWayUserEntity principal,
            @PathVariable Long chatId) {
        return chatService.messages(principal, chatId);
    }

    @PostMapping("/{chatId}/messages")
    public ChatTextDto sendMessage(@AuthenticationPrincipal YourWayUserEntity principal,
            @PathVariable Long chatId, @Valid @RequestBody SendChatTextRequest request) {
        return chatService.sendMessage(principal, chatId, request);
    }
}
