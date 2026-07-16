package com.openclassrooms.yourwayapi.dto.chat;

import jakarta.validation.constraints.Size;
import java.util.List;

public record CreateChatRequest(
        @Size(max = 255) String subject,
        Long bookingId,
        List<Long> participantIds) {
}
