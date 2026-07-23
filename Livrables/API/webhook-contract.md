# Contrat Webhook - Paiements (cadre cible)

Endpoint
- `POST /webhooks/payments`

Sécurité
- La requête doit être authentifiée selon le mécanisme officiel du fournisseur.
- Les noms des headers, le calcul de signature, la tolérance d'horodatage et la gestion des secrets restent à définir après l'étude de Stripe et PayPal.
- Les secrets sont stockés dans un gestionnaire de secrets ou dans la configuration sécurisée de l'environnement, jamais dans le dépôt.

Format interne normalisé
- Chaque adaptateur fournisseur transforme le webhook reçu vers une enveloppe interne commune contenant au minimum :
  - `provider` (string) — fournisseur d'origine
  - `provider_event_id` (string) — identifiant fourni par le fournisseur
  - `event_type` (string) — type métier normalisé
  - `received_at` (ISO 8601) — date de réception par la plateforme
  - `data` (object) — données métier utiles, par exemple réservation, paiement, montant et devise
- Le payload original et les headers utiles peuvent être conservés séparément pour audit technique pendant la durée définie ci-dessous.
- Les noms d'événements et la structure des payloads propres à Stripe et PayPal ne sont pas figés dans ce contrat générique.

Idempotence
- Dédupliquer avec le couple `(provider, provider_event_id)`.
- Un événement déjà traité ne doit pas déclencher une seconde mise à jour métier.
- Conserver l'identifiant et le résultat de traitement pendant au moins 7 jours afin de couvrir les nouvelles tentatives du fournisseur.

Purge et conservation
- Après 7 jours, supprimer ou archiver les données techniques du webhook selon la politique de conservation retenue.
- La purge ne doit pas supprimer les données métier nécessaires à l'historique du paiement ou de la réservation.
- La tâche de purge doit être planifiée, observable et rejouable sans retraiter les événements supprimés.

Retry policy
- Les règles de nouvelle tentative dépendent du fournisseur et seront précisées dans les contrats d'intégration définitifs.
- La plateforme doit répondre rapidement après validation et enregistrement de l'événement, sans exécuter un traitement métier long dans la requête HTTP.

Traitement commun
- Vérifier l'authenticité selon le mécanisme du fournisseur avant tout traitement métier.
- Enregistrer l'événement et son statut de traitement.
- Associer l'événement au paiement ou à la réservation lorsque l'information est disponible.
- Normaliser le résultat vers les statuts internes de paiement et de remboursement.

Réponses
- Répondre avec un succès après validation et enregistrement idempotent de l'événement.
- Utiliser une erreur client pour un payload invalide ou une authentification impossible, selon les règles du fournisseur.
- Utiliser une erreur serveur uniquement lorsqu'une nouvelle tentative est souhaitable.

Étude ultérieure obligatoire
- Étudier les documentations officielles et les versions d'API de Stripe et PayPal avant l'implémentation.
- Choisir le ou les fournisseurs retenus pour la première livraison.
- Définir ensuite, pour chaque fournisseur, les événements pris en charge, les payloads, la vérification de signature, les règles de retry et les codes de réponse.
- Publier enfin les contrats d'intégration définitifs et adapter l'enveloppe interne normalisée si nécessaire.
