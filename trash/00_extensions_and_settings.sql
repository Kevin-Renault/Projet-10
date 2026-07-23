-- 00_extensions_and_settings.sql
-- EN: Enable required extensions and set basic DB-level notes.
-- FR: Active les extensions requises et notes de configuration DB.
-- Ensure pgcrypto is available for gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- Notes:
-- - `CREATE EXTENSION` may require superuser privileges or a role with CREATE privilege on database.
-- - Run this file first.