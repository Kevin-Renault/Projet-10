package com.openclassrooms.yourwayapi.repository;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

import com.openclassrooms.yourwayapi.entity.YourWayUserEntity;

public interface YourWayUserRepository extends JpaRepository<YourWayUserEntity, Long> {
    Optional<YourWayUserEntity> findByEmail(String email);

    Optional<YourWayUserEntity> findByUsername(String username);

    boolean existsByEmail(String email);

    boolean existsByUsername(String username);
}
