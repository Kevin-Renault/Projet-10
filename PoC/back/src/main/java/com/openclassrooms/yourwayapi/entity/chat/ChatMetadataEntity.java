package com.openclassrooms.yourwayapi.entity.chat;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "chat_metadata")
@Getter
@Setter
@NoArgsConstructor
public class ChatMetadataEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "chat_id", nullable = false)
    private Long chatId;

    @Column(name = "meta_key", nullable = false, length = 255)
    private String metaKey;

    @Column(name = "meta_value")
    private String metaValue;

    @Column(name = "created_at")
    private Instant createdAt;
}
