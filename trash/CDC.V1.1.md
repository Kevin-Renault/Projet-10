# CAHIER DES CHARGES

## SOMMAIRE

- Objet du document
- Contexte
- Périmètre
- Liste des fonctionnalités
- Gestion du profil
- Gestion d’une location de voitures
- Exigences particulières
- Profils et situations d’usage
- Besoins utilisateurs consolidés
- Règles métier consolidées
- Exigences transverses
- User stories et critères d’acceptation
- Points à clarifier

## Objet du document

Le document “Cahier des charges” liste les fonctionnalités à implémenter pour le projet Your Car Your Way. Ces fonctionnalités sont exprimées du point de vue métier sous la forme d’actions que l’utilisateur peut effectuer sur l’application.

## Contexte

Your Car Your Way est une entreprise de location de voitures. Les clients utilisent actuellement des applications web qui ne correspondent plus aux besoins fonctionnels ni aux contraintes techniques. Une nouvelle application centralisée pour tous les clients doit être créée.

## Périmètre

Les fonctionnalités décrites dans ce document concernent la première version de la nouvelle application Your Car Your Way. Cette application sera déployée à l'international, et utilisée par tous les clients de l’entreprise.

Cette application est à destination des clients, et ne concerne pas les actions que les employés de Your Car Your Way doivent faire en agence.

## Liste des fonctionnalités

> Note de Leilani : cette section n’est pas exhaustive ni complétée.

### Gestion du profil

- Consulter son profil via la page de profil.
- Modifier ses informations personnelles (nom, prénom, date de naissance, adresse) via la page de profil.
- Supprimer son compte.

### Gestion d’une location de voitures

- Consulter la liste des agences de location.
- Afficher les offres de location après avoir rempli un formulaire de recherche avec les critères suivants :
	- ville de départ ;
	- ville de retour ;
	- date et heure de début
	- date et heure de retour ;
	- catégorie du véhicule.
- Consulter le détail d’une offre de location.
- Réserver une location correspondant à une offre, ce qui inclut :
	- fournir ses informations personnelles (récupérables depuis le profil si présentes) ;
	- effectuer le paiement.
- Consulter l’historique de ses réservations (passées et en cours).
- Modifier et annuler une réservation.

Une offre de location se définit par :

- une ville de départ ;
- une ville de retour ;
- une date et une heure de départ ;
- une date et une heure de retour ;
- une catégorie de véhicule ;
- un tarif.

## Exigences particulières

- La modification d’une réservation est possible jusqu’à 48 h avant le début de cette dernière.
- À moins d'une semaine du début de la réservation, YourCarYourWay ne rembourse que 25 % du montant total de la réservation.
- La gestion du paiement doit être externalisée auprès d’un fournisseur de service de paiement en ligne (par exemple : Stripe).
- Les catégories du véhicule reprennent la norme ACRISS : https://www.acriss.org/car-codes/.
- La suppression du compte implique de saisir le mot de passe du compte.
- Les applications utilisées en agence doivent avoir accès à une API pour consulter et modifier les données traitées par l’application à destination des clients. Les opérations CRUD standard sont requises pour chaque domaine (exemple : utilisateur, réservation, etc.).

## Profils et situations d’usage

### Client consultant les offres

- Consulter la liste des agences de location.
- Rechercher des offres de location selon des critères de ville, date, heure et catégorie de véhicule.
- Consulter le détail d’une offre de location.

### Client disposant d’un compte

- Consulter son profil.
- Modifier ses informations personnelles.
- Réserver une location.
- Consulter l’historique de ses réservations.
- Modifier ou annuler une réservation selon les règles prévues.
- Supprimer son compte.

### Client en situation de handicap

- Accéder aux mêmes fonctionnalités de consultation, réservation et gestion de compte que les autres clients.
- Utiliser l’application dans des conditions compatibles avec les exigences d’accessibilité mentionnées dans l’énoncé.

### Applications utilisées en agence

- Consulter les données traitées par l’application à destination des clients via une API.
- Modifier ces données via une API.
- Utiliser les opérations CRUD standard sur les domaines concernés.

## Besoins utilisateurs consolidés

- Pouvoir rechercher une offre de location correspondant à un besoin de déplacement.
- Pouvoir comparer et consulter les informations d’une offre avant réservation.
- Pouvoir réserver une offre en renseignant les informations nécessaires et en effectuant un paiement.
- Pouvoir retrouver ses réservations passées et en cours.
- Pouvoir modifier ou annuler une réservation dans le respect des règles métier.
- Pouvoir gérer ses informations personnelles depuis son profil.
- Pouvoir supprimer son compte selon un parcours sécurisé.
- Pouvoir utiliser le service dans un contexte international.
- Pouvoir consulter les contenus, libellés et informations affichées dans une langue adaptée.
- Pouvoir accéder au service dans des conditions compatibles avec les besoins des personnes en situation de handicap.

