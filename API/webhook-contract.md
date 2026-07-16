# Contrat Webhook - Paiements (ébauche)

Endpoint
- `POST /webhooks/payments`

Sécurité
- Header `X-WC-Timestamp`: unix timestamp (seconds)
- Header `X-WC-Signature`: `t=<timestamp>,v1=<hex(HMAC-SHA256(secret, timestamp + '.' + payload))>`
- Secret partagé configuré en variable d'environnement.

Payload
- JSON contenant au minimum :
  - `event_id` (string) — identifiant unique de l'événement
  - `type` (string) — ex: `payment_intent.succeeded`
  - `data` (object) — détails (reservationId, amount, currency)

Idempotence
- Conserver `event_id` traité pendant 7 jours.

Retry policy
- Fournisseur doit renvoyer l'événement jusqu'à 3 tentatives si réponse ≠ 200 (backoff exponentiel: 1m, 5m, 30m).

Validation
- Vérifier timestamp (tolérance ±5 minutes).
- Vérifier signature HMAC.

Actions
- ACK (200) -> marquer comme traité.
- NACK (4xx) -> ne pas réessayer (erreur du payload).
- 5xx -> accepter réessais du fournisseur.
