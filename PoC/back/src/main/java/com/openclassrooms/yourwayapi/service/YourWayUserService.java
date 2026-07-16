package com.openclassrooms.yourwayapi.service;

import com.openclassrooms.yourwayapi.dto.UserDto;
import com.openclassrooms.yourwayapi.entity.YourWayUserEntity;
import com.openclassrooms.yourwayapi.mapper.UserMapper;
import com.openclassrooms.yourwayapi.repository.YourWayUserRepository;
import java.util.List;
import java.util.regex.Pattern;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class YourWayUserService {

    private static final Pattern PASSWORD_PATTERN = Pattern.compile(
            "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[#?!@$%^&*-]).{8,}$");

    private final YourWayUserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final UserMapper userMapper;

    public YourWayUserService(YourWayUserRepository userRepository, PasswordEncoder passwordEncoder,
            UserMapper userMapper) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.userMapper = userMapper;
    }

    @Transactional(readOnly = true)
    public List<UserDto> getAll() {
        return userRepository.findAll().stream().map(userMapper::toDto).toList();
    }

    @Transactional(readOnly = true)
    public UserDto getById(Long id) {
        YourWayUserEntity user = userRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        return userMapper.toDto(user);
    }

    @Transactional
    public UserDto update(YourWayUserEntity principal, UserDto request) {
        if (request == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid payload");
        }
        Long principalId = requireAuthenticatedUserId(principal);
        YourWayUserEntity user = userRepository.findById(principalId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        String newUsername = trimToNull(request.username());
        String newEmail = trimToNull(request.email());
        String newPassword = trimToNull(request.password());

        if (newUsername != null && !newUsername.equals(user.getUsername())) {
            userRepository.findByUsername(newUsername)
                    .filter(u -> !u.getId().equals(user.getId()))
                    .ifPresent(u -> {
                        throw new ResponseStatusException(HttpStatus.CONFLICT, "Username already used");
                    });
            user.setUsername(newUsername);
        }

        if (newEmail != null && !newEmail.equals(user.getEmail())) {
            userRepository.findByEmail(newEmail)
                    .filter(u -> !u.getId().equals(user.getId()))
                    .ifPresent(u -> {
                        throw new ResponseStatusException(HttpStatus.CONFLICT, "Email already used");
                    });
            user.setEmail(newEmail);
        }

        if (newPassword != null) {
            requireValidPassword(newPassword);
            user.setPasswordHash(passwordEncoder.encode(newPassword));
        }

        YourWayUserEntity saved = userRepository.save(user);
        return userMapper.toDto(saved);
    }

    private static Long requireAuthenticatedUserId(YourWayUserEntity principal) {
        if (principal == null || principal.getId() == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Unauthorized");
        }
        return principal.getId();
    }

    private static void requireValidPassword(String password) {
        if (password == null || !PASSWORD_PATTERN.matcher(password).matches()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Password does not meet requirements");
        }
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
