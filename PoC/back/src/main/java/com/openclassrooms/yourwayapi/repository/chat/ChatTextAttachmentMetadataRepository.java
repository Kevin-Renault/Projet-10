package com.openclassrooms.yourwayapi.repository.chat;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

import com.openclassrooms.yourwayapi.entity.chat.ChatTextAttachmentMetadataEntity;

public interface ChatTextAttachmentMetadataRepository extends JpaRepository<ChatTextAttachmentMetadataEntity, Long> {
    List<ChatTextAttachmentMetadataEntity> findAllByChatTextAttachmentId(Long chatTextAttachmentId);
}
