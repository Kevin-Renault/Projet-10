-- 09_person_seed.sql
-- Comptes de démonstration pour le POC.
-- Les mots de passe en clair sont uniquement rappelés ici pour les tests locaux.
-- agent_01@gmail.com / Agent_01@MDP
-- agent_02@gmail.com / Agent_02@MDP
-- client_01@gmail.com / Client_01@MDP
-- client_02@gmail.com / Client_02@MDP
-- client_03@gmail.com / Client_03@MDP
INSERT INTO ycyw_user (
        username,
        email,
        password_hash,
        user_role,
        auth_type,
        preferred_language,
        timezone,
        user_status
    )
VALUES (
        'agent_01',
        'agent_01@gmail.com',
        '$2a$10$qkLJioeRWAfcxRzd3uGvuuznvVBaDtWGhxXx7UsEBzX1fLj4rkbSC',
        'agent',
        'password',
        'fr',
        'Europe/Paris',
        'active'
    ),
    (
        'agent_02',
        'agent_02@gmail.com',
        '$2a$10$0E4VJeMxIGNvjL5ysrLHJOZeJKAJf8IuAeNjFVaN7uJL7RgXO9xpu',
        'agent',
        'password',
        'fr',
        'Europe/Paris',
        'active'
    ),
    (
        'client_01',
        'client_01@gmail.com',
        '$2a$10$2uEE5gokdBqE0AmbJiNube92plZqcK6qXgbDxek1A15N4y4VS8rcu',
        'client',
        'password',
        'fr',
        'Europe/Paris',
        'active'
    ),
    (
        'client_02',
        'client_02@gmail.com',
        '$2a$10$fJwePuQcgYnh1UE4/ak/r.50LzzKqXLmz8Q1.C5GEdU021eKdutqm',
        'client',
        'password',
        'fr',
        'Europe/Paris',
        'active'
    ),
    (
        'client_03',
        'client_03@gmail.com',
        '$2a$10$DBBvRXdH16gcygX34p6vTeAkVVk57LLz/2pGr/TxVdPmRZClNybeC',
        'client',
        'password',
        'fr',
        'Europe/Paris',
        'active'
    ) ON CONFLICT (email) DO
UPDATE
SET username = EXCLUDED.username,
    password_hash = EXCLUDED.password_hash,
    user_role = EXCLUDED.user_role,
    auth_type = EXCLUDED.auth_type,
    preferred_language = EXCLUDED.preferred_language,
    timezone = EXCLUDED.timezone,
    user_status = EXCLUDED.user_status;