-- 02_types_enums.sql
-- EN: Domain ENUM types used across the schema.
-- FR: Types ENUM du domaine utilisés dans le schéma.
-- ////////////////////////////////////////////////////////////////////////////
-- /// ENUM PART (START) - domain enumerations / value lists
-- ////////////////////////////////////////////////////////////////////////////
DROP TYPE IF EXISTS psh_need CASCADE;
CREATE TYPE psh_need AS ENUM (
    'none',
    'blind',
    'low_vision',
    'hearing_impaired',
    'motor_disability',
    'reduced_mobility',
    'cognitive_impairment'
);
-- Postgres ENUM types for domain fields (converted from MySQL ENUM syntax)
DROP TYPE IF EXISTS vehicle_status_type CASCADE;
CREATE TYPE vehicle_status_type AS ENUM (
    'available',
    'reserved',
    'in_service',
    'maintenance'
);
DROP TYPE IF EXISTS booking_status_type CASCADE;
CREATE TYPE booking_status_type AS ENUM ('pending', 'confirmed', 'cancelled', 'completed');
DROP TYPE IF EXISTS booking_payment_status_type CASCADE;
CREATE TYPE booking_payment_status_type AS ENUM ('unpaid', 'paid', 'refunded', 'partial');
DROP TYPE IF EXISTS refund_status_type CASCADE;
CREATE TYPE refund_status_type AS ENUM ('not_refunded', 'pending', 'processed', 'failed');
DROP TYPE IF EXISTS payment_result_status CASCADE;
CREATE TYPE payment_result_status AS ENUM (
    'initiated',
    'pending',
    'succeeded',
    'failed',
    'refunded'
);
DROP TYPE IF EXISTS webhook_status_type CASCADE;
CREATE TYPE webhook_status_type AS ENUM ('received', 'processing', 'processed', 'failed');
DROP TYPE IF EXISTS chat_status_type CASCADE;
CREATE TYPE chat_status_type AS ENUM (
    'open',
    'waiting_reassignment',
    'assigned',
    'closed',
    'archived'
);
DROP TYPE IF EXISTS chat_role_type CASCADE;
CREATE TYPE chat_role_type AS ENUM ('client', 'agent', 'system');
DROP TYPE IF EXISTS chat_content_type CASCADE;
CREATE TYPE chat_content_type AS ENUM ('text', 'system', 'json');
DROP TYPE IF EXISTS chat_text_status_type CASCADE;
CREATE TYPE chat_text_status_type AS ENUM ('sent', 'delivered', 'read', 'failed');
-- ////////////////////////////////////////////////////////////////////////////
-- /// ENUM PART (END)
-- ////////////////////////////////////////////////////////////////////////////