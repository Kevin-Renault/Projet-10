# PoC tchat - Your Car Your Way

Cette PoC demontre la faisabilite de l'option B de la mission : un tchat entre un client et un agent. Elle est volontairement limitee au parcours tchat et ne constitue pas l'application complete de reservation.

## Ce qui est demontre

- creation et consultation d'une conversation ;
- envoi et persistance des messages dans PostgreSQL ;
- roles client et agent ;
- prise en charge et liberation d'une conversation par un agent ;
- affichage des conversations en attente, attribuees et cloturees ;
- cloture d'une conversation par le client ;
- blocage de l'envoi apres cloture ;
- mise a jour temps reel avec Server-Sent Events (SSE) ;
- authentification JWT en cookies HttpOnly ;
- rotation et revocation des refresh tokens ;
- protection CSRF des requetes modifiantes ;
- controle des droits cote backend.

## Technologies

| Composant | Technologie |
| --- | --- |
| Frontend | Angular 21.2, TypeScript, RxJS |
| Backend | Java 21, Spring Boot 3.2, Spring MVC |
| Persistance | PostgreSQL, Spring Data JPA/Hibernate |
| Securite | Spring Security, JWT, cookies HttpOnly, CSRF |
| Temps reel | SSE avec `SseEmitter` et `EventSource` |
| Tests frontend | Jest, Karma/Jasmine, Cypress |
| Tests backend | JUnit, Spring Boot Test, Mockito |

## Prerequis

Installer les outils suivants :

- Java 21 ;
- Node.js et npm ;
- PostgreSQL 13 ou une version plus recente ;
- Git, si le projet est clone depuis GitHub.

Verifier les versions :

```powershell
java -version
node --version
npm --version
psql --version
```

## Recuperer le projet

```powershell
git clone https://github.com/Kevin-Renault/Projet-10.git
Set-Location Projet-10\PoC
```

## Configurer PostgreSQL

Creer une base vide, par exemple `ycyw_poc` :

```powershell
createdb -U postgres ycyw_poc
```

Le backend lit les variables suivantes :

| Variable | Exemple | Role |
| --- | --- | --- |
| `DB_YCYW_NAME` | `ycyw_poc` | Nom de la base |
| `DB_USER` | `postgres` | Utilisateur PostgreSQL |
| `DB_PASSWORD` | `mot-de-passe-local` | Mot de passe PostgreSQL |
| `JWT_SECRET` | chaine d'au moins 32 caracteres | Signature des JWT |

Definir ces variables dans le terminal qui lancera le backend. Ne pas les committer dans Git.

```powershell
$env:DB_YCYW_NAME = "ycyw_poc"
$env:DB_USER = "postgres"
$env:DB_PASSWORD = "mot-de-passe-local"
$env:JWT_SECRET = "cle-locale-de-developpement-d-au-moins-32-caracteres"
```

Au demarrage, Spring execute les scripts SQL de `back/src/main/resources` dans l'ordre. Ils creent le schema et les comptes de demonstration. Pour appliquer le schema manuellement, voir [Livrables/Database/INSTALL.md](../Livrables/Database/INSTALL.md).

## Demarrer le backend

Depuis un terminal PowerShell, avec les variables precedentes definies :

```powershell
Set-Location PoC\back
.\mvnw.cmd spring-boot:run
```

Le backend est disponible sur `http://localhost:8080`.

## Installer et demarrer le frontend

Dans un second terminal :

```powershell
Set-Location PoC\front
npm ci
npm start -- --configuration normal
```

La configuration `normal` utilise le vrai backend via [proxy.conf.json](front/proxy.conf.json). Ouvrir ensuite `http://localhost:4200`.

Attention : `npm start` sans configuration utilise `environment.dev.ts`, qui active les services mock. Ce mode est utile pour le developpement visuel mais ne valide pas la persistance PostgreSQL ni les SSE du backend.

## Comptes de demonstration

Les comptes sont crees par `09_person_seed.sql` au premier demarrage du backend :

