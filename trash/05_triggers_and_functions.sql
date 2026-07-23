-- 06_triggers_and_functions.sql
-- EN: Functions and triggers (updated_at auto-set)
-- FR: Fonctions et triggers (mise à jour automatique de updated_at)
CREATE OR REPLACE FUNCTION set_updated_at_column() RETURNS trigger AS $$ BEGIN NEW.updated_at = now();
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION validate_acriss_vehicle_seats() RETURNS trigger AS $$
DECLARE minimum_required SMALLINT;
BEGIN IF NEW.acriss_code IS NULL THEN RETURN NEW;
END IF;
IF NOT EXISTS (
    SELECT 1
    FROM acriss_category
    WHERE code = substring(
            NEW.acriss_code
            FROM 1 FOR 1
        )
)
OR NOT EXISTS (
    SELECT 1
    FROM acriss_vehicle_type
    WHERE code = substring(
            NEW.acriss_code
            FROM 2 FOR 1
        )
)
OR NOT EXISTS (
    SELECT 1
    FROM acriss_transmission_drive
    WHERE code = substring(
            NEW.acriss_code
            FROM 3 FOR 1
        )
)
OR NOT EXISTS (
    SELECT 1
    FROM acriss_fuel_air_conditioning
    WHERE code = substring(
            NEW.acriss_code
            FROM 4 FOR 1
        )
) THEN RAISE EXCEPTION 'Invalid ACRISS code %',
NEW.acriss_code;
END IF;
IF substring(
    NEW.acriss_code
    FROM 2 FOR 1
) = 'V' THEN
SELECT minimum_seats INTO minimum_required
FROM acriss_passenger_van_rule
WHERE prefix = substring(
        NEW.acriss_code
        FROM 1 FOR 2
    );
IF NEW.seats IS NULL
OR NEW.seats < minimum_required THEN RAISE EXCEPTION 'ACRISS code % requires at least % seats',
NEW.acriss_code,
minimum_required;
END IF;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS trg_validate_acriss_vehicle_seats ON vehicle;
CREATE TRIGGER trg_validate_acriss_vehicle_seats BEFORE
INSERT
    OR
UPDATE OF acriss_code,
    seats ON vehicle FOR EACH ROW EXECUTE PROCEDURE validate_acriss_vehicle_seats();
-- Attach the trigger to tables that have `updated_at` column
DO $$
DECLARE tbl TEXT;
BEGIN FOR tbl IN ARRAY ['vehicle','booking','payment','webhook_event','chat','chat_text','refresh_token'] LOOP EXECUTE format(
    'DROP TRIGGER IF EXISTS trg_set_updated_at_%s ON %s;',
    tbl,
    tbl
);
EXECUTE format(
    'CREATE TRIGGER trg_set_updated_at_%s BEFORE UPDATE ON %s FOR EACH ROW EXECUTE PROCEDURE set_updated_at_column();',
    tbl,
    tbl
);
END LOOP;
END $$;