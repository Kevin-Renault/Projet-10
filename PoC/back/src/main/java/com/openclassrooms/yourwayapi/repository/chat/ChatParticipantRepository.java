package com.openclassrooms.yourwayapi.repository.chat;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

import com.openclassrooms.yourwayapi.entity.chat.ChatParticipantEntity;

public interface ChatParticipantRepository extends JpaRepository<ChatParticipantEntity, Long> {
    List<ChatParticipantEntity> findAllByChatId(Long chatId);

    List<ChatParticipantEntity> findAllByUserId(Long userId);

    Optional<ChatParticipantEntity> findByChatIdAndUserId(Long chatId, Long userId);

    boolean existsByChatIdAndUserId(Long chatId, Long userId);
}
