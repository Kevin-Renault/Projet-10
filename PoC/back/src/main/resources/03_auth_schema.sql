-- 03_auth_schema.sql
-- SAFE DROP BLOCK
-- Drop auth-related objects in dependency order (dependents first)
DROP TABLE IF EXISTS user_accessibility_pref CASCADE;
DROP TABLE IF EXISTS refresh_token CASCADE;
DROP TABLE IF EXISTS service_account_scope CASCADE;
DROP TABLE IF EXISTS service_account CASCADE;
DROP TABLE IF EXISTS agent_profile_permission CASCADE;
DROP TABLE IF EXISTS agent_profile CASCADE;
DROP TABLE IF EXISTS email_verification CASCADE;
DROP TABLE IF EXISTS user_profile CASCADE;
DROP TABLE IF EXISTS permission CASCADE;
DROP TABLE IF EXISTS ycyw_user CASCADE;
DROP TABLE IF EXISTS agence_opening_hour CASCADE;
DROP TABLE IF EXISTS agence CASCADE;
-- EN: User, profile, service account, refresh_token tables
-- FR: Utilisateurs, profils, comptes de service, refresh_token
CREATE TABLE IF NOT EXISTS agence (
    id BIGSERIAL PRIMARY KEY,
    agence_uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    agence_name VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    agence_address TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    author_id BIGINT NULL,
    agence_status VARCHAR(20) NOT NULL DEFAULT 'active'
);
CREATE TABLE IF NOT EXISTS agence_opening_hour (
    id BIGSERIAL PRIMARY KEY,
    agence_id BIGINT NOT NULL,
    day_of_week SMALLINT NOT NULL,
    opens_at TIME NOT NULL,
    closes_at TIME NOT NULL,
    UNIQUE (agence_id, day_of_week),
    CHECK (
        day_of_week BETWEEN 0 AND 6
    ),
    CHECK (opens_at < closes_at),
    FOREIGN KEY (agence_id) REFERENCES agence(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_agence_opening_hour_agence ON agence_opening_hour(agence_id);
CREATE TABLE IF NOT EXISTS ycyw_user (
    id BIGSERIAL PRIMARY KEY,
    user_uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    user_role VARCHAR(50) NOT NULL DEFAULT 'client',
    agence_id BIGINT NULL,
    auth_type VARCHAR(50) DEFAULT 'password',
    phone VARCHAR(20) NULL,
    preferred_language CHAR(2) DEFAULT 'fr',
    timezone VARCHAR(50) DEFAULT 'Europe/Paris',
    -- accessibility_prefs moved to `user_accessibility_pref` (strict 1NF)
    is_psh BOOLEAN DEFAULT FALSE,
    psh_needs psh_need NOT NULL DEFAULT 'none',
    external_id VARCHAR(255) NULL,
    user_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT now(),
    last_login TIMESTAMPTZ NULL,
    CHECK (
        user_status IN ('pending', 'active', 'suspended', 'deleted')
    ),
    FOREIGN KEY (agence_id) REFERENCES agence(id) ON DELETE
    SET NULL
);
CREATE TABLE IF NOT EXISTS user_profile (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    address TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    FOREIGN KEY (user_id) REFERENCES ycyw_user(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_user_profile_user ON user_profile(user_id);
-- Email activation codes are stored as hashes and are single-use and time-limited.
CREATE TABLE IF NOT EXISTS email_verification (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    code_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    attempt_count SMALLINT NOT NULL DEFAULT 0,
    verified_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    FOREIGN KEY (user_id) REFERENCES ycyw_user(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_email_verification_expires ON email_verification(expires_at);
CREATE TABLE IF NOT EXISTS agent_profile (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    badge_number VARCHAR(50) NULL,
    desk VARCHAR(50) NULL,
    -- permissions moved to normalized tables: permission + agent_profile_permission
    FOREIGN KEY (user_id) REFERENCES ycyw_user(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS permission (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(100) NOT NULL UNIQUE,
    label VARCHAR(255) NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);
CREATE TABLE IF NOT EXISTS agent_profile_permission (
    agent_profile_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    PRIMARY KEY (agent_profile_id, permission_id),
    FOREIGN KEY (agent_profile_id) REFERENCES agent_profile(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permission(id) ON DELETE RESTRICT
);
CREATE INDEX IF NOT EXISTS idx_agent_profile_permission_perm ON agent_profile_permission(permission_id);
CREATE TABLE IF NOT EXISTS service_account (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    agence_id BIGINT NULL,
    api_key_hash VARCHAR(255) NOT NULL,
    -- scopes normalized into `service_account_scope`
    created_at TIMESTAMPTZ DEFAULT now(),
    last_used TIMESTAMPTZ NULL,
    UNIQUE (api_key_hash),
    FOREIGN KEY (agence_id) REFERENCES agence(id) ON DELETE
    SET NULL
);
CREATE TABLE IF NOT EXISTS service_account_scope (
    service_account_id BIGINT NOT NULL,
    scope VARCHAR(255) NOT NULL,
    PRIMARY KEY (service_account_id, scope),
    FOREIGN KEY (service_account_id) REFERENCES service_account(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_service_account_scope_sa ON service_account_scope(service_account_id);
CREATE TABLE IF NOT EXISTS refresh_token (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (user_id),
    UNIQUE (token_hash),
    token_type VARCHAR(20) DEFAULT 'refresh',
    ip_address INET,
    user_agent TEXT,
    FOREIGN KEY (user_id) REFERENCES ycyw_user(id) ON DELETE CASCADE
);
-- helpful indexes
CREATE INDEX IF NOT EXISTS idx_user_agence ON ycyw_user(agence_id);
CREATE INDEX IF NOT EXISTS idx_service_account_agence ON service_account(agence_id);
CREATE INDEX IF NOT EXISTS idx_refresh_user ON refresh_token(user_id);
-- Accessibility preferences use one normalized row per user (strict 1NF).
CREATE TABLE IF NOT EXISTS user_accessibility_pref (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    high_contrast BOOLEAN NOT NULL DEFAULT FALSE,
    large_text BOOLEAN NOT NULL DEFAULT FALSE,
    screen_reader BOOLEAN NOT NULL DEFAULT FALSE,
    reduced_motion BOOLEAN NOT NULL DEFAULT FALSE,
    wheelchair_access BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT now(),
    FOREIGN KEY (user_id) REFERENCES ycyw_user(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_user_accessibility_pref_user ON user_accessibility_pref(user_id);