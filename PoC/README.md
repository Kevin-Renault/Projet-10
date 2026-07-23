# PoC tchat - Your Car Your Way

Cette preuve de concept démontre le parcours d'un tchat entre un client et un agent. Elle couvre uniquement la fonctionnalité de tchat et ne constitue pas l'application complète de réservation.

## Périmètre de la PoC

La PoC permet de :

- créer et consulter une conversation ;
- lire et enregistrer des messages dans PostgreSQL ;
- authentifier un client ou un agent ;
- prendre en charge une conversation en attente ;
- libérer une conversation attribuée ;
- afficher les conversations en attente, attribuées ou clôturées ;
- recevoir les nouveaux messages et changements d'état par SSE ;
- clôturer une conversation côté client ;
- bloquer l'envoi de messages après clôture ;
- contrôler les droits d'accès côté backend.

La PoC ne comprend pas le parcours de réservation, le paiement, la gestion complète des véhicules, Redis, RabbitMQ, Kubernetes ou une supervision de production.

## Technologies utilisées

| Composant | Technologie |
| --- | --- |
| Frontend | Angular 21, TypeScript, RxJS |
| Backend | Java 21, Spring Boot 3.2, Spring MVC |
| Base de données | PostgreSQL 13 ou plus récent |
| Persistance | Spring Data JPA et Hibernate |
| Authentification | Spring Security, JWT et cookies HttpOnly |
| Protection des requêtes | CSRF avec cookie et header `X-XSRF-TOKEN` |
| Temps réel | Server-Sent Events avec `SseEmitter` et `EventSource` |
| Tests frontend | Jest, Karma/Jasmine et Cypress |
| Tests backend | JUnit, Spring Boot Test et Mockito |

## Prérequis

Installer :

- Java 21 ;
- Node.js et npm ;
- PostgreSQL 13 ou plus récent ;
- Git.

Vérifier les installations :

```powershell
java -version
node --version
npm --version
psql --version
```

Le backend attend PostgreSQL sur `localhost:5432`. L'utilisateur PostgreSQL doit pouvoir se connecter à la base et, lors de la première installation, créer l'extension `pgcrypto`.

## Récupérer le projet

```powershell
git clone https://github.com/Kevin-Renault/Projet-10.git
Set-Location Projet-10\PoC
```

Si le dépôt est déjà présent, se placer directement dans le dossier `PoC`.

## Initialiser PostgreSQL

Créer une base vide :

```powershell
createdb -U postgres ycyw_poc
```

Le backend lit sa configuration dans les variables d'environnement. Elles doivent être définies avant son démarrage, dans le même environnement que celui qui exécute Maven.

### Développement local uniquement

Pour un test local rapide, définir les variables dans le terminal PowerShell qui lancera le backend :

```powershell
$env:DB_YCYW_NAME = "ycyw_poc"
$env:DB_USER = "postgres"
$env:DB_PASSWORD = "mot-de-passe-local"
$env:JWT_SECRET = "cle-locale-de-developpement-d-au-moins-32-caracteres"
```

Cette méthode est pratique pour le développement local : les variables restent disponibles uniquement dans ce terminal et les processus lancés depuis celui-ci. Elles disparaissent lorsque le terminal est fermé. Ne pas utiliser de mots de passe ou de secrets réels dans ce fichier ou dans un script versionné.

### Environnement persistant hors développement local

Pour une installation persistante sur Windows, définir les variables d'environnement au niveau du système ou du compte utilisateur, puis redémarrer le terminal et les services concernés. Par exemple, depuis un terminal PowerShell ouvert avec les droits nécessaires :

```powershell
[Environment]::SetEnvironmentVariable("DB_YCYW_NAME", "ycyw_poc", "Machine")
[Environment]::SetEnvironmentVariable("DB_USER", "postgres", "Machine")
[Environment]::SetEnvironmentVariable("DB_PASSWORD", "<mot-de-passe-a-fournir-hors-du-depot>", "Machine")
[Environment]::SetEnvironmentVariable("JWT_SECRET", "<secret-a-fournir-hors-du-depot>", "Machine")
```

