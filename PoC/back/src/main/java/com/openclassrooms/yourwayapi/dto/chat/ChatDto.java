package com.openclassrooms.yourwayapi.dto.chat;

import java.time.Instant;
import java.util.UUID;

public record ChatDto(Long id, UUID chatUuid, String subject, Long bookingId, Long createdBy,
                String status, Long assignedAgentId, Instant createdAt, Instant updatedAt) {
}
