package com.openclassrooms.yourwayapi.service;

import java.io.IOException;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

@Service
public class ChatEventService {

    private final ConcurrentHashMap<Long, Set<SseEmitter>> chatEmitters = new ConcurrentHashMap<>();
    private final Set<SseEmitter> agentEmitters = ConcurrentHashMap.newKeySet();

    public SseEmitter subscribeToChat(Long chatId) {
        SseEmitter emitter = new SseEmitter(30 * 60 * 1000L);
        Set<SseEmitter> emitters = chatEmitters.computeIfAbsent(chatId, key -> ConcurrentHashMap.newKeySet());
        emitters.add(emitter);
        registerCleanup(emitter, () -> removeChatEmitter(chatId, emitter));
        return emitter;
    }

    public SseEmitter subscribeAsAgent() {
        SseEmitter emitter = new SseEmitter(30 * 60 * 1000L);
        agentEmitters.add(emitter);
        registerCleanup(emitter, () -> agentEmitters.remove(emitter));
        return emitter;
    }

    public void publish(String type, Long chatId, Object data) {
        ChatEvent event = new ChatEvent(type, chatId, data);
        sendTo(chatEmitters.getOrDefault(chatId, Set.of()), event);
        sendTo(agentEmitters, event);
    }

    private void sendTo(Set<SseEmitter> emitters, ChatEvent event) {
        for (SseEmitter emitter : emitters) {
            try {
                emitter.send(SseEmitter.event().name("chat-event").data(event));
            } catch (IOException | IllegalStateException exception) {
                emitter.completeWithError(exception);
            }
        }
    }

    private void registerCleanup(SseEmitter emitter, Runnable cleanup) {
        emitter.onCompletion(cleanup);
        emitter.onTimeout(() -> {
            cleanup.run();
            emitter.complete();
        });
        emitter.onError(exception -> cleanup.run());
    }

    private void removeChatEmitter(Long chatId, SseEmitter emitter) {
        Set<SseEmitter> emitters = chatEmitters.get(chatId);
        if (emitters != null) {
            emitters.remove(emitter);
            if (emitters.isEmpty()) {
                chatEmitters.remove(chatId, emitters);
            }
        }
    }

    public record ChatEvent(String type, Long chatId, Object data) {
    }
}
