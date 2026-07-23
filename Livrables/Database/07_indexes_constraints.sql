-- 07_indexes_constraints.sql
-- SAFE DROP BLOCK
-- Drop indexes created by this file
DROP INDEX IF EXISTS ux_agence_uuid;
DROP INDEX IF EXISTS ux_user_uuid;
DROP INDEX IF EXISTS ux_booking_uuid;
DROP INDEX IF EXISTS ux_chat_uuid;
DROP INDEX IF EXISTS ux_offer_uuid;
DROP INDEX IF EXISTS ux_vehicle_uuid;
DROP INDEX IF EXISTS ux_chat_text_uuid;
DROP INDEX IF EXISTS ux_payment_provider_payment;
DROP INDEX IF EXISTS ux_webhook_provider_event;
-- EN: Additional unique indexes and constraints for public UUIDs and idempotency
-- FR: Indexes uniques et contraintes supplémentaires pour UUID publiques et idempotence
-- Public UUID uniqueness indexes (explicit)
CREATE UNIQUE INDEX IF NOT EXISTS ux_agence_uuid ON agence(agence_uuid);
CREATE UNIQUE INDEX IF NOT EXISTS ux_user_uuid ON ycyw_user(user_uuid);
CREATE UNIQUE INDEX IF NOT EXISTS ux_booking_uuid ON booking(booking_uuid);
CREATE UNIQUE INDEX IF NOT EXISTS ux_chat_uuid ON chat(chat_uuid);
CREATE UNIQUE INDEX IF NOT EXISTS ux_offer_uuid ON offer(offer_uuid);
CREATE UNIQUE INDEX IF NOT EXISTS ux_vehicle_uuid ON vehicle(vehicle_uuid);
CREATE UNIQUE INDEX IF NOT EXISTS ux_chat_text_uuid ON chat_text(chat_text_uuid);
-- Idempotency / provider uniqueness
CREATE UNIQUE INDEX IF NOT EXISTS ux_payment_provider_payment ON payment(payment_provider, provider_payment_id);
CREATE UNIQUE INDEX IF NOT EXISTS ux_webhook_provider_event ON webhook_event(event_provider, provider_event_id);
-- Misc performance indexes
-- idx_booking_provider_payment_id removed (provider_payment_id moved to payment table)