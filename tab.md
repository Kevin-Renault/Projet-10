Voici le contrôle des éléments explicitement exigés par `enonce.md`, et leur présence dans `CDC.V1.4.md` et dans le modèle SQL.

| Élément exigé par l’énoncé | Bien décrit dans le CDC ? | Présent dans le modèle SQL ? | État |
|---|---|---|---|
| Besoins utilisateurs | Oui | Oui, partiellement | `ycyw_user`, `user_profile`, `agence.city` et `agence_opening_hour` couvrent les informations principales du profil et des agences. Les règles métier et les données applicatives complémentaires restent gérées par l’application. |
| User stories | Oui | Non applicable | Elles sont correctement documentées dans le CDC ; la base n’a pas à contenir les user stories. |
| Critères d’acceptation | Oui | Non applicable | Correct dans le CDC ; ils ne relèvent pas du modèle SQL. |
| Personnes en situation de handicap | Oui | Oui, partiellement | `psh_needs`, `is_psh` et `user_accessibility_pref` existent. Les adaptations restent principalement applicatives. |
| Contraintes d’accessibilité | Oui | Partiellement | Le CDC est détaillé. La base stocke certaines préférences, mais ne peut pas représenter toute l’accessibilité de l’interface. |
| Sécurité | Oui | Partiellement | `password_hash`, `refresh_token`, permissions et `email_verification` existent. Le 2FA a été retiré du périmètre. Le CDC précise désormais l’activation par code, la gestion des sessions, la limitation des tentatives et la protection des secrets ; l’application doit appliquer ces règles. |
| Internationalisation | Oui | Oui, partiellement | `preferred_language`, `timezone` et `currency` existent. Les traductions de l’interface, la langue de repli et le formatage local des dates, heures et montants relèvent de l’application, pas du modèle SQL. |
| Paiement externe | Oui | Oui | `payment`, `webhook_event`, identifiant fournisseur et métadonnées sont présents. |
| Intégration de composants tiers | Oui | Oui, partiellement | Le CDC précise désormais les données nécessaires, la signature et l’idempotence des webhooks, les erreurs, les reprises et la protection des secrets. Le modèle SQL représente le paiement, les webhooks et les comptes de service ; les flux restent principalement applicatifs. |
| API sécurisée pour les agences | Oui | Oui, partiellement | Le CDC définit une API en lecture seule pour le périmètre de la première livraison. `service_account`, scopes et permissions existent ; l’implémentation des endpoints relève de l’application. |
| Impact écologique | Oui | Non applicable | Le CDC et la proposition d’architecture précisent la réduction des données transférées, le cache, l’optimisation des images et le choix raisonné de l’hébergement. Ces pratiques ne sont pas des données métier à stocker en base. |
| Spécifications techniques | Oui | Non applicable | Elles sont décrites dans `Proposition-Architecture.md` et complétées par les contrats OpenAPI/webhook. |
| Diagrammes UML | Oui | Non applicable | Des vues Mermaid de composants et du modèle de données sont présentes dans la proposition d’architecture. |
| Modèle de données | Oui | Oui | Le modèle relationnel est décrit dans la proposition d’architecture et implémenté par les scripts SQL normalisés. |
| Choix technologiques comparés et justifiés | Oui | Non applicable | La proposition compare et justifie Angular, Spring Boot, PostgreSQL, JWT/refresh tokens et le paiement externe. |
| Architecture applicative | Oui | Non applicable | La proposition décrit les composants Angular, Spring Boot, PostgreSQL, les services externes et leurs échanges. |
| PoC tchat | Non | Oui, pour la structure de données | Le CDC mentionne le besoin, mais la preuve doit être démontrée dans la PoC et son README. |
| README développeur junior | Partiellement | Non applicable | `PoC/README.md` existe et présente l'objectif, le périmètre et des principes de validation, mais ses commandes restent génériques et doivent être alignées sur la stack Angular/Spring Boot/PostgreSQL. |
| Structure de données de la PoC | Non | Oui | Les tables `chat`, `chat_participant`, `chat_text`, pièces jointes et accusés de lecture existent. |
