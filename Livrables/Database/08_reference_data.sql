-- 08_reference_data.sql
-- SAFE CLEAN BLOCK
-- Truncate reference data before re-inserting to ensure idempotence
TRUNCATE TABLE vehicle_feature_catalog,
currency RESTART IDENTITY CASCADE;
-- EN: Initial reference data for the database.
-- FR: Donnees de reference initiales de la base.
INSERT INTO currency (code, name)
VALUES ('EUR', 'Euro'),
    ('USD', 'US Dollar'),
    ('GBP', 'Pound Sterling'),
    ('CAD', 'Canadian Dollar') ON CONFLICT (code) DO NOTHING;
INSERT INTO vehicle_feature_catalog (code, label)
VALUES ('gps', 'GPS'),
    ('air_conditioning', 'Climatisation'),
    ('child_seat', 'Siege enfant') ON CONFLICT (code) DO NOTHING;