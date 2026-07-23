-- 1. Remplacez 'ton_mot_de_passe' par un vrai mot de passe fort de votre choix.
-- 2. Exécutez ce script dans PostgreSQL avec un compte administrateur, par exemple postgres.
-- 3. Enregistrez les informations suivantes dans des variables d'environnement côté application Spring Boot :
--    - DB_USER : le nom d'utilisateur PostgreSQL (ex : kevin)
--    - DB_PASSWORD : le mot de passe PostgreSQL choisi (ex : votre_mot_de_passe)
--    - DB_YCYW_NAME : le nom de la base de données (ex : ycyw_db)
--    Sous Windows, deux possibilités pour chaque variable :
--      - Pour la session courante (temporaire) :
--          set DB_USER="kevin"
--          set DB_PASSWORD="votre_mot_de_passe"
--          set DB_YCYW_NAME="ycyw_db"
--      - Pour toutes les futures sessions (persistant) :
--          setx DB_USER "kevin"
--          setx DB_PASSWORD "votre_mot_de_passe"
--          setx DB_YCYW_NAME "ycyw_db"
CREATE DATABASE ycyw_db WITH ENCODING 'UTF8' TEMPLATE template0;
CREATE USER kevin WITH PASSWORD 'UtopiaUtopia@1977';
GRANT CONNECT,
    TEMPORARY ON DATABASE ycyw_db TO kevin;
\ connect ycyw_db
GRANT USAGE,
    CREATE ON SCHEMA public TO kevin;
GRANT SELECT,
    INSERT,
    UPDATE,
    DELETE,
    REFERENCES,
    TRIGGER ON ALL TABLES IN SCHEMA public TO kevin;
GRANT USAGE,
    SELECT,
    UPDATE ON ALL SEQUENCES IN SCHEMA public TO kevin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT,
    INSERT,
    UPDATE,
    DELETE,
    REFERENCES,
    TRIGGER ON TABLES TO kevin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE,
    SELECT,
    UPDATE ON SEQUENCES TO kevin;