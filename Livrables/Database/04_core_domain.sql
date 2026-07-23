-- 04_core_domain.sql
-- SAFE DROP BLOCK
-- Drop dependent views and tables in an order that respects FK dependencies
-- Run this block first to clean the schema before (re)creating objects below.
DROP VIEW IF EXISTS vehicle_acriss_details CASCADE;
DROP TABLE IF EXISTS vehicle_feature CASCADE;
DROP TABLE IF EXISTS vehicle_photo CASCADE;
DROP TABLE IF EXISTS payment_metadata CASCADE;
DROP TABLE IF EXISTS webhook_event_payload CASCADE;
DROP TABLE IF EXISTS webhook_event_header CASCADE;
DROP TABLE IF EXISTS webhook_event CASCADE;
DROP TABLE IF EXISTS payment CASCADE;
DROP TABLE IF EXISTS booking CASCADE;
DROP TABLE IF EXISTS offer CASCADE;
DROP TABLE IF EXISTS vehicle_feature_catalog CASCADE;
DROP TABLE IF EXISTS vehicle CASCADE;
DROP TABLE IF EXISTS refund_policy CASCADE;
DROP TABLE IF EXISTS currency CASCADE;
-- EN: Core domain objects: agencies, vehicles, bookings, payments, webhooks.
-- FR: Domaine principal : agences, véhicules, réservations, paiements, webhooks.
-- VEHICLES
-- ////////////////////////////////////////////////////////////////////////////
CREATE TABLE IF NOT EXISTS vehicle (
    id BIGSERIAL PRIMARY KEY,
    vehicle_uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    reference VARCHAR(100) NULL,
    make VARCHAR(100) NULL,
    model VARCHAR(100) NULL,
    variant VARCHAR(100) NULL,
    year SMALLINT NULL,
    acriss_code CHAR(4) NULL,
    seats SMALLINT NULL CHECK (
        seats IS NULL
        OR seats > 0
    ),
    mileage BIGINT NULL,
    registration_number VARCHAR(50) NULL,
    UNIQUE (registration_number),
    owner_agence_id BIGINT NULL,
    current_agence_id BIGINT NULL,
    vehicle_status vehicle_status_type NOT NULL DEFAULT 'available',
    created_by BIGINT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    CHECK (
        acriss_code IS NULL
        OR acriss_code ~ '^[A-Z0-9]{4}$'
    ),
    FOREIGN KEY (owner_agence_id) REFERENCES agence(id) ON DELETE
    SET NULL,
        FOREIGN KEY (current_agence_id) REFERENCES agence(id) ON DELETE
    SET NULL,
        FOREIGN KEY (created_by) REFERENCES ycyw_user(id) ON DELETE
    SET NULL
);
CREATE OR REPLACE VIEW vehicle_acriss_details AS
SELECT v.id AS vehicle_id,
    v.acriss_code,
    c.label AS category_label,
    t.label AS vehicle_type_label,
    td.label AS transmission_drive_label,
    f.label AS fuel_air_conditioning_label,
    p.description AS passenger_van_description
FROM vehicle v
    LEFT JOIN acriss_category c ON c.code = substring(
        v.acriss_code
        FROM 1 FOR 1
    )
    LEFT JOIN acriss_vehicle_type t ON t.code = substring(
        v.acriss_code
        FROM 2 FOR 1
    )
    LEFT JOIN acriss_transmission_drive td ON td.code = substring(
        v.acriss_code
        FROM 3 FOR 1
    )
    LEFT JOIN acriss_fuel_air_conditioning f ON f.code = substring(
        v.acriss_code
        FROM 4 FOR 1
    )
    LEFT JOIN acriss_passenger_van_rule p ON p.prefix = substring(
        v.acriss_code
        FROM 1 FOR 2
    )
    AND substring(
        v.acriss_code
        FROM 2 FOR 1
    ) = 'V';