| Role | Identifiant | Mot de passe |
| --- | --- | --- |
| Agent | `agent_01@gmail.com` | `Agent_01@MDP` |
| Agent | `agent_02@gmail.com` | `Agent_02@MDP` |
| Client | `client_01@gmail.com` | `Client_01@MDP` |
| Client | `client_02@gmail.com` | `Client_02@MDP` |
| Client | `client_03@gmail.com` | `Client_03@MDP` |

Ces comptes sont strictement destines a la demonstration locale.

## Parcours de validation manuelle

### Parcours client/agent

1. Se connecter avec `client_01@gmail.com`.
2. Creer une conversation depuis `Nouveau chat`.
3. Ouvrir la conversation et envoyer un message.
4. Ouvrir une seconde fenetre privee et se connecter avec `agent_01@gmail.com`.
5. Verifier que la conversation apparait dans `En attente` ou `Tous`.
6. Cliquer sur `Prendre` et verifier le passage a `Attribue`.
7. Depuis le client, envoyer un nouveau message et verifier sa reception dans la conversation agent.
8. Depuis le client, cliquer sur `Cloturer`.
9. Verifier que l'agent revient a la liste apres l'evenement SSE.
10. Verifier que la conversation apparait dans `Cloturees`, sans bouton d'action.
11. Verifier qu'aucun nouveau message ne peut etre envoye apres cloture.

### Parcours liberation

1. Depuis une conversation attribuee, l'agent clique sur `Libérer`.
2. Verifier le statut `Sans agent`.
3. Verifier que la conversation revient dans `En attente` et peut etre reprise.

## API du tchat

Les routes sont exposees sous `/api/chats` :

| Methode | Route | Utilisation |
| --- | --- | --- |
| `POST` | `/api/chats` | Creer une conversation |
| `GET` | `/api/chats` | Lister les conversations du client |
| `GET` | `/api/chats/agent-view?filter=all` | Vue agent filtree |
| `GET` | `/api/chats/{id}` | Consulter une conversation |
| `POST` | `/api/chats/{id}/claim` | Prendre une conversation |
| `POST` | `/api/chats/{id}/release` | Liberer une conversation |
| `POST` | `/api/chats/{id}/close` | Cloturer cote client |
| `GET` | `/api/chats/{id}/messages` | Lire les messages |
| `POST` | `/api/chats/{id}/messages` | Envoyer un message |
| `GET` | `/api/chats/{id}/events` | Flux SSE d'une conversation |
| `GET` | `/api/chats/agent-events` | Flux SSE du dashboard agent |

Les requetes modifiantes utilisent les cookies d'authentification et le jeton CSRF gere par le frontend.

## Tests et build

### Frontend

Depuis `PoC/front` :

```powershell
npm run build
npm run test:unit:ci
npm run cypress:run
```

### Backend

Depuis `PoC/back`, avec les variables PostgreSQL definies :

```powershell
.\mvnw.cmd test
.\mvnw.cmd verify
```

Les tests Cypress existants couvrent principalement l'authentification et des parcours historiques. Le parcours tchat doit donc egalement etre valide manuellement avec le scenario ci-dessus.

## Structure détaillée du projet

Le dépôt contient les livrables du projet ainsi qu'une preuve de concept complète du parcours de tchat.

