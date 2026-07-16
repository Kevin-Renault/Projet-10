package com.openclassrooms.yourwayapi.mapper;

import com.openclassrooms.yourwayapi.dto.UserDto;
import com.openclassrooms.yourwayapi.entity.YourWayUserEntity;
import org.springframework.stereotype.Component;

@Component
public class UserMapper {

    public UserDto toDto(YourWayUserEntity entity) {
        if (entity == null) {
            return null;
        }
        return new UserDto(
                entity.getId(),
                entity.getUsername(),
                entity.getEmail(),
                "",
                "user",
                entity.getCreatedAt());
    }

    /**
     * Note: le DTO ne contient pas le mot de passe.
     * Cette conversion ne renseigne donc pas le champ password.
     */
    public YourWayUserEntity toEntity(UserDto dto) {
        if (dto == null) {
            return null;
        }
        YourWayUserEntity entity = new YourWayUserEntity();
        entity.setId(dto.id());
        entity.setUsername(dto.username());
        entity.setEmail(dto.email());
        entity.setCreatedAt(dto.createdAt());
        return entity;
    }

    public YourWayUserEntity reference(Long id) {
        if (id == null) {
            return null;
        }
        YourWayUserEntity entity = new YourWayUserEntity();
        entity.setId(id);
        return entity;
    }
}
