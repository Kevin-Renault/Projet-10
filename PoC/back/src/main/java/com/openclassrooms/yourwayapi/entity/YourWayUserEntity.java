package com.openclassrooms.yourwayapi.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Entity
@Table(name = "ycyw_user")
@Getter
@Setter
@NoArgsConstructor
public class YourWayUserEntity {

    public enum PshNeed {
        none,
        blind,
        low_vision,
        hearing_impaired,
        motor_disability,
        reduced_mobility,
        cognitive_impairment
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_uuid", nullable = false, unique = true)
    private UUID userUuid;

    @Column(name = "username", nullable = false, unique = true, length = 100)
    private String username;

    @Column(name = "email", nullable = false, unique = true, length = 255)
    private String email;

    @Column(name = "password_hash", nullable = false, length = 255)
    private String passwordHash;

    @Column(name = "user_role", nullable = false, length = 50)
    private String userRole = "client";

    @Column(name = "agence_id")
    private Long agenceId;

    @Column(name = "auth_type", length = 50)
    private String authType = "password";

    @Column(name = "phone", length = 20)
    private String phone;

    @Column(name = "preferred_language", length = 2)
    private String preferredLanguage = "fr";

    @Column(name = "timezone", length = 50)
    private String timezone = "Europe/Paris";

    @Column(name = "is_psh")
    private Boolean isPsh = false;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "psh_needs", columnDefinition = "psh_need", nullable = false)
    private PshNeed pshNeeds = PshNeed.none;

    @Column(name = "external_id", length = 255)
    private String externalId;

    @Column(name = "user_status", length = 20)
    private String userStatus = "pending";

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "last_login")
    private Instant lastLogin;

    @PrePersist
    private void generateUuid() {
        if (userUuid == null) {
            userUuid = UUID.randomUUID();
        }
    }
}