```text
Projet-10/
│
├── PoC/
│   ├── README.md
│   │   └── Guide d'installation, de démarrage et de validation manuelle
│   │
│   ├── back/
│   │   ├── pom.xml
│   │   │   └── Dépendances Maven et configuration du projet Spring Boot
│   │   │
│   │   ├── mvnw
│   │   ├── mvnw.cmd
│   │   │   └── Wrappers Maven pour Linux/macOS et Windows
│   │   │
│   │   └── src/
│   │       ├── main/
│   │       │   ├── java/
│   │       │   │   └── .../
│   │       │   │       ├── Application.java
│   │       │   │       │   └── Point d'entrée de l'application Spring Boot
│   │       │   │       │
│   │       │   │       ├── config/
│   │       │   │       │   ├── Configuration Spring et Spring Security
│   │       │   │       │   ├── Configuration CORS
│   │       │   │       │   ├── Configuration CSRF
│   │       │   │       │   └── Configuration des cookies et des flux SSE
│   │       │   │       │
│   │       │   │       ├── controller/
│   │       │   │       │   ├── Contrôleurs REST d'authentification
│   │       │   │       │   ├── Contrôleurs REST des conversations
│   │       │   │       │   ├── Contrôleurs REST des messages
│   │       │   │       │   └── Contrôleurs des flux Server-Sent Events
│   │       │   │       │
│   │       │   │       ├── service/
│   │       │   │       │   ├── Gestion des utilisateurs
│   │       │   │       │   ├── Création et consultation des conversations
│   │       │   │       │   ├── Envoi et lecture des messages
│   │       │   │       │   ├── Prise en charge et libération des conversations
│   │       │   │       │   ├── Clôture des conversations
│   │       │   │       │   ├── Gestion des événements SSE
│   │       │   │       │   └── Création, rotation et révocation des refresh tokens
│   │       │   │       │
│   │       │   │       ├── repository/
│   │       │   │       │   ├── Accès aux utilisateurs
│   │       │   │       │   ├── Accès aux conversations
│   │       │   │       │   ├── Accès aux messages
│   │       │   │       │   └── Accès aux refresh tokens
│   │       │   │       │
│   │       │   │       ├── entity/
│   │       │   │       │   ├── Entité utilisateur
│   │       │   │       │   ├── Entité conversation
│   │       │   │       │   ├── Entité message
│   │       │   │       │   └── Entité refresh token
│   │       │   │       │
│   │       │   │       ├── dto/
│   │       │   │       │   ├── Objets de requête d'authentification
│   │       │   │       │   ├── Objets de réponse d'authentification
│   │       │   │       │   ├── Objets de conversation
│   │       │   │       │   ├── Objets de message
│   │       │   │       │   └── Objets utilisés par les événements SSE
│   │       │   │       │
│   │       │   │       ├── security/
│   │       │   │       │   ├── Génération et validation des JWT
│   │       │   │       │   ├── Filtre d'authentification JWT
│   │       │   │       │   ├── Gestion des cookies HttpOnly
│   │       │   │       │   ├── Gestion des refresh tokens
│   │       │   │       │   └── Contrôle des rôles et des droits d'accès
│   │       │   │       │
│   │       │   │       ├── exception/
│   │       │   │       │   ├── Exceptions métier
│   │       │   │       │   ├── Gestion des erreurs REST
│   │       │   │       │   └── Réponses d'erreur standardisées
│   │       │   │       │
│   │       │   │       └── sse/
│   │       │   │           ├── Gestion des connexions SSE
│   │       │   │           ├── Gestion des émetteurs SseEmitter
│   │       │   │           ├── Diffusion des nouveaux messages
│   │       │   │           └── Notification des changements d'état
│   │       │   │
│   │       │   └── resources/
│   │       │       ├── application.properties
│   │       │       │   └── Configuration générale de l'API et de la base de données
│   │       │       │
│   │       │       ├── application-test.properties
│   │       │       │   └── Configuration utilisée pendant les tests
│   │       │       │
│   │       │       └── db/
│   │       │           └── migration/
│   │       │               ├── Scripts de création des tables
│   │       │               ├── Scripts de création des contraintes et index
│   │       │               ├── Scripts de création des rôles applicatifs
│   │       │               └── 09_person_seed.sql
│   │       │                   └── Comptes de démonstration client et agent
│   │       │
│   │       └── test/
│   │           ├── java/
│   │           │   ├── Tests unitaires des services
│   │           │   ├── Tests des contrôleurs REST
│   │           │   ├── Tests de sécurité
│   │           │   ├── Tests des règles d'accès
│   │           │   └── Tests d'intégration Spring Boot
│   │           │
│   │           └── resources/
│   │               └── Configuration et données utilisées par les tests
│   │
│   └── front/
│       ├── package.json
│       │   └── Dépendances npm et scripts de développement, de test et de build
│       │
│       ├── package-lock.json
│       │   └── Versions exactes des dépendances npm
│       │
│       ├── angular.json
│       │   └── Configuration du workspace Angular
│       │
│       ├── tsconfig.json
│       ├── tsconfig.app.json
│       ├── tsconfig.spec.json
│       │   └── Configuration TypeScript de l'application et des tests
│       │
│       ├── proxy.conf.json
│       │   └── Redirection des appels frontend vers l'API Spring Boot
│       │
│       ├── cypress.config.ts
│       │   └── Configuration des tests end-to-end Cypress
│       │
│       └── src/
│           ├── index.html
│           │   └── Page HTML principale
│           │
│           ├── main.ts
│           │   └── Point d'entrée de l'application Angular
│           │
│           ├── styles.scss
│           │   └── Styles globaux de l'application
│           │
│           ├── environments/
│           │   ├── environment.dev.ts
│           │   │   └── Configuration du mode de développement avec services mock
│           │   │
│           │   └── environment.normal.ts
│           │       └── Configuration utilisant le véritable backend
│           │
│           ├── app/
│           │   ├── app.component.*
│           │   │   └── Composant racine de l'application
│           │   │
│           │   ├── app.config.ts
│           │   │   └── Configuration des providers Angular
│           │   │
│           │   ├── app.routes.ts
│           │   │   └── Déclaration des routes de l'application
│           │   │
│           │   ├── core/
│           │   │   ├── guards/
│           │   │   │   └── Protection des routes nécessitant une authentification
│           │   │   │
│           │   │   ├── interceptors/
│           │   │   │   ├── Ajout des credentials aux requêtes HTTP
│           │   │   │   ├── Gestion des erreurs d'authentification
│           │   │   │   └── Gestion du jeton CSRF
│           │   │   │
│           │   │   ├── services/
│           │   │   │   ├── Service d'authentification
│           │   │   │   ├── Service de gestion des conversations
│           │   │   │   ├── Service de gestion des messages
│           │   │   │   ├── Service SSE
│           │   │   │   └── Service de gestion de l'état utilisateur
│           │   │   │
│           │   │   └── models/
│           │   │       ├── Modèles utilisateur et rôle
│           │   │       ├── Modèles conversation et statut
│           │   │       ├── Modèle message
│           │   │       └── Modèles de réponse de l'API
│           │   │
│           │   ├── features/
│           │   │   ├── auth/
│           │   │   │   ├── Page de connexion
│           │   │   │   ├── Gestion de la session
│           │   │   │   └── Déconnexion
│           │   │   │
│           │   │   ├── client/
│           │   │   │   ├── Liste des conversations du client
│           │   │   │   ├── Création d'une conversation
│           │   │   │   ├── Consultation d'une conversation
│           │   │   │   ├── Envoi de messages
│           │   │   │   └── Clôture d'une conversation
│           │   │   │
│           │   │   └── agent/
│           │   │       ├── Tableau de bord agent
│           │   │       ├── Filtres des conversations
│           │   │       ├── Prise en charge d'une conversation
│           │   │       ├── Libération d'une conversation
│           │   │       ├── Consultation des messages
│           │   │       └── Réception des mises à jour SSE
│           │   │
│           │   ├── shared/
│           │   │   ├── components/
│           │   │   │   ├── En-tête et navigation
│           │   │   │   ├── Affichage d'un message
│           │   │   │   ├── Liste de conversations
│           │   │   │   ├── Indicateurs de statut
│           │   │   │   └── Boutons et composants communs
│           │   │   │
│           │   │   ├── pipes/
│           │   │   │   └── Formatage des dates, statuts et libellés
│           │   │   │
│           │   │   └── validators/
│           │   │       └── Validateurs des formulaires
│           │   │
│           │   └── mocks/
│           │       ├── Données de démonstration
│           │       ├── Services mock
│           │       └── Réponses simulées de l'API
│           │
│           ├── assets/
│           │   ├── images/
│           │   ├── icônes/
│           │   └── ressources statiques
│           │
│           └── tests/
│               ├── Tests unitaires Jest/Karma
│               └── Tests end-to-end Cypress
│
├── Livrables/
│   ├── Database/
│   │   ├── INSTALL.md
│   │   │   └── Installation et initialisation de la base PostgreSQL
│   │   └── Scripts SQL et documentation du modèle de données
│   │
│   ├── Architecture/
│   │   └── Documents décrivant l'architecture cible et les choix techniques
│   │
│   ├── Conception/
│   │   └── Documents fonctionnels, techniques et diagrammes
│   │
│   └── .../
│       └── Autres documents nécessaires à la présentation du projet
│
└── .gitignore
    └── Fichiers exclus du dépôt : variables d'environnement, dépendances,
        fichiers générés et configurations locales
```

