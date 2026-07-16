package com.openclassrooms.yourwayapi.repository.chat;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

import com.openclassrooms.yourwayapi.entity.chat.ChatTextReadEntity;

public interface ChatTextReadRepository extends JpaRepository<ChatTextReadEntity, Long> {
    List<ChatTextReadEntity> findAllByChatTextId(Long chatTextId);

    List<ChatTextReadEntity> findAllByUserId(Long userId);
}
