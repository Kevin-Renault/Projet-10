package com.openclassrooms.yourwayapi.dto.chat;

import java.time.Instant;

public record ChatParticipantDto(Long id, Long chatId, Long userId, String role,
        Instant joinedAt, Instant leftAt) {
}