### Organisation du backend

Le backend est organisé selon une séparation entre :

- les contrôleurs, qui exposent l'API HTTP ;
- les services, qui contiennent les règles métier ;
- les repositories, qui communiquent avec PostgreSQL ;
- les entités, qui représentent les tables de la base ;
- les DTO, qui définissent les données échangées avec le frontend ;
- la couche de sécurité, qui gère les JWT, les cookies HttpOnly, les refresh tokens, les rôles et la protection CSRF ;
- la couche SSE, qui diffuse les changements en temps réel aux clients connectés.

Les règles d'accès sont contrôlées côté backend. Le frontend masque certaines actions selon le rôle de l'utilisateur, mais cette restriction d'affichage ne remplace pas les contrôles réalisés par l'API.

### Organisation du frontend

Le frontend Angular est divisé en plusieurs niveaux :

- `core/` contient les services et mécanismes globaux de l'application ;
- `features/` contient les fonctionnalités métier, séparées entre les parcours client, agent et authentification ;
- `shared/` contient les composants réutilisables ;
- `mocks/` permet de lancer l'interface sans backend ni base PostgreSQL ;
- `environments/` contient les configurations propres aux différents modes de lancement ;
- `tests/` regroupe les tests unitaires et end-to-end.

### Modes de fonctionnement du frontend

