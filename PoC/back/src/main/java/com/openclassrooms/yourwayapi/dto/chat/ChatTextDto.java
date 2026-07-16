package com.openclassrooms.yourwayapi.dto.chat;

import java.time.Instant;

public record ChatTextDto(Long id, Long chatId, Long senderId, String contentType,
        String content, String status, Instant createdAt, Instant updatedAt) {
}
