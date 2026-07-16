INSTALL.md

EN
-- Run the SQL files in order to create the database schema. Recommended Postgres version: 13+
-- 1) Connect to the target database as a superuser or a role that can create extensions.
-- 2) From this directory run `apply_all.ps1`, which applies the files explicitly in the correct order, including `01_types_enums.sql` then `01_acriss_vehicle.sql` before the core domain.
-- 3) Alternatively, run the individual SQL files in the order listed in `apply_all.ps1`.

FR
-- Exécutez les fichiers SQL dans l'ordre pour créer le schéma. PostgreSQL recommandé : 13+
-- 1) Connectez-vous à la base cible avec un superutilisateur ou un rôle capable de créer des extensions.
-- 2) Depuis ce dossier exécutez `apply_all.ps1`, qui applique explicitement les fichiers dans le bon ordre, notamment `01_types_enums.sql` puis `01_acriss_vehicle.sql` avant le domaine principal.
-- 3) Alternativement, exécutez les fichiers SQL individuellement dans l'ordre indiqué dans `apply_all.ps1`.

Notes:
- `gen_random_uuid()` requires `pgcrypto`.
- If you cannot create extensions, ask your DBA to run step 1, then continue with the rest.
- For production, prefer using migration tools such as Flyway or Liquibase instead of raw SQL files.
