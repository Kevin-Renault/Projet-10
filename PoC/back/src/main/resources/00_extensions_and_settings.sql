-- 00_extensions_and_settings.sql
-- SAFE DROP BLOCK
-- Remove extensions if present (safe to run before recreating schema)
DROP EXTENSION IF EXISTS pgcrypto;
-- EN: Enable required extensions and set basic DB-level notes.
-- FR: Active les extensions requises et notes de configuration DB.
-- Ensure pgcrypto is available for gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- Notes:
-- - `CREATE EXTENSION` may require superuser privileges or a role with CREATE privilege on database.
-- - Run this file first.