-- 01_types_enums.sql
-- EN: Domain ENUM types used across the schema.
-- FR: Types ENUM du domaine utilisés dans le schéma.
-- ////////////////////////////////////////////////////////////////////////////
-- /// ENUM PART (START) - domain enumerations / value lists
-- ////////////////////////////////////////////////////////////////////////////
CREATE TYPE IF NOT EXISTS psh_need AS ENUM (
    'none',
    'blind',
    'low_vision',
    'hearing_impaired',
    'motor_disability',
    'reduced_mobility',
    'cognitive_impairment'
);
-- Postgres ENUM types for domain fields (converted from MySQL ENUM syntax)
CREATE TYPE IF NOT EXISTS vehicle_status_type AS ENUM (
    'available',
    'reserved',
    'in_service',
    'maintenance'
);
CREATE TYPE IF NOT EXISTS booking_status_type AS ENUM ('pending', 'confirmed', 'cancelled', 'completed');
CREATE TYPE IF NOT EXISTS booking_payment_status_type AS ENUM ('unpaid', 'paid', 'refunded', 'partial');
CREATE TYPE IF NOT EXISTS refund_status_type AS ENUM ('not_refunded', 'pending', 'processed', 'failed');
CREATE TYPE IF NOT EXISTS payment_result_status AS ENUM (
    'initiated',
    'pending',
    'succeeded',
    'failed',
    'refunded'
);
CREATE TYPE IF NOT EXISTS webhook_status_type AS ENUM ('received', 'processing', 'processed', 'failed');
CREATE TYPE IF NOT EXISTS chat_status_type AS ENUM ('open', 'closed', 'archived');
CREATE TYPE IF NOT EXISTS chat_role_type AS ENUM ('client', 'agent', 'system');
CREATE TYPE IF NOT EXISTS chat_content_type AS ENUM ('text', 'system', 'json');
CREATE TYPE IF NOT EXISTS chat_text_status_type AS ENUM ('sent', 'delivered', 'read', 'failed');
-- ////////////////////////////////////////////////////////////////////////////
-- /// ENUM PART (END)
-- ////////////////////////////////////////////////////////////////////////////