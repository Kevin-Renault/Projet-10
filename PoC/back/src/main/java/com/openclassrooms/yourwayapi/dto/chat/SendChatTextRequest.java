package com.openclassrooms.yourwayapi.dto.chat;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record SendChatTextRequest(
        @NotBlank @Size(max = 10000) String content,
        @Size(max = 20) String contentType) {
}