Le niveau `Machine` concerne tous les utilisateurs et peut nécessiter des droits administrateur. Pour limiter la configuration au compte courant, remplacer `Machine` par `User`.

Dans un environnement de production, ne pas stocker les secrets en clair dans les variables système, un script, le dépôt ou la documentation. Utiliser le gestionnaire de secrets fourni par l'infrastructure de déploiement, puis injecter les valeurs au démarrage de l'application.

Ne pas committer ces valeurs. Le backend utilise aussi, si nécessaire, les variables optionnelles suivantes :

| Variable | Valeur par défaut | Utilisation |
| --- | --- | --- |
| `JWT_EXPIRATION_SECONDS` | `900` | Durée du JWT d'accès |
| `JWT_REFRESH_EXPIRATION_SECONDS` | `2592000` | Durée du refresh token |
| `JWT_COOKIE_NAME` | `access_token` | Nom du cookie JWT |
| `JWT_REFRESH_COOKIE_NAME` | `refresh_token` | Nom du cookie de refresh |
| `JWT_COOKIE_SECURE` | `false` | Cookie HTTPS ou non |
| `JWT_COOKIE_SAMESITE` | `Lax` | Politique SameSite |

### Initialisation automatique par Spring

Au démarrage, Spring exécute les scripts SQL suivants depuis `back/src/main/resources` :

```text
00_extensions_and_settings.sql
01_acriss_vehicle.sql
02_types_enums.sql
03_auth_schema.sql
04_core_domain.sql
05_chat.sql
07_indexes_constraints.sql
08_reference_data.sql
09_person_seed.sql
```

Le script `06_triggers_and_functions.sql` n'est pas exécuté par le séparateur SQL Spring, car il contient des blocs PL/pgSQL. Pour appliquer l'ensemble du schéma, utiliser la procédure documentée dans [Livrables/Database/INSTALL.md](../Livrables/Database/INSTALL.md) et le script `Livrables/Database/apply_all.ps1`.

## Démarrer le backend

Depuis `PoC/back`, après avoir défini les variables PostgreSQL et JWT :

```powershell
Set-Location PoC\back
.\mvnw.cmd spring-boot:run
```

Le backend démarre sur `http://localhost:8080`.

## Démarrer le frontend

Dans un second terminal :

```powershell
Set-Location PoC\front
npm ci
npm start
```

Ouvrir ensuite `http://localhost:4200`.

Le frontend utilise `proxy.conf.json` pour transmettre les appels `/api` vers `http://localhost:8080`. La configuration par défaut utilise `environment.ts` et les services réels.

### Mode mock

Le mode mock permet de tester l'interface sans démarrer PostgreSQL ni le backend :

```powershell
npm start -- --configuration dev
```

Ce mode utilise `environment.dev.ts`, `AuthMockService`, `ChatMockService` et les autres services mock. Il ne valide pas la persistance, l'authentification backend, la protection CSRF ou les SSE réels.

La configuration Angular `normal` utilise également les services réels. Elle ne correspond pas à un fichier `environment.normal.ts` : ce fichier n'existe pas dans la PoC.

## Comptes de démonstration

Les comptes sont créés par `09_person_seed.sql` :

| Role | Identifiant | Mot de passe |
| --- | --- | --- |
| Agent | `agent_01@gmail.com` | `Agent_01@MDP` |
| Agent | `agent_02@gmail.com` | `Agent_02@MDP` |
| Client | `client_01@gmail.com` | `Client_01@MDP` |
| Client | `client_02@gmail.com` | `Client_02@MDP` |
| Client | `client_03@gmail.com` | `Client_03@MDP` |

Ces comptes sont uniquement destinés à la démonstration locale.

## Statuts d'une conversation

Le backend utilise les valeurs suivantes :

| Valeur API | Libellé dans l'interface | Signification |
| --- | --- | --- |
| `open` | En attente | La conversation peut être prise par un agent |
| `assigned` | Attribuée | Un agent est affecté à la conversation |
| `waiting_reassignment` | Sans agent | L'agent précédent a libéré la conversation |
| `closed` | Clôturée | Le client a terminé la conversation |
| `archived` | Clôturée | Conversation conservée dans l'historique |

Lorsqu'une conversation est `assigned`, le champ `assignedAgentId` contient l'identifiant de l'agent actif. Le bouton `Libérer` apparaît uniquement si cet identifiant correspond à l'agent connecté. Une conversation attribuée à un autre agent n'est pas ouvrable depuis le tableau de bord agent.

## Parcours de validation

### Parcours client et agent

1. Se connecter comme `client_01@gmail.com`.
2. Créer une conversation avec `Nouveau chat`.
3. Ouvrir la conversation et envoyer un premier message.
4. Ouvrir une fenêtre privée et se connecter comme `agent_01@gmail.com`.
5. Ouvrir le filtre `En attente` ou `Tous`.
6. Cliquer sur `Prendre`. La conversation passe à `assigned` et `assignedAgentId` prend l'identifiant de l'agent.
7. Vérifier que le bouton `Libérer` est visible pour cet agent, dans la liste et dans le détail de la conversation.
8. Depuis la fenêtre client, envoyer un nouveau message et vérifier sa réception côté agent.
9. Depuis le client, cliquer sur `Clôturer`.
10. Vérifier que l'agent revient à la liste après l'événement SSE.
11. Vérifier que la conversation apparaît dans `Clôturées` et qu'aucun nouveau message ne peut être envoyé.

### Parcours de libération et de reprise

1. Depuis une conversation attribuée à l'agent connecté, cliquer sur `Libérer`.
2. Vérifier le passage à `waiting_reassignment` et la remise à `null` de `assignedAgentId`.
3. Vérifier que la conversation revient dans `En attente`.
4. Cliquer sur `Prendre` pour vérifier qu'elle peut être reprise.

### Controle des droits

1. Attribuer une conversation à `agent_01@gmail.com`.
2. Se connecter avec `agent_02@gmail.com`.
3. Vérifier que la conversation est visible dans les listes générales, mais qu'elle n'est pas ouvrable.
4. Vérifier que l'agent 2 ne voit pas le bouton `Libérer`.
5. Vérifier qu'un appel direct à l'API de libération est refusé par le backend.

## API du tchat

Les routes du tchat sont exposées sous `/api/chats` :

| Méthode | Route | Utilisation |
| --- | --- | --- |
| `POST` | `/api/chats` | Créer une conversation |
| `GET` | `/api/chats` | Lister les conversations de l'utilisateur |
| `GET` | `/api/chats/open` | Lister les conversations disponibles pour un agent |
| `GET` | `/api/chats/agent-view?filter=all` | Vue agent filtrée |
| `GET` | `/api/chats/{id}` | Consulter une conversation autorisée |
| `POST` | `/api/chats/{id}/claim` | Prendre une conversation |
| `POST` | `/api/chats/{id}/release` | Libérer sa conversation attribuée |
| `POST` | `/api/chats/{id}/close` | Clôturer côté client |
| `GET` | `/api/chats/{id}/participants` | Lister les participants |
| `POST` | `/api/chats/{id}/participants` | Ajouter un participant autorisé |
| `GET` | `/api/chats/{id}/messages` | Lire les messages |
| `POST` | `/api/chats/{id}/messages` | Envoyer un message |
| `GET` | `/api/chats/{id}/events` | Écouter les événements SSE de la conversation |
| `GET` | `/api/chats/agent-events` | Écouter les changements du tableau de bord agent |

Les routes d'authentification utilisées par le frontend sont exposées sous `/api/auth` :

