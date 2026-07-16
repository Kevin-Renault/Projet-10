package com.openclassrooms.yourwayapi.dto.chat;

import java.time.Instant;

public record ChatTextAttachmentDto(Long id, Long chatTextId, String filename, String url,
        Instant createdAt) {
}
