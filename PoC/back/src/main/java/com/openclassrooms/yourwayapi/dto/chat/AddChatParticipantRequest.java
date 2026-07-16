package com.openclassrooms.yourwayapi.dto.chat;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;

public record AddChatParticipantRequest(
        @NotNull Long userId,
        @Pattern(regexp = "client|agent|system") String role) {
}
