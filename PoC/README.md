# PoC tchat - Your Car Your Way

Cette preuve de concept démontre le parcours d'un tchat entre un client et un agent. Elle couvre uniquement la fonctionnalité de tchat et ne constitue pas l'application complète de réservation.

## Sommaire

- [**Introduction**](#introduction)
    - [Périmètre de la PoC](#périmètre-de-la-poc)
    - [Technologies utilisées](#technologies-utilisées)

- [**Installation**](#installation)
    - [Prérequis](#prérequis)
    - [Récupérer le projet](#récupérer-le-projet)
    - [Initialiser PostgreSQL](#initialiser-postgresql)
        - [Développement local uniquement](#développement-local-uniquement)
        - [Environnement persistant hors développement local](#environnement-persistant-hors-développement-local)
        - [Initialisation automatique par Spring](#initialisation-automatique-par-spring)
    - [Démarrer le backend](#démarrer-le-backend)
    - [Démarrer le frontend](#démarrer-le-frontend)
        - [Mode mock](#mode-mock)
        
- [**Validation & scénarii**](#validation--scenarii)
    - [Comptes de démonstration](#comptes-de-démonstration)
    - [Statuts d'une conversation](#statuts-dune-conversation)
    - [Parcours de validation](#parcours-de-validation)
        - [Parcours client et agent](#parcours-client-et-agent)
        - [Parcours de libération et de reprise](#parcours-de-libération-et-de-reprise)
        - [Controle des droits](#controle-des-droits)

- [**API du tchat**](#api-du-tchat)
    - [Contrat OpenAPI](#contrat-openapi)
        - [Comment lire le fichier](#comment-lire-le-fichier)
        - [Fichier statique et documentation générée](#fichier-statique-et-documentation-générée)
        - [Valider le YAML](#valider-le-yaml)

- [**Tests et build**](#tests-et-build)
    - [Frontend](#frontend)
    - [Backend](#backend)

- [Structure réelle de la PoC](#structure-réelle-de-la-poc)

## Introduction

## Quick-start (5 minutes)

Suivez ces étapes pour démarrer rapidement la PoC en local.
1. Cloner le dépôt et se placer dans le dossier PoC :

```powershell
git clone https://github.com/Kevin-Renault/Projet-10.git
Set-Location Projet-10\PoC
```

2. Préparer les variables d'environnement pour l'application

```powershell
# Copier l'exemple et éditer les secrets locaux (ne PAS committer back/.env)
copy back\.env.example back\.env
notepad back\.env    # éditer DB_PASSWORD et JWT_SECRET
```

3. Démarrer PostgreSQL et initialiser la base (utilise les valeurs de `back/.env`)

```powershell
# Recommended: use docker compose to start Postgres and run the SQL init scripts
docker compose -f docker-compose.yml up -d --build

# Follow Postgres logs (will show initialization progress)
docker compose -f docker-compose.yml logs -f postgres

# If you need a clean re-init, stop and remove volumes first:
# docker compose -f docker-compose.yml down -v
```

4. Vérifier que PostgreSQL est prêt

```powershell
# Attendre que Postgres accepte les connexions
docker exec postgres18 bash -lc 'until pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"; do sleep 1; done'
```

Les scripts SQL sont exécutés automatiquement par PostgreSQL lors de la création
du volume Docker. Ils ne sont pas relancés par le backend Spring.

5. Charger les variables d'environnement dans la session PowerShell et démarrer le backend

```powershell
Get-Content back\.env | ForEach-Object {
    if ($_ -match '^\s*([^#=]+)=(.*)$') {
        $name = $matches[1].Trim(); $val = $matches[2].Trim()
        $env:$name = $val
        # map POSTGRES_* -> DB_* expected by the Spring Boot app
        switch ($name) {
            'POSTGRES_DB' { $env:DB_YCYW_NAME = $val }
            'POSTGRES_USER' { $env:DB_USER = $val }
            'POSTGRES_PASSWORD' { $env:DB_PASSWORD = $val }
            default { }
        }
    }
}

Set-Location back
.\mvnw.cmd spring-boot:run
```

6. Démarrer le frontend (séparé)

```powershell
Set-Location front
npm ci
npm start
```

7. Vérifier les points d'accès

- Frontend : http://localhost:4200
- Swagger backend : http://localhost:8080/swagger-ui.html

Notes et bonnes pratiques

- `back/.env` contient des secrets locaux ; **ne** le commitez pas. Utilisez un `.env.example` (placeholders) pour documenter les variables. 
- Préférez `--env-file` ou `docker-compose` pour éviter d'exposer des mots de passe dans l'historique de commandes.
- Si le conteneur PostgreSQL redémarre ou s'arrête immédiatement, inspectez les logs :
    ```powershell
    docker logs postgres18 --tail 200
    ```
- Pour nettoyer :
    ```powershell
    docker rm -f postgres18
    docker volume rm pgdata
    ```

### Périmètre de la PoC

#### Fonctionnel

Un client peut :
- se connecter de façon sécurisée en tant que client
- accéder à l'interface client
- créer et consulter une conversation
- répondre à une de ses conversations
- clôturer une de ses conversations
- se déconnecter

Un agent peut :
- se connecter de façon sécurisée en tant qu'agent
- accéder à l'interface agent
- prendre une conversation en attente (nouvelle ou libérée)
- répondre aux clients dans les conversations qu'il a en charge
- libérer une conversation attribuée
- se déconnecter

#### Implémentation technique

Cette section décrit comment la PoC réalise les fonctions listées ci‑dessus (emplacement du code, choix d'implémentation). Pour la liste des bibliothèques et versions, voir **Technologies utilisées**.

- Architecture : monolithe Spring Boot (`PoC/back`) pour l'API et Angular (`PoC/front`) pour le client ; voir la section *Structure réelle de la PoC* pour l'arborescence.
- Persistance : PostgreSQL pour les entités du domaine (messages, conversations, utilisateurs). Les scripts SQL se trouvent dans `back/src/main/resources` ; pour appliquer l'ensemble (y compris les fonctions/trigger PL/pgSQL), utiliser `Livrables/Database/apply_all.ps1`.
- Temps réel : notifications par Server‑Sent Events (implémentées côté serveur avec `SseEmitter`, côté client via `EventSource`).
- Mode mock : le frontend propose un mode mock (`environment.dev`) pour tester l'UI sans backend (services `*MockService`).
- Sécurité & authentification : mécanisme d'authentification et sessions détaillé dans la sous‑section **Sessions et authentification** ci‑dessous.
- Tests & validation : le front/back contiennent des suites unitaires et E2E (Jest/Cypress côté frontend, JUnit côté backend) — voir la section *Tests et build*.

#### Relation avec le CDC et ses releases

Le CDC décrit le produit cible et organise ses fonctionnalités par livraisons : un lot préparatoire regroupe le socle sécurisé (US-14, US-15 et US-16), la Release 1 regroupe le MVP de réservation (US-01 à US-07) et la Release 2 regroupe l'historique, la modification de réservation, l'intégration agence, l'internationalisation et les services tiers (US-08, US-09, US-10, US-11, US-13 et US-17). Un lot technique distinct, déjà démontré par cette PoC, couvre le tchat client-agent (US-18).

Cette PoC ne constitue pas l'implémentation complète de ces releases. Elle valide une tranche technique ciblée, centrée sur le tchat, avec l'authentification et la gestion de session nécessaires à son fonctionnement. Le socle sécurisé et le tchat sont donc démontrés techniquement, sans que cela signifie que la Release 1 ou la Release 2 sont entièrement livrées.

Les fonctionnalités de réservation, de paiement et d'infrastructure distribuée décrites dans le CDC et l'architecture cible restent hors du périmètre implémenté de cette PoC.

##### Sessions et authentification

- Mécanisme : la PoC utilise un access token JWT pour l'authentification des requêtes et un refresh token opaque pour prolonger la session.
- Cookies : les deux tokens sont envoyés au client en cookies `HttpOnly` (impossibles à lire depuis JavaScript). Le refresh cookie est limité au chemin `/api/auth`.
- Stockage serveur : les refresh tokens opaques sont hashés (SHA-256) et stockés en base (`refresh_token`) avec une date d'expiration.
- Rotation : lors d'un appel à `/api/auth/refresh` le refresh token présenté est vérifié, supprimé et remplacé par un nouveau (rotation). Le backend renvoie un nouveau access cookie et un nouveau refresh cookie.
- Révocation : l'appel à `/api/auth/logout` révoque le refresh token (suppression côté serveur) et efface les cookies côté client.
- Durées par défaut : access token ~ `86400s` (1 jour), refresh token ~ `2592000s` (30 jours) — réglables via `security.jwt.*`.
- Frontend : `AuthService.initSession()` tente de récupérer `/api/auth/me`; si le token d'accès est expiré il appelle `/api/auth/refresh` puis retente `/me`. Un intercepteur (`RefreshOn401Interceptor`) déclenche automatiquement `/api/auth/refresh` sur `401` et réessaie la requête.
- CSRF : endpoint `/api/auth/csrf` initialise le cookie `XSRF-TOKEN` et le backend expose le token via l'en-tête `X-XSRF-TOKEN` pour les clients.

#### Limites connues

La PoC n'implémente pas le parcours de réservation, le paiement ni l'infrastructure distribuée (Redis, RabbitMQ, Kubernetes) ou une supervision de production. En revanche, elle permet de valider les choix technologiques cibles (Java 21, Spring Boot, Angular, PostgreSQL) sur les parcours fonctionnels montrés dans cette PoC.



### Technologies utilisées

| Composant | Technologie |
| --- | --- |
| Frontend | Angular 21, TypeScript, RxJS |
| Backend | Java 21, Spring Boot 3.2, Spring MVC |
| Base de données | PostgreSQL 18 (stable) ou plus récent |
| Persistance | Spring Data JPA et Hibernate |
| Authentification | Spring Security, JWT et cookies HttpOnly |
| Protection des requêtes | CSRF avec cookie et header `X-XSRF-TOKEN` |
| Temps réel | Server-Sent Events avec `SseEmitter` et `EventSource` |
| Tests frontend | Jest, Karma/Jasmine et Cypress |
| Tests backend | JUnit, Spring Boot Test et Mockito |

## Installation

### Prérequis

Installer :

- Java 21 — Temurin (Adoptium) : https://adoptium.net/temurin/releases/?version=21
- Node.js (LTS) et npm : https://nodejs.org/en/download/
- PostgreSQL 18 (stable) : https://www.postgresql.org/download/
- Git : https://git-scm.com/downloads

Vérifier les installations :

```powershell
java -version
node --version
npm --version
psql --version
```

Le backend attend PostgreSQL sur `localhost:5432`. L'utilisateur PostgreSQL doit pouvoir se connecter à la base et, lors de la première installation, créer l'extension `pgcrypto`.

### Récupérer le projet

```powershell
git clone https://github.com/Kevin-Renault/Projet-10.git
Set-Location Projet-10\PoC
```

Si le dépôt est déjà présent, se placer directement dans le dossier `PoC`.

### Initialiser PostgreSQL

Créer une base vide :

```powershell
createdb -U postgres ycyw_poc
```

Le backend lit sa configuration dans les variables d'environnement. Elles doivent être définies avant son démarrage, dans le même environnement que celui qui exécute Maven.

#### Développement local uniquement

Pour un test local rapide, définir les variables dans le terminal PowerShell qui lancera le backend :

```powershell
$env:DB_YCYW_NAME = "ycyw_poc"
$env:DB_USER = "postgres"
$env:DB_PASSWORD = "mot-de-passe-local"
$env:JWT_SECRET = "cle-locale-de-developpement-d-au-moins-32-caracteres"
```

Cette méthode est pratique pour le développement local : les variables restent disponibles uniquement dans ce terminal et les processus lancés depuis celui-ci. Elles disparaissent lorsque le terminal est fermé. Ne pas utiliser de mots de passe ou de secrets réels dans ce fichier ou dans un script versionné.

#### Environnement persistant hors développement local

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

#### Initialisation locale par Spring (optionnelle)

Par défaut, Spring n'exécute aucun script SQL au démarrage :

```properties
spring.sql.init.mode=never
```

Pour demander exceptionnellement à Spring d'exécuter les scripts SQL depuis
`back/src/main/resources`, remplacer cette valeur par :

```properties
spring.sql.init.mode=always
```

Les scripts concernés sont :

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

Le script `06_triggers_and_functions.sql` n'est pas exécuté par le séparateur SQL Spring, car il contient des blocs PL/pgSQL. Pour appliquer l'ensemble du schéma, utiliser le script `Livrables/Database/apply_all.ps1`.

### Démarrer le backend

Depuis `back`, après avoir défini les variables PostgreSQL et JWT :

```powershell
Set-Location back
.\mvnw.cmd spring-boot:run
```

Le backend démarre sur `http://localhost:8080`.

### Profils Spring Boot (docker vs local)

Ce projet fournit deux fichiers de configuration complémentaires pour faciliter l'exécution selon l'environnement :

- `back/src/main/resources/application-docker.properties` : utilisé quand l'application tourne avec Docker Compose. Il connecte la JVM au service Postgres du réseau Docker (hôte `postgres`) et lit les variables `POSTGRES_*` fournies par `back/.env` ou `docker-compose`.
- `back/src/main/resources/application-local.properties` : utilisé pour le développement local avec PostgreSQL accessible sur `localhost`. Il utilise les variables `DB_YCYW_NAME`, `DB_USER` et `DB_PASSWORD` (ou des valeurs de secours définies dans le fichier).

Comment lancer avec un profil :

- Lancer depuis un shell (profil `local`) :

```powershell
# profil local (Postgres sur localhost)
Set-Location back
.\mvnw.cmd -Dspring-boot.run.profiles=local spring-boot:run
```

- Lancer avec Docker Compose (profil `docker`) :

```powershell
# démarrer Postgres via docker-compose
docker compose -f docker-compose.yml up -d

# lancer le backend en demandant explicitement le profil docker
Set-Location back
.\mvnw.cmd -Dspring-boot.run.profiles=docker spring-boot:run
```

Avec Docker, une autre option est d'exporter `SPRING_PROFILES_ACTIVE=docker` dans la configuration d'environnement du service `back` dans `docker-compose.yml` — cependant, la méthode ci‑dessus (passage de profil par l'option Maven) est non destructive et simple pour tester.


### Démarrer le frontend

Dans un second terminal :

```powershell
Set-Location front
npm ci
npm start
```

Ouvrir ensuite `http://localhost:4200`.

Le frontend utilise `proxy.conf.json` pour transmettre les appels `/api` vers `http://localhost:8080`. La configuration par défaut utilise `environment.ts` et les services réels.

#### Mode mock

Le mode mock permet de tester l'interface sans démarrer PostgreSQL ni le backend :

```powershell
npm start -- --configuration dev
```

Ce mode utilise `environment.dev.ts`, `AuthMockService`, `ChatMockService` et les autres services mock. Il ne valide pas la persistance, l'authentification backend, la protection CSRF ou les SSE réels.

La configuration Angular `normal` utilise également les services réels. Elle ne correspond pas à un fichier `environment.normal.ts` : ce fichier n'existe pas dans la PoC.

<a name="validation--scenarii"></a>
## Validation & scénarii

### Comptes de démonstration

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

### Contrat OpenAPI de la PoC (`openapi-poc.yaml`)

Le fichier [`openapi-poc.yaml`](openapi-poc.yaml) est le contrat versionné de l'API de la PoC au format OpenAPI 3.0.3. Il décrit les échanges attendus entre le frontend et le backend de la PoC :

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

`PoC/openapi-poc.yaml` est un fichier documentaire versionné : Spring Boot ne le charge pas automatiquement pour construire les routes et il ne remplace pas les contrôleurs Java. Les routes réelles sont implémentées dans `back/src/main/java/.../controller/`.

Le backend utilise également Springdoc, qui génère une description OpenAPI à partir des contrôleurs et des annotations Java pendant l'exécution :

| Ressource | Utilisation |
| --- | --- |
| `http://localhost:8080/swagger-ui.html` | Consulter et tester l'API dans une interface graphique |
| `http://localhost:8080/v3/api-docs` | Consulter le contrat OpenAPI généré au format JSON |
| [`openapi-poc.yaml`](openapi-poc.yaml) | Lire, relire et partager le contrat versionné de la PoC, notamment avant l'implémentation d'un client |

La documentation générée reflète le code exécuté. Le fichier YAML est la référence lisible et versionnée du contrat attendu. Après toute modification d'une route, d'un DTO, d'un mécanisme d'authentification ou d'une réponse, il faut vérifier la cohérence entre le YAML, les contrôleurs Java et la documentation Springdoc. Le YAML ne doit pas être présenté comme une preuve qu'une route cible est déjà implémentée : les routes réservation et paiement y sont documentées pour l'architecture cible, mais restent hors du périmètre de cette PoC.

#### Valider le YAML

Depuis le dossier `PoC`, la validation peut être effectuée avec un validateur OpenAPI :

```powershell
npx --yes @redocly/cli lint openapi-poc.yaml
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

Les scripts SQL et le script d'application du schéma se trouvent dans [Livrables/Database](../Livrables/Database). Les documents d'architecture du projet sont conservés dans `Livrables/`, mais ils ne décrivent pas des composants installés dans cette PoC.

## Limites connues

Cette PoC est une démonstration fonctionnelle locale. Elle n'utilise pas de migrations versionnées, de gestion de secrets de production, de scalabilité horizontale, de broker de messages ou de supervision complète des flux SSE.

Avant une mise en production, il faudrait notamment ajouter une stratégie de migrations, une gestion sécurisée des secrets, une supervision des connexions SSE, des tests E2E spécialisés sur le tchat et une architecture de déploiement adaptée à la charge.
