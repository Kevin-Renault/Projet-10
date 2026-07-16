package com.openclassrooms.yourwayapi.dto.chat;

import java.time.Instant;

public record ChatTextMetadataDto(Long id, Long chatTextId, String metaKey, String metaValue,
        Instant createdAt) {
}
