package com.openclassrooms.yourwayapi.repository.chat;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

import com.openclassrooms.yourwayapi.entity.chat.ChatMetadataEntity;

public interface ChatMetadataRepository extends JpaRepository<ChatMetadataEntity, Long> {
    List<ChatMetadataEntity> findAllByChatId(Long chatId);
}
