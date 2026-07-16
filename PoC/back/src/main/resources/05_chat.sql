-- 05_chat.sql
-- SAFE DROP BLOCK
-- Drop chat objects in dependency order
DROP TABLE IF EXISTS chat_text_read CASCADE;
DROP TABLE IF EXISTS chat_text_attachment_metadata CASCADE;
DROP TABLE IF EXISTS chat_text_attachment CASCADE;
DROP TABLE IF EXISTS chat_text_metadata CASCADE;
DROP TABLE IF EXISTS chat_text CASCADE;
DROP TABLE IF EXISTS chat_participant_metadata CASCADE;
DROP TABLE IF EXISTS chat_participant CASCADE;
DROP TABLE IF EXISTS chat_metadata CASCADE;
DROP TABLE IF EXISTS chat CASCADE;
-- EN: Chat PoC tables: conversations, participants, messages, attachments, read receipts
-- FR: Tchat PoC : conversations, participants, messages, pièces jointes, accusés de lecture
CREATE TABLE IF NOT EXISTS chat (
    id BIGSERIAL PRIMARY KEY,
    chat_uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    subject VARCHAR(255) NULL,
    booking_id BIGINT NULL,
    created_by BIGINT NULL,
    status chat_status_type DEFAULT 'open',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    FOREIGN KEY (booking_id) REFERENCES booking(id) ON DELETE
    SET NULL,
        FOREIGN KEY (created_by) REFERENCES ycyw_user(id) ON DELETE
    SET NULL
);
-- Chat metadata normalized into key/value table (strict 1NF)
CREATE TABLE IF NOT EXISTS chat_metadata (
    id BIGSERIAL PRIMARY KEY,
    chat_id BIGINT NOT NULL,
    meta_key VARCHAR(255) NOT NULL,
    meta_value TEXT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    FOREIGN KEY (chat_id) REFERENCES chat(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_chat_metadata_chat ON chat_metadata(chat_id);
CREATE TABLE IF NOT EXISTS chat_participant (
    id BIGSERIAL PRIMARY KEY,
    chat_id BIGINT NOT NULL,
    user_id BIGINT NULL,
    role chat_role_type NOT NULL DEFAULT 'client',
    joined_at TIMESTAMPTZ DEFAULT now(),
    left_at TIMESTAMPTZ NULL,
    FOREIGN KEY (chat_id) REFERENCES chat(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES ycyw_user(id) ON DELETE
    SET NULL
);
-- Chat participant metadata table (strict 1NF)
CREATE TABLE IF NOT EXISTS chat_participant_metadata (
    id BIGSERIAL PRIMARY KEY,
    chat_participant_id BIGINT NOT NULL,
    meta_key VARCHAR(255) NOT NULL,
    meta_value TEXT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    FOREIGN KEY (chat_participant_id) REFERENCES chat_participant(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_chat_participant_metadata_participant ON chat_participant_metadata(chat_participant_id);
CREATE TABLE IF NOT EXISTS chat_text (
    id BIGSERIAL PRIMARY KEY,
    chat_id BIGINT NOT NULL,
    sender_id BIGINT NULL,
    content_type chat_content_type DEFAULT 'text',
    content TEXT NULL,
    status chat_text_status_type DEFAULT 'sent',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    FOREIGN KEY (chat_id) REFERENCES chat(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES ycyw_user(id) ON DELETE
    SET NULL
);
-- Chat text metadata (strict 1NF)
CREATE TABLE IF NOT EXISTS chat_text_metadata (
    id BIGSERIAL PRIMARY KEY,
    chat_text_id BIGINT NOT NULL,
    meta_key VARCHAR(255) NOT NULL,
    meta_value TEXT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    FOREIGN KEY (chat_text_id) REFERENCES chat_text(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_chat_text_metadata_text ON chat_text_metadata(chat_text_id);
CREATE TABLE IF NOT EXISTS chat_text_attachment (
    id BIGSERIAL PRIMARY KEY,
    chat_text_id BIGINT NOT NULL,
    filename VARCHAR(255) NULL,
    url TEXT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    FOREIGN KEY (chat_text_id) REFERENCES chat_text(id) ON DELETE CASCADE
);
-- Chat text attachment metadata (strict 1NF)
CREATE TABLE IF NOT EXISTS chat_text_attachment_metadata (
    id BIGSERIAL PRIMARY KEY,
    chat_text_attachment_id BIGINT NOT NULL,
    meta_key VARCHAR(255) NOT NULL,
    meta_value TEXT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    FOREIGN KEY (chat_text_attachment_id) REFERENCES chat_text_attachment(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_chat_text_attachment_metadata_att ON chat_text_attachment_metadata(chat_text_attachment_id);
CREATE TABLE IF NOT EXISTS chat_text_read (
    id BIGSERIAL PRIMARY KEY,
    chat_text_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    read_at TIMESTAMPTZ DEFAULT now(),
    FOREIGN KEY (chat_text_id) REFERENCES chat_text(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES ycyw_user(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_chat_booking ON chat(booking_id);
CREATE INDEX IF NOT EXISTS idx_chat_participant_user ON chat_participant(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_text_sender ON chat_text(sender_id);
CREATE INDEX IF NOT EXISTS idx_chat_text_created ON chat_text(created_at);