| Méthode | Route | Utilisation |
| --- | --- | --- |
| `GET` | `/api/auth/csrf` | Initialiser le cookie CSRF |
| `POST` | `/api/auth/login` | Ouvrir une session |
| `POST` | `/api/auth/register` | Créer un compte |
| `POST` | `/api/auth/refresh` | Renouveler la session |
| `POST` | `/api/auth/logout` | Fermer la session |
| `GET` | `/api/auth/me` | Récupérer l'utilisateur courant |

Les requêtes modifiantes utilisent les cookies d'authentification et le header CSRF géré par le frontend. Les cookies ne sont pas lus directement par le code Angular.

### Contrat OpenAPI (`openapi.yaml`)

Le fichier [`openapi.yaml`](openapi.yaml) est le contrat versionné de l'API au format OpenAPI 3.0.3. Il décrit les échanges attendus entre le frontend, le backend et les futurs clients ou systèmes tiers :

- les routes, leur méthode HTTP et leur rôle métier dans `paths` ;
- les paramètres de chemin, de requête et les headers ;
- les corps JSON attendus et les réponses possibles ;
- les modèles de données réutilisables dans `components.schemas` ;
- les mécanismes d'authentification dans `components.securitySchemes` ;
- les flux temps réel du tchat avec le type `text/event-stream` pour SSE.

#### Comment lire le fichier

La lecture se fait du général vers le détail :

1. `openapi` indique la version de la norme utilisée ;
2. `info.version` indique la version du contrat, actuellement `1.1.1` ;
3. `servers` indique l'URL de référence de l'API ;
4. chaque clé de `paths` correspond à une route, puis `get`, `post` ou `put` décrit l'opération ;
5. `$ref` réutilise un élément défini dans `components`, par exemple un schéma de réponse ou un paramètre commun ;
6. `security` indique l'authentification nécessaire pour appeler la route :
   - `security: [{ cookieAuth: [] }]` signifie que le cookie JWT `access_token` est requis ;
   - `security: [{ bearerAuth: [] }]` signifie qu'un token JWT doit être envoyé dans le header `Authorization: Bearer ...` ;
   - `security: [{ cookieAuth: [] }, { bearerAuth: [] }]` signifie qu'une des deux méthodes est acceptée ;
   - `security: []` signifie explicitement que la route est publique et ne nécessite pas de connexion. C'est le cas, par exemple, de la connexion et de l'inscription ;
7. `security` concerne l'authentification, tandis que le header `X-XSRF-TOKEN` concerne la protection CSRF. Une requête publique peut donc tout de même demander un token CSRF, comme l'inscription et la connexion ;
8. les requêtes modifiantes utilisent le header `X-XSRF-TOKEN` lorsque le CSRF est requis.

Exemple :

```yaml
/api/auth/login:
    post:
        security: []                 # aucune connexion préalable nécessaire
        parameters:
            - $ref: '#/components/parameters/CsrfHeader'
```

Ici, l'utilisateur n'a pas encore de session, donc la route n'exige ni cookie JWT ni bearer token. En revanche, le header CSRF peut être demandé pour empêcher les requêtes forgées.

Exemple de lecture :

```yaml
/api/chats/{chatId}/messages:
    post:
        requestBody:             # JSON envoyé par le client
            ...
        responses:               # réponses possibles du backend
            '200': ...
```

Le nom `{chatId}` est un paramètre de chemin. Son type et sa contrainte (`int64`, valeur minimale `1`) sont définis dans `components.parameters.ChatId`. Le corps de la requête est décrit par `SendChatTextRequest`, qui impose un champ `content` de 1 à 10 000 caractères.

#### Fichier statique et documentation générée

`PoC/openapi.yaml` est un fichier documentaire versionné : Spring Boot ne le charge pas automatiquement pour construire les routes et il ne remplace pas les contrôleurs Java. Les routes réelles sont implémentées dans `back/src/main/java/.../controller/`.

Le backend utilise également Springdoc, qui génère une description OpenAPI à partir des contrôleurs et des annotations Java pendant l'exécution :

