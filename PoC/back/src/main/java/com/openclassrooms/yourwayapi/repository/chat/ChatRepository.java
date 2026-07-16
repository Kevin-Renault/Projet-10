package com.openclassrooms.yourwayapi.repository.chat;

import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

import com.openclassrooms.yourwayapi.entity.chat.ChatEntity;
import com.openclassrooms.yourwayapi.entity.chat.ChatStatus;

public interface ChatRepository extends JpaRepository<ChatEntity, Long> {
    List<ChatEntity> findAllByBookingIdOrderByUpdatedAtDesc(Long bookingId);

    List<ChatEntity> findAllByStatusOrderByUpdatedAtDesc(ChatStatus status);

    List<ChatEntity> findAllByOrderByUpdatedAtDesc();

    java.util.Optional<ChatEntity> findByChatUuid(UUID chatUuid);
}
