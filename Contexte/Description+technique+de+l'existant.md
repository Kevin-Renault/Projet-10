
# Description technique de l’existant

## Sommaire

- Contexte
- Architectures par pays
	- France (application historique)
	- Allemagne, Espagne, Italie
	- Royaume-Uni
	- Canada
	- États-Unis
- Architecture globale
- État des lieux techniques
	- Fiabilité
	- Sécurité
	- Disponibilité

## États-Unis

- **Contexte :** mise à l’essai d’une nouvelle stack technique à l’occasion de ce nouveau projet.
- **Technologies :**
	- Frontend : Angular
	- Backend : Spring Boot
- **Déploiement :** Azure (App Services / Containers).
- **Particularités :**
	- Seule application containerisée.
	- Projet plus ambitieux, mais jamais généralisé à d’autres pays.

## Architecture globale

- **Architecture dominante :** 100 % monolithes web (aucun microservice).
- **APIs :** limitées, hétérogènes et non unifiées.
- **Données :** chaque pays possède sa propre base, avec des schémas divergents.
- **Partage d’information :** inexistant ou assuré par des échanges manuels.

## État des lieux techniques

### Fiabilité

#### Taux de disponibilité moyen des quatre applications (sur 12 mois)

| Pays ou groupe de pays | Disponibilité |
| --- | --- |
| FR / DE / ES / IT | 97,2 % |
| UK | 98,6 % |
| CA | 98,1 % |
| US | 98,9 % |

#### Temps moyen de récupération après incident (MTTR)

| Environnement | MTTR |
| --- | --- |
| OVH | Environ 2 h 45 |
| AWS / Azure | Environ 1 h 10 |

#### Taux de réussite des déploiements

| Environnement | Taux de réussite |
| --- | --- |
| FR / DE / ES / IT (OVH) | 82 % (déploiements manuels) |
| UK / CA / US (cloud) | 91 % |

#### Délai moyen de stabilisation après une mise à jour

Ce délai correspond aux bugs post-release jusqu’à stabilisation.

| Pays ou groupe de pays | Délai moyen |
| --- | --- |
| FR / DE / ES / IT | 3,4 jours |
| UK / CA / US | 1,7 jour |

### Sécurité

#### Hachage des mots de passe

| Pays ou groupe de pays | Algorithme |
| --- | --- |
| FR / DE / ES / IT | SHA-1 (héritage historique) |
| UK (Laravel) | bcrypt (cost 10) |
| CA (Node.js) | argon2id |
| US (Spring Boot) | bcrypt (strength 12) |

#### Chiffrement du trafic

HTTPS est activé partout, mais TLS 1.0 est encore utilisé en France et en Italie pour des raisons de compatibilité.

#### Gestion des secrets

| Pays ou groupe de pays | Gestion des secrets |
| --- | --- |
| FR / DE / ES / IT | Secrets stockés dans des fichiers de configuration sur serveur OVH. |
| UK / CA | Variables d’environnement AWS, sans rotation automatisée. |
| US | Azure KeyVault utilisé partiellement, pour les API seulement. |

#### Dépendances présentant des vulnérabilités connues

Résultats du scan interne :

| Pays ou groupe de pays | Part des packages concernés |
| --- | --- |
| FR | 41 % |
| DE / ES / IT | Entre 35 % et 40 % |
| UK | 18 % |
| CA | 22 % |
| US | 11 % |

### Disponibilité

#### Temps moyen d’indisponibilité mensuel

| Pays ou groupe de pays | Indisponibilité moyenne |
| --- | --- |
| FR / DE / ES / IT | 21 à 28 minutes |
| UK / CA | 9 à 16 minutes |
| US | 7 minutes |

#### Redondance

| Pays ou groupe de pays | État de la redondance |
| --- | --- |
| FR / DE / ES / IT | Aucune réplication des instances applicatives. |
| UK / CA | Réplication partielle. |
| US | Application containerisée, mais base non redondante. |

#### Charge maximale sans dégradation

| Pays ou groupe de pays | Charge maximale |
| --- | --- |
| FR / DE / ES / IT | Environ 150 requêtes par seconde |
| UK | Environ 250 requêtes par seconde |
| CA | Environ 300 requêtes par seconde |
| US | Environ 350 requêtes par seconde |