## Règles métier consolidées

- Une offre de location est définie par une ville de départ, une ville de retour, une date et une heure de départ, une date et une heure de retour, une catégorie de véhicule et un tarif.
- La modification d’une réservation est possible jusqu’à 48 h avant le début de cette dernière.
- À moins d'une semaine du début de la réservation, YourCarYourWay ne rembourse que 25 % du montant total de la réservation.
- Le paiement est géré par un fournisseur de service de paiement en ligne externe.
- Les catégories de véhicule suivent la norme ACRISS.
- La suppression du compte nécessite la saisie du mot de passe du compte.
- Les applications utilisées en agence doivent pouvoir consulter et modifier les données via une API offrant les opérations CRUD standard sur les domaines concernés.

## Exigences transverses

### Accessibilité

- Les besoins des personnes en situation de handicap doivent être pris en compte.
- Les parcours de consultation, recherche, réservation, gestion du profil et suppression du compte doivent être pensés pour être accessibles.

#### Prise en compte des PSH

- Les parcours principaux doivent pouvoir être réalisés uniquement au clavier.
- Les champs de formulaire, boutons, liens et actions doivent être identifiables de manière compréhensible.
- Les messages d’erreur, d’aide et de confirmation doivent être explicites et compréhensibles.
- Les parcours principaux doivent être compatibles avec l’utilisation d’un lecteur d’écran.
- Les informations utiles à la réalisation d’une action ne doivent pas reposer uniquement sur la couleur ou sur un repère visuel seul.
- Les étapes du parcours de réservation doivent rester compréhensibles pour des utilisateurs ayant des besoins de simplification et de guidage.

### Sécurité

- La suppression du compte doit être confirmée par la saisie du mot de passe.
- Le paiement doit être externalisé auprès d’un fournisseur de service de paiement en ligne.
- L’accès aux données par les applications d’agence doit passer par une API dédiée.

### Internationalisation

- L’application est destinée à être déployée à l’international.
- Les fonctionnalités doivent permettre de gérer des villes de départ et de retour dans un contexte international.
- Les éléments affichés à l’utilisateur doivent pouvoir être présentés dans la langue de l’interface.
- Les labels, messages, textes d’interface et informations affichées doivent être cohérents avec la langue utilisée.

## User stories et critères d’acceptation

### Gestion du profil

#### US-01 - Consultation du profil

En tant que client disposant d’un compte, je veux consulter mon profil afin d’accéder à mes informations personnelles.

Critères d’acceptation :

- Étant donné un client disposant d’un compte, quand il accède à la page de profil, alors il peut consulter ses informations personnelles.

#### US-02 - Modification du profil

En tant que client disposant d’un compte, je veux modifier mes informations personnelles afin de maintenir mon profil à jour.

Critères d’acceptation :

- Étant donné un client disposant d’un compte, quand il modifie son nom, son prénom, sa date de naissance ou son adresse depuis la page de profil, alors les nouvelles informations sont prises en compte.

#### US-03 - Suppression du compte

En tant que client disposant d’un compte, je veux supprimer mon compte afin de ne plus utiliser le service.

Critères d’acceptation :

- Étant donné un client disposant d’un compte, quand il demande la suppression de son compte, alors la saisie de son mot de passe est requise.
- Étant donné un client naviguant au clavier ou à l’aide d’un lecteur d’écran, quand il demande la suppression de son compte, alors il peut comprendre l’action demandée, saisir son mot de passe et confirmer l’opération.

### Gestion d’une location de voitures

#### US-04 - Consultation des agences

En tant que client, je veux consulter la liste des agences de location afin d’identifier les points de départ et de retour disponibles.

Critères d’acceptation :

- Étant donné un client, quand il consulte les agences de location, alors la liste des agences est affichée.

#### US-05 - Recherche d’offres de location

En tant que client, je veux afficher les offres de location à partir de critères de recherche afin de trouver une offre adaptée à mon besoin.

Critères d’acceptation :

- Étant donné un client, quand il renseigne une ville de départ, une ville de retour, une date et une heure de début, une date et une heure de retour et une catégorie de véhicule, alors les offres de location correspondantes peuvent être affichées.
- Étant donné un client naviguant au clavier, quand il utilise le formulaire de recherche, alors il peut atteindre et renseigner tous les champs sans souris.
- Étant donné un client utilisant un lecteur d’écran, quand il utilise le formulaire de recherche, alors les champs, leurs libellés et les messages associés sont compréhensibles.

