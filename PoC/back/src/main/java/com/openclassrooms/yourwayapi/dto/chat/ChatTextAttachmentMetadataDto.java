package com.openclassrooms.yourwayapi.dto.chat;

import java.time.Instant;

public record ChatTextAttachmentMetadataDto(Long id, Long chatTextAttachmentId, String metaKey,
        String metaValue, Instant createdAt) {
}
