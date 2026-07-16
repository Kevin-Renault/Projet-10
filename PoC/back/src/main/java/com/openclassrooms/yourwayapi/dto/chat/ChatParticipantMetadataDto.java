package com.openclassrooms.yourwayapi.dto.chat;

import java.time.Instant;

public record ChatParticipantMetadataDto(Long id, Long chatParticipantId, String metaKey,
        String metaValue, Instant createdAt) {
}
