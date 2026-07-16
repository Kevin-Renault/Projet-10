package com.openclassrooms.yourwayapi.repository.chat;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

import com.openclassrooms.yourwayapi.entity.chat.ChatParticipantMetadataEntity;

public interface ChatParticipantMetadataRepository extends JpaRepository<ChatParticipantMetadataEntity, Long> {
    List<ChatParticipantMetadataEntity> findAllByChatParticipantId(Long chatParticipantId);
}
