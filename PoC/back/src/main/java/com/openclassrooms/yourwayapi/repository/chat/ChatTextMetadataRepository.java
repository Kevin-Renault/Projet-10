package com.openclassrooms.yourwayapi.repository.chat;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

import com.openclassrooms.yourwayapi.entity.chat.ChatTextMetadataEntity;

public interface ChatTextMetadataRepository extends JpaRepository<ChatTextMetadataEntity, Long> {
    List<ChatTextMetadataEntity> findAllByChatTextId(Long chatTextId);
}