Deux modes principaux sont disponibles :

- **Mode développement** : utilise `environment.dev.ts` et les services mock. Il permet de travailler sur l'interface sans démarrer PostgreSQL ni le backend.
- **Mode normal** : utilise `environment.normal.ts`, le proxy Angular et le véritable backend Spring Boot. Il permet de valider l'authentification, la persistance PostgreSQL, les droits d'accès et les événements SSE.

### Flux principal d'une fonctionnalité de tchat

Pour une action telle que l'envoi d'un message, le traitement suit généralement ce chemin :

1. Le composant Angular collecte la saisie de l'utilisateur.
2. Le service frontend envoie une requête HTTP à l'API.
3. Les intercepteurs ajoutent les informations nécessaires à la requête, notamment les cookies et le jeton CSRF.
4. Le contrôleur Spring reçoit la requête.
5. Le service backend vérifie l'utilisateur, son rôle et ses droits sur la conversation.
6. Le message est enregistré en base via le repository.
7. Le backend publie un événement SSE.
8. Les clients connectés mettent à jour leur interface sans rechargement de page.

### Flux des données

```text
Utilisateur
    │
    ▼
Composant Angular
    │
    ▼
Service frontend
    │
    ▼
Intercepteurs HTTP
    │
    ▼
API REST Spring Boot
    │
    ├── Contrôle de sécurité et des droits
    ├── Validation des données
    ├── Application des règles métier
    ├── Persistance PostgreSQL
    └── Publication d'un événement SSE
            │
            ▼
       Interfaces client et agent
```

Cette organisation permet de conserver une séparation claire entre l'interface, la logique métier, la sécurité, la persistance et la communication temps réel.
```

Les documents d'architecture et de conception se trouvent dans `Livrables/`.

## Limites de la PoC

Cette PoC ne met pas en oeuvre les composants d'industrialisation de l'architecture cible, notamment Redis, RabbitMQ, Kubernetes, observabilite complete, paiement et CI/CD de production. Ils sont decrits dans les livrables d'architecture mais restent hors du perimetre de cette demonstration ciblee sur le tchat.

Pour une mise en production, il faudrait notamment ajouter des migrations versionnees, une gestion de secrets, une supervision des flux SSE, une strategie de scalabilite et des tests E2E specialises sur le tchat.
