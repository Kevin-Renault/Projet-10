package com.openclassrooms.yourwayapi.dto.chat;

import java.time.Instant;

public record ChatMetadataDto(Long id, Long chatId, String metaKey, String metaValue, Instant createdAt) {
}
