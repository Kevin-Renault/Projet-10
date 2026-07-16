package com.openclassrooms.yourwayapi.repository.chat;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

import com.openclassrooms.yourwayapi.entity.chat.ChatTextEntity;

public interface ChatTextRepository extends JpaRepository<ChatTextEntity, Long> {
    List<ChatTextEntity> findAllByChatIdOrderByCreatedAtAsc(Long chatId);

    List<ChatTextEntity> findAllBySenderIdOrderByCreatedAtDesc(Long senderId);
}
