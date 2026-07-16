package com.openclassrooms.yourwayapi.dto.chat;

import java.time.Instant;

public record ChatTextReadDto(Long id, Long chatTextId, Long userId, Instant readAt) {
}