-- Indexes for vehicles
CREATE INDEX IF NOT EXISTS idx_vehicle_current_agence ON vehicle(current_agence_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_status ON vehicle(vehicle_status);
CREATE INDEX IF NOT EXISTS idx_vehicle_owner_agence ON vehicle(owner_agence_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_make_model_acriss ON vehicle(make, model, acriss_code);
CREATE INDEX IF NOT EXISTS idx_vehicle_acriss_code ON vehicle(acriss_code);
CREATE INDEX IF NOT EXISTS idx_vehicle_created_by ON vehicle(created_by);
CREATE TABLE IF NOT EXISTS vehicle_feature_catalog (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    label VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS vehicle_feature (
    vehicle_id BIGINT NOT NULL,
    feature_id BIGINT NOT NULL,
    PRIMARY KEY (vehicle_id, feature_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicle(id) ON DELETE CASCADE,
    FOREIGN KEY (feature_id) REFERENCES vehicle_feature_catalog(id) ON DELETE RESTRICT
);
CREATE INDEX IF NOT EXISTS idx_vehicle_feature_feature ON vehicle_feature(feature_id);
CREATE TABLE IF NOT EXISTS vehicle_photo (
    id BIGSERIAL PRIMARY KEY,
    vehicle_id BIGINT NOT NULL,
    url TEXT NOT NULL,
    alt_text VARCHAR(255) NULL,
    display_order SMALLINT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (vehicle_id, display_order),
    FOREIGN KEY (vehicle_id) REFERENCES vehicle(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_vehicle_photo_vehicle ON vehicle_photo(vehicle_id);
-- Offer (tariff) per agency for a vehicle: allows same vehicle to have different prices per agency
CREATE TABLE IF NOT EXISTS offer (
    id BIGSERIAL PRIMARY KEY,
    offer_uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    vehicle_id BIGINT NOT NULL,
    agence_id BIGINT NOT NULL,
    daily_price DECIMAL(10, 2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'EUR',
    available_from TIMESTAMPTZ NULL,
    available_to TIMESTAMPTZ NULL,
    min_rental_days SMALLINT NULL,
    max_rental_days SMALLINT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    CHECK (daily_price > 0),
    CHECK (
        available_from IS NULL
        OR available_to IS NULL
        OR available_from < available_to
    ),
    CHECK (
        min_rental_days IS NULL
        OR min_rental_days > 0
    ),
    CHECK (
        max_rental_days IS NULL
        OR max_rental_days > 0
    ),
    CHECK (
        min_rental_days IS NULL
        OR max_rental_days IS NULL
        OR min_rental_days <= max_rental_days
    ),
    FOREIGN KEY (vehicle_id) REFERENCES vehicle(id) ON DELETE CASCADE,
    FOREIGN KEY (agence_id) REFERENCES agence(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_offer_vehicle ON offer(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_offer_agence ON offer(agence_id);
-- BOOKINGS
-- ////////////////////////////////////////////////////////////////////////////
CREATE TABLE IF NOT EXISTS booking (
    id BIGSERIAL PRIMARY KEY,
    booking_uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    booking_ref VARCHAR(100) NULL,
    user_id BIGINT NOT NULL,
    pickup_agence_id BIGINT NULL,
    return_agence_id BIGINT NULL,
    start_at TIMESTAMPTZ NOT NULL,
    end_at TIMESTAMPTZ NOT NULL,
    booking_status booking_status_type NOT NULL DEFAULT 'pending',
    total_amount DECIMAL(10, 2) NULL,
    currency CHAR(3) NOT NULL DEFAULT 'EUR',
    payment_status booking_payment_status_type DEFAULT 'unpaid',
    refund_amount DECIMAL(10, 2) NULL,
    payment_method VARCHAR(50) DEFAULT 'paypal',
    refund_status refund_status_type DEFAULT 'not_refunded',
    refund_processed_at TIMESTAMPTZ NULL,
    refund_policy_id BIGINT NULL,
    offer_id BIGINT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    cancelled_at TIMESTAMPTZ NULL,
    cancellation_reason TEXT NULL,
    CHECK (start_at < end_at),
    CHECK (
        total_amount IS NULL
        OR total_amount >= 0
    ),
    CHECK (
        refund_amount IS NULL
        OR refund_amount >= 0
    ),
    CHECK (
        refund_amount IS NULL
        OR total_amount IS NULL
        OR refund_amount <= total_amount
    ),
    FOREIGN KEY (user_id) REFERENCES ycyw_user(id) ON DELETE CASCADE,
    FOREIGN KEY (offer_id) REFERENCES offer(id) ON DELETE RESTRICT,
    FOREIGN KEY (pickup_agence_id) REFERENCES agence(id) ON DELETE
    SET NULL,
        FOREIGN KEY (return_agence_id) REFERENCES agence(id) ON DELETE
    SET NULL
);
-- Booking indexes
CREATE INDEX IF NOT EXISTS idx_booking_user ON booking(user_id);
CREATE INDEX IF NOT EXISTS idx_booking_status ON booking(booking_status);
-- idx_booking_provider_payment_id removed (provider_payment_id removed from booking)
CREATE INDEX IF NOT EXISTS idx_booking_start_end ON booking(start_at, end_at);
CREATE INDEX IF NOT EXISTS idx_booking_pickup_return ON booking(pickup_agence_id, return_agence_id);
CREATE INDEX IF NOT EXISTS idx_booking_created_at ON booking(created_at);
-- PAYMENTS
-- ////////////////////////////////////////////////////////////////////////////
CREATE TABLE IF NOT EXISTS payment (
    id BIGSERIAL PRIMARY KEY,
    payment_ref VARCHAR(100) NULL,
    booking_id BIGINT NULL,
    user_id BIGINT NULL,
    payment_provider VARCHAR(50) NOT NULL,
    provider_payment_id VARCHAR(255) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'EUR',
    payment_status payment_result_status NOT NULL DEFAULT 'initiated',
    method VARCHAR(50) NULL,
    -- metadata moved to `payment_metadata` (strict 1NF)
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    CHECK (amount > 0),
    UNIQUE (payment_provider, provider_payment_id),
    FOREIGN KEY (booking_id) REFERENCES booking(id) ON DELETE
    SET NULL,
        FOREIGN KEY (user_id) REFERENCES ycyw_user(id) ON DELETE
    SET NULL
);
CREATE INDEX IF NOT EXISTS idx_payment_booking ON payment(booking_id);
CREATE INDEX IF NOT EXISTS idx_payment_user ON payment(user_id);
CREATE INDEX IF NOT EXISTS idx_payment_provider ON payment(payment_provider);
-- Payment metadata normalized into key/value table (strict 1NF)
CREATE TABLE IF NOT EXISTS payment_metadata (
    id BIGSERIAL PRIMARY KEY,
    payment_id BIGINT NOT NULL,
    meta_key VARCHAR(255) NOT NULL,
    meta_value TEXT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    FOREIGN KEY (payment_id) REFERENCES payment(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_payment_metadata_payment ON payment_metadata(payment_id);
-- Refund policy reference table (3NF)
CREATE TABLE IF NOT EXISTS refund_policy (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    label VARCHAR(255) NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_refund_policy_code ON refund_policy(code);
-- Currency reference table (3NF)
CREATE TABLE IF NOT EXISTS currency (
    code CHAR(3) PRIMARY KEY,
    name VARCHAR(100) NULL
);
-- Enforce currency codes on offers/booking/payment
ALTER TABLE offer
ADD CONSTRAINT fk_offer_currency FOREIGN KEY (currency) REFERENCES currency(code);
ALTER TABLE booking
ADD CONSTRAINT fk_booking_currency FOREIGN KEY (currency) REFERENCES currency(code);
ALTER TABLE payment
ADD CONSTRAINT fk_payment_currency FOREIGN KEY (currency) REFERENCES currency(code);
-- Link booking to refund_policy
ALTER TABLE booking
ADD CONSTRAINT fk_booking_refund_policy FOREIGN KEY (refund_policy_id) REFERENCES refund_policy(id) ON DELETE
SET NULL;
-- WEBHOOK EVENTS
-- ////////////////////////////////////////////////////////////////////////////
CREATE TABLE IF NOT EXISTS webhook_event (
    id BIGSERIAL PRIMARY KEY,
    event_provider VARCHAR(50) NOT NULL,
    provider_event_id VARCHAR(255) NOT NULL,
    event_type VARCHAR(100) NULL,
    -- payload and headers moved to `webhook_event_payload` / `webhook_event_header`
    received_at TIMESTAMPTZ DEFAULT now(),
    processed_at TIMESTAMPTZ NULL,
    event_status webhook_status_type DEFAULT 'received',
    attempt_count INT DEFAULT 0,
    related_booking_id BIGINT NULL,
    related_payment_id BIGINT NULL,
    UNIQUE (event_provider, provider_event_id),
    FOREIGN KEY (related_booking_id) REFERENCES booking(id) ON DELETE
    SET NULL,
        FOREIGN KEY (related_payment_id) REFERENCES payment(id) ON DELETE
    SET NULL
);
CREATE INDEX IF NOT EXISTS idx_webhook_provider ON webhook_event(event_provider);
CREATE INDEX IF NOT EXISTS idx_webhook_status ON webhook_event(event_status);
-- Webhook payloads and headers normalized into key/value tables (strict 1NF)
CREATE TABLE IF NOT EXISTS webhook_event_payload (
    id BIGSERIAL PRIMARY KEY,
    webhook_event_id BIGINT NOT NULL,
    payload_key VARCHAR(255) NOT NULL,
    payload_value TEXT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    FOREIGN KEY (webhook_event_id) REFERENCES webhook_event(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS webhook_event_header (
    id BIGSERIAL PRIMARY KEY,
    webhook_event_id BIGINT NOT NULL,
    header_key VARCHAR(255) NOT NULL,
    header_value TEXT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    FOREIGN KEY (webhook_event_id) REFERENCES webhook_event(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_webhook_event_payload_event ON webhook_event_payload(webhook_event_id);
CREATE INDEX IF NOT EXISTS idx_webhook_event_header_event ON webhook_event_header(webhook_event_id);