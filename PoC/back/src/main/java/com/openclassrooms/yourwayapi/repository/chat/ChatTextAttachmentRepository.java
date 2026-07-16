package com.openclassrooms.yourwayapi.repository.chat;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

import com.openclassrooms.yourwayapi.entity.chat.ChatTextAttachmentEntity;

public interface ChatTextAttachmentRepository extends JpaRepository<ChatTextAttachmentEntity, Long> {
    List<ChatTextAttachmentEntity> findAllByChatTextId(Long chatTextId);
}