#### US-06 - Consultation du détail d’une offre

En tant que client, je veux consulter le détail d’une offre de location afin de vérifier qu’elle correspond à mon besoin.

Critères d’acceptation :

- Étant donné une offre de location, quand le client consulte son détail, alors il peut accéder aux informations de l’offre.
- Étant donné un client utilisant un lecteur d’écran, quand il consulte le détail d’une offre, alors il peut accéder aux informations essentielles de l’offre de manière compréhensible.

#### US-07 - Réservation d’une location

En tant que client, je veux réserver une offre de location afin de confirmer ma location.

Critères d’acceptation :

- Étant donné une offre de location, quand le client effectue une réservation, alors il peut fournir ses informations personnelles.
- Étant donné une réservation, quand les informations du profil sont présentes, alors elles peuvent être récupérées depuis le profil.
- Étant donné une réservation, quand le client valide le parcours de paiement, alors le paiement est effectué via un fournisseur externe.
- Étant donné un client naviguant au clavier ou à l’aide d’un lecteur d’écran, quand il effectue une réservation, alors il peut comprendre les étapes du parcours, renseigner les informations demandées et identifier les actions à réaliser.

#### US-08 - Consultation de l’historique des réservations

En tant que client disposant d’un compte, je veux consulter l’historique de mes réservations afin de retrouver mes réservations passées et en cours.

Critères d’acceptation :

- Étant donné un client disposant d’un compte, quand il consulte son historique, alors ses réservations passées et en cours sont affichées.
- Étant donné un client naviguant au clavier ou à l’aide d’un lecteur d’écran, quand il consulte son historique, alors il peut parcourir ses réservations et distinguer les informations utiles sans dépendre d’un code couleur seul.

#### US-09 - Modification d’une réservation

En tant que client disposant d’une réservation, je veux modifier ma réservation afin de l’adapter à mon besoin dans le respect des règles prévues.

Critères d’acceptation :

- Étant donné une réservation, quand le client demande une modification plus de 48 h avant son début, alors la modification est possible.
- Étant donné une réservation, quand le client demande une modification moins de 48 h avant son début, alors la modification n’est pas possible.

#### US-10 - Annulation d’une réservation

En tant que client disposant d’une réservation, je veux annuler ma réservation afin de renoncer à la location.

Critères d’acceptation :

- Étant donné une réservation, quand le client l’annule à moins d'une semaine de son début, alors le remboursement est limité à 25 % du montant total de la réservation.

### Intégration avec les applications d’agence

#### US-11 - Consultation des données via API

En tant qu’application utilisée en agence, je veux consulter les données traitées par l’application client afin d’exploiter les informations nécessaires en agence.

Critères d’acceptation :

- Étant donné une application utilisée en agence, quand elle appelle l’API dédiée, alors elle peut consulter les données des domaines concernés.

#### US-12 - Modification des données via API

En tant qu’application utilisée en agence, je veux modifier les données traitées par l’application client afin d’assurer les opérations nécessaires en agence.

Critères d’acceptation :

- Étant donné une application utilisée en agence, quand elle appelle l’API dédiée, alors elle peut utiliser des opérations CRUD standard sur les domaines concernés.

### Internationalisation

#### US-13 - Affichage dans la langue de l’interface

En tant que client, je veux consulter l’interface dans une langue adaptée afin de comprendre les informations, les labels et les actions affichées.

Critères d’acceptation :

- Étant donné un client utilisant une langue d’interface donnée, quand il consulte l’application, alors les labels et les textes affichés sont présentés dans cette langue.
- Étant donné un client utilisant une langue d’interface donnée, quand il consulte un formulaire ou un parcours, alors les messages, aides et informations affichées sont cohérents avec cette langue.
- Étant donné un client utilisant une langue d’interface donnée, quand il consulte une action ou un résultat affiché, alors les éléments de display visibles sont compréhensibles dans cette langue.

## Points à clarifier

- La note de Leilani précise que la liste des fonctionnalités n’est pas exhaustive ni complétée.
- Les modalités exactes de création de compte et d’authentification ne sont pas précisées dans le cahier des charges initial.
- Les modalités détaillées de gestion des remboursements en dehors du cas « à moins d'une semaine » ne sont pas précisées.
- Les conditions détaillées de modification d’une réservation ne sont précisées que pour la contrainte des 48 h.
- Les exigences fonctionnelles détaillées liées à l’internationalisation ne sont pas explicitement décrites.
- Les exigences fonctionnelles détaillées liées à l’accessibilité doivent être complétées lors de la consolidation du besoin.