| Ressource | Utilisation |
| --- | --- |
| `http://localhost:8080/swagger-ui.html` | Consulter et tester l'API dans une interface graphique |
| `http://localhost:8080/v3/api-docs` | Consulter le contrat OpenAPI généré au format JSON |
| [`openapi.yaml`](openapi.yaml) | Lire, relire et partager le contrat versionné, notamment avant l'implémentation d'un client |

La documentation générée reflète le code exécuté. Le fichier YAML est la référence lisible et versionnée du contrat attendu. Après toute modification d'une route, d'un DTO, d'un mécanisme d'authentification ou d'une réponse, il faut vérifier la cohérence entre le YAML, les contrôleurs Java et la documentation Springdoc. Le YAML ne doit pas être présenté comme une preuve qu'une route cible est déjà implémentée : les routes réservation et paiement y sont documentées pour l'architecture cible, mais restent hors du périmètre de cette PoC.

#### Valider le YAML

Depuis le dossier `PoC`, la validation peut être effectuée avec un validateur OpenAPI :

```powershell
npx --yes @redocly/cli lint openapi.yaml
```

Cette commande vérifie la syntaxe YAML, les références `$ref` et la conformité OpenAPI. Elle nécessite Node.js et peut télécharger l'outil lors de la première exécution. Une validation réussie ne remplace pas les tests backend : elle confirme uniquement que le contrat est exploitable par des outils OpenAPI.

## Tests et build

### Frontend

Depuis `PoC/front` :

```powershell
npm run build
npm run test:unit:ci
npm run cypress:run
```

Le build peut afficher des avertissements concernant le budget de certains fichiers SCSS. Ils ne constituent pas une erreur tant que la commande se termine avec le code `0`.

### Backend

Depuis `PoC/back`, avec PostgreSQL demarre et les variables d'environnement definies :

```powershell
.\mvnw.cmd test
.\mvnw.cmd verify
```

Les tests backend utilisent la base configurée par le profil de développement. Le parcours complet du tchat, notamment le fonctionnement entre deux utilisateurs, doit aussi être validé manuellement avec les scénarios précédents.

## Structure réelle de la PoC

```text
PoC/
├── README.md
├── back/
│   ├── pom.xml
│   ├── mvnw
│   ├── mvnw.cmd
│   └── src/
│       ├── main/
│       │   ├── java/com/openclassrooms/yourwayapi/
│       │   │   ├── controller/       # Routes HTTP REST et SSE
│       │   │   ├── dto/              # Objets d'échange avec le frontend
│       │   │   ├── entity/           # Entités JPA
│       │   │   ├── exception/        # Gestion des erreurs API
│       │   │   ├── repository/       # Accès PostgreSQL
│       │   │   ├── security/         # JWT, cookies et refresh tokens
│       │   │   └── service/          # Règles métier
│       │   └── resources/
│       │       ├── application.properties
│       │       └── scripts SQL de la base
│       └── test/java/                # Tests JUnit et Spring Boot
└── front/
    ├── package.json
    ├── angular.json
    ├── proxy.conf.json
    └── src/
        ├── environments/             # Configurations mock et réelle
        └── app/
            ├── core/                 # Authentification, modèles et services
            ├── features/chat/        # Liste, création et détail du tchat
            ├── shared/               # Composants partagés
            └── store/                # État frontend
```

Les scripts SQL et leur procédure d'installation complète se trouvent dans [Livrables/Database](../Livrables/Database). Les documents d'architecture du projet sont conservés dans `Livrables/`, mais ils ne décrivent pas des composants installés dans cette PoC.

## Limites connues

Cette PoC est une démonstration fonctionnelle locale. Elle n'utilise pas de migrations versionnées, de gestion de secrets de production, de scalabilité horizontale, de broker de messages ou de supervision complète des flux SSE.

Avant une mise en production, il faudrait notamment ajouter une stratégie de migrations, une gestion sécurisée des secrets, une supervision des connexions SSE, des tests E2E spécialisés sur le tchat et une architecture de déploiement adaptée à la charge.
