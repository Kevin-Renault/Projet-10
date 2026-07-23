-- ACRISS vehicle classification reference data.
-- The four code positions are validated independently and the passenger-van
-- prefixes are kept as a separate reference for the expanded ACRISS table.
CREATE TABLE IF NOT EXISTS acriss_category (
    code CHAR(1) PRIMARY KEY,
    label VARCHAR(100) NOT NULL
);
CREATE TABLE IF NOT EXISTS acriss_vehicle_type (
    code CHAR(1) PRIMARY KEY,
    label VARCHAR(100) NOT NULL
);
CREATE TABLE IF NOT EXISTS acriss_transmission_drive (
    code CHAR(1) PRIMARY KEY,
    label VARCHAR(150) NOT NULL
);
CREATE TABLE IF NOT EXISTS acriss_fuel_air_conditioning (
    code CHAR(1) PRIMARY KEY,
    label VARCHAR(150) NOT NULL
);
CREATE TABLE IF NOT EXISTS acriss_passenger_van_rule (
    prefix CHAR(2) PRIMARY KEY,
    minimum_seats SMALLINT NOT NULL CHECK (minimum_seats > 0),
    description VARCHAR(255) NOT NULL
);
INSERT INTO acriss_category (code, label)
VALUES ('M', 'Mini'),
    ('N', 'Mini Elite'),
    ('E', 'Economy'),
    ('H', 'Economy Elite'),
    ('C', 'Compact'),
    ('D', 'Compact Elite'),
    ('I', 'Intermediate'),
    ('J', 'Intermediate Elite'),
    ('S', 'Standard'),
    ('R', 'Standard Elite'),
    ('F', 'Fullsize'),
    ('G', 'Fullsize Elite'),
    ('P', 'Premium'),
    ('U', 'Premium Elite'),
    ('L', 'Luxury'),
    ('W', 'Luxury Elite'),
    ('O', 'Oversize'),
    ('X', 'Special') ON CONFLICT (code) DO NOTHING;
INSERT INTO acriss_vehicle_type (code, label)
VALUES ('B', '2-3 Door'),
    ('C', '2/4 Door'),
    ('D', '4-5 Door'),
    ('W', 'Wagon/Estate'),
    ('V', 'Passenger Van'),
    ('L', 'Limousine/Sedan'),
    ('S', 'Sport'),
    ('T', 'Convertible'),
    ('F', 'SUV'),
    ('J', 'Open Air All Terrain'),
    ('X', 'Special'),
    ('P', 'Pick-up single/extended cab 2 door'),
    ('Q', 'Pick-up double cab 4 door'),
    ('Z', 'Special Offer Car'),
    ('E', 'Coupe'),
    ('M', 'Monospace'),
    ('R', 'Recreational Vehicle'),
    ('H', 'Motor Home'),
    ('Y', '2 Wheel Vehicle'),
    ('N', 'Roadster'),
    ('G', 'Crossover'),
    ('K', 'Commercial Van/Truck') ON CONFLICT (code) DO NOTHING;
INSERT INTO acriss_transmission_drive (code, label)
VALUES ('M', 'Manual, unspecified drive'),
    ('N', 'Manual, 4WD'),
    ('C', 'Manual, AWD'),
    ('A', 'Automatic, unspecified drive'),
    ('B', 'Automatic, 4WD'),
    ('D', 'Automatic, AWD'),
    ('Q', 'Level 3 conditional automation'),
    ('H', 'Level 4 high automation'),
    ('F', 'Level 5 full automation') ON CONFLICT (code) DO NOTHING;
INSERT INTO acriss_fuel_air_conditioning (code, label)
VALUES (
        'R',
        'Unspecified fuel/power combustion engine, air conditioning'
    ),
    (
        'N',
        'Unspecified fuel/power combustion engine, no air conditioning'
    ),
    ('D', 'Diesel, air conditioning'),
    ('Q', 'Diesel, no air conditioning'),
    ('H', 'Hybrid'),
    ('I', 'Hybrid plug-in'),
    ('E', 'Electric'),
    ('C', 'Electric'),
    ('L', 'LPG/compressed gas, air conditioning'),
    ('S', 'LPG/compressed gas, no air conditioning'),
    ('A', 'Hydrogen, air conditioning'),
    ('B', 'Hydrogen, no air conditioning'),
    ('M', 'Multi fuel/power, air conditioning'),
    ('F', 'Multi fuel/power, no air conditioning'),
    ('V', 'Petrol, air conditioning'),
    ('Z', 'Petrol, no air conditioning'),
    ('U', 'Ethanol, air conditioning'),
    ('X', 'Ethanol, no air conditioning') ON CONFLICT (code) DO NOTHING;
INSERT INTO acriss_passenger_van_rule (prefix, minimum_seats, description)
VALUES ('IV', 6, '6 or more seats'),
    ('JV', 6, 'Elite 6+ seats or 5+2 seats'),
    ('SV', 7, '7 or more seats'),
    ('RV', 7, 'Elite 7+ seats'),
    ('FV', 7, '7 or more seats with more space'),
    ('GV', 7, 'Elite 7+ seats with more space'),
    ('PV', 8, '8 or more seats'),
    ('UV', 8, 'Elite 8+ seats'),
    ('LV', 9, '9 or more seats'),
    ('WV', 9, 'Elite 9+ seats'),
    ('XV', 12, '12 or more seats'),
    ('OV', 15, '15 or more seats') ON CONFLICT (prefix) DO NOTHING;