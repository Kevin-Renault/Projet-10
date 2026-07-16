# PoC / Proof of Concept — fonctionnalité de tchat

Résumé
-------
Ce dépôt contient la preuve de concept (PoC) requise par la mission : valider la faisabilité d'une option architecturale en implémentant une seule fonctionnalité représentative — le tchat (option B de l'énoncé).

Objectif du PoC
----------------
- Démontrer la viabilité des choix techniques et architecturaux (séparation des composants, API, persistance minimale, gestion des erreurs).
- Fournir un artefact exécutable et reproductible qu'un développeur junior peut lancer localement.
- Rester limité : n'implémentez que la logique nécessaire pour prouver le concept (envoi/ réception de messages, stockage temporaire, API REST ou WebSocket).

Portée (scope)
---------------
- Inclut :
	- un service minimal de tchat (API REST ou WebSocket) permettant d'envoyer et recevoir des messages;
	- une persistance simple (en mémoire ou fichier SQLite) pour montrer le modèle de données;
	- un README clair décrivant l'architecture, les choix techniques et la manière de démarrer la PoC.
- Exclut : authentification complète multi‑pays, interfaces utilisateur riches, scalabilité production, intégration CI/CD complète.

Livrables attendus
-------------------
- Code source minimal dans `PoC/`.
- `README.md` (celui-ci) expliquant : objectifs, structure, dépendances, commandes pour démarrer, et comment valider le bon fonctionnement.
- Un script ou une commande pour démarrer la PoC localement (ex. `docker-compose up`, `npm start`, ou `python -m` selon la stack utilisée).
- Quelques scénarios de test manuels (ex. envoyer un message, récupérer l'historique, gérer message invalide).

Structure recommandée
----------------------
- `PoC/src/` — code source
- `PoC/tests/` — tests unitaires/mini scénarios (optionnel mais recommandé)
- `PoC/docker-compose.yml` — définition de services si besoin
- `PoC/README.md` — instructions et notes (ce fichier)

Critères d'évaluation (checklist)
---------------------------------
- Fonctionnalité : envoi et réception de messages fonctionnels.
- Architecture : composants simples et découplés (API, stockage).
- Lisibilité : code compréhensible et commenté.
- Reproductibilité : instructions claires pour démarrer localement un environnement de test.
- Documentation : README adapté pour un développeur junior.
- Sécurité/bonnes pratiques : pas de secrets en clair, gestion basique des erreurs.
- Accessibilité & accessibilité conceptuelle : si une UI minimale est fournie, respecter les règles d'accessibilité de base (labels, navigation clavier).

Commandes exemples (adapter selon la stack choisie)
--------------------------------------------------
// Node.js
```
npm install
npm start
```

// Python (exemple)
```
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python -m poc.app
```

Validation rapide
------------------
1. Démarrer la PoC avec la commande fournie.
2. Appeler l'API d'envoi de message (ex. POST `/api/messages` ou via WebSocket) et vérifier la réponse.
3. Récupérer l'historique (ex. GET `/api/messages`) et vérifier la persistance minimale.
4. Expliquer dans le README quelles décisions architecturales sont démontrées et pourquoi.

Notes finales
-------------
Gardez le périmètre réduit : l'objectif est de prouver une idée architecturale, pas de produire un produit final. Documentez clairement les limitations et les étapes nécessaires pour industrialiser la solution.

