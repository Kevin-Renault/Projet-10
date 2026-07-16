## 1. Contexte et périmètre

### 1.1 Contexte métier

Your Car Your Way est une entreprise historique du secteur, présente depuis plus de vingt ans sur le marché européen et récemment implantée en Amérique du Nord. Sa croissance rapide s’est accompagnée d’une multiplication d’applications web distinctes selon les pays, entraînant quelques problèmes :

une complexité technique,
des incohérences fonctionnelles,
des difficultés de maintenance.

### 1.2 Enjeux et objectifs de l’audit

- Comprendre le fonctionnement actuel des applications.
  - Ce qu'elle ont en commun
  - ce qui les différencies
- Identifier les avantages et inconvénient apparent des différentes solutions qui tourne a date.
- S’appuyer uniquement sur les documents fournis dans le dossier `Contexte` pour réaliser cet audit. Les sources exploitées sont :
  - `Contexte/Your Car Your Way - Cahier des charges V1.pdf`
  - `Contexte/DFSJA P10 Description technique de l'existant.pdf`

Les informations techniques et les métriques présentées dans ce rapport sont reprises des sections correspondantes de `Contexte/Description+technique+de+l'existant.md`, qui constitue la transcription de référence du document technique fourni. Les éléments interprétés comme des conséquences ou des risques sont distingués des faits observés.


### 1.3 Périmètre de l’analyse

- Stack présente
- performance et fiabilité
- Expérience utilisateur.
- Modele.
- Analyse des points forts, limites et risques.


## 2. Audit


### 2.1 Stack

Le tableau suivant récapitule les éléments techniques identifiés dans le rapport "Description technique de l'existant" (Contexte) pour chaque pays : frontend, backend, hébergement et remarques opérationnelles.

| Pays | Frontend | Backend | Hébergement / Déploiement | Remarques techniques |
|---|---|---|---|---|
| France (FR) | JSP / JSF | Java EE | OVH (serveurs, déploiements manuels) | Monolithe historique, base fonctionnelle riche mais vieillissante; mots de passe histor. hashés en SHA-1; TLS 1.0 encore utilisé pour compatibilité |
| Allemagne (DE) | JSP / JSF (dérivé FR) | Java EE | OVH | Dérivés du produit FR, variations locales, schémas proches mais divergence progressive |
| Espagne (ES) | JSP / JSF (dérivé FR) | Java EE | OVH | Même observation que DE/IT ; déploiements manuels |
| Italie (IT) | JSP / JSF (dérivé FR) | Java EE | OVH | TLS 1.0 encore présent sur certaines instances |
| Royaume‑Uni (UK) | PHP (Laravel) | PHP (Laravel) | AWS (EC2) | Application plus récente, isolation du code, bcrypt (cost 10) pour hash des mots de passe |
| Canada (CA) | React | Node.js | AWS | Tentative de modernisation (frontend React, backend Node.js) ; argon2id pour hash des mots de passe |
| États‑Unis (US) | Angular | Spring Boot | Azure (App Services / Containers) | Seule application containerisée ; bcrypt strength 12 ; déploiements plus industrialisés |

Notes additionnelles :
- Les API existantes sont limitées, hétérogènes et non unifiées entre pays.
- Chaque pays possède sa propre base de données avec des schémas divergents ; le partage d'information est actuellement absent ou manuel.
- Indicateurs opérationnels (extraits) : charge maximale sans dégradation ~150 req/s (FR/DE/ES/IT), ~350 req/s (US). Taux de vulnérabilités connu plus élevé sur FR (≈41%) comparé à US (≈11%).





### 2.2 performance et fiabilité

Le tableau ci‑dessous récapitule les métriques clés par groupe/pays (extraits du rapport "Description technique de l'existant"). Les valeurs marquées `(BEST)` indiquent la meilleure valeur observée pour la métrique, `(WORST)` la moins bonne.

| Pays / Groupe | Disponibilité (12m) | MTTR (moy.) | Taux réussite déploiement | Charge max (req/s) | Erreurs pic (%) | Backups & redondance |
|---|---:|---:|---:|---:|---:|---|
| FR / DE / ES / IT | <strong style="color:red">**97.2 % (WORST)**</strong> | <strong style="color:red">**~2 h 45 (WORST)**</strong> | <strong style="color:red">**~82 % (WORST)**</strong> | <strong style="color:red">**≈ 150 (WORST)**</strong> | <strong style="color:red">**jusqu'à 4 % (WORST)**</strong> | <strong style="color:red">**Backups manuels 1×/j; restauration non testée (WORST)**</strong> |
| UK | 98.6 % | ~1 h 10 | ~91 % | ≈ 250 | ~1.5 % | Snapshots quotidiens AWS (sans tests réguliers) |
| CA | 98.1 % | ~1 h 10 | ~91 % | ≈ 300 | ~1.5 % | Snapshots quotidiens AWS (sans tests réguliers) |
| US | <strong style="color:green">**98.9 % (BEST)**</strong> | <strong style="color:green">**~1 h 10 (BEST)**</strong> | <strong style="color:green">**~91 % (BEST)**</strong> | <strong style="color:green">**≈ 350 (BEST)**</strong> | <strong style="color:green">**~0.8 % (BEST)**</strong> | <strong style="color:green">**Sauvegardes Azure automatisées; tests de restauration tous les 90 jours (BEST)**</strong> |

Observations synthétiques :

- Les environnements cloud (UK/CA/US) montrent des indicateurs opérationnels supérieurs aux environnements OVH (FR/DE/ES/IT) : disponibilité, MTTR, taux de réussite des déploiements et pratiques de sauvegarde.
- Les FR/DE/ES/IT présentent des faiblesses transverses (déploiements manuels, hashage historique, TLS 1.0), ce qui constitue un risque pour la disponibilité et la sécurité.

Métriques complémentaires issues de la description technique de l'existant :

| Pays / Groupe | Stabilisation après mise à jour | Indisponibilité mensuelle moyenne | Redondance |
|---|---:|---:|---|
| FR / DE / ES / IT | 3,4 jours | 21 à 28 minutes | Aucune réplication des instances applicatives |
| UK | 1,7 jour | 9 à 16 minutes pour le groupe UK / CA | Réplication partielle |
| CA | 1,7 jour | 9 à 16 minutes pour le groupe UK / CA | Réplication partielle |
| US | 1,7 jour | 7 minutes | Application containerisée, mais base non redondante |

Ces indicateurs complètent l'analyse de disponibilité et de fiabilité : les environnements cloud stabilisent plus rapidement les mises à jour, mais la base de données américaine reste un point de fragilité en l'absence de redondance.

Priorités recommandées (court terme → moyen terme) :

- Automatiser CI/CD pour réduire les erreurs de déploiement et augmenter le taux de réussite (>95%).
- Mettre en place réplication et plans de basculement pour les bases FR/DE/ES/IT ; automatiser et tester la restauration des backups.
- Déployer observabilité (metrics, traces, alerting) et définir SLO/SLI pour monitorer la disponibilité et la latence.
- Effectuer des tests de charge réguliers avant les périodes de pic (vacances) et dimensionner l'infrastructure (autoscaling, cache/CDN).
- Corriger immédiatement les failles critiques : migration des hash SHA‑1, mise à niveau TLS 1.2+, scans SCA et plan de correction.

Indicateurs de succès à court terme : réduction du MTTR (<1h), taux de réussite des déploiements >95%, sauvegardes automatisées et testées sur 100% des environnements de production.




### 2.3 Expérience utilisateur

Source unique : observations strictement issues de `Contexte/DFSJA P10 Description technique de l'existant.pdf`.

Faits extraits du PDF :
- Le document fournit très peu d'informations UX détaillées. Il décrit principalement l'état technique et les particularités par pays.
- Mention explicite : Canada — « meilleure expérience utilisateur » et tentative locale d'unification visuelle (résultat non généralisé).
- Observations techniques liées à l'UX : le FR/DE/ES/IT sont décrits comme des monolithes plus anciens (stack Java EE, déploiements manuels), ce qui laisse supposer une interface historique ; le US utilise une stack plus moderne (Angular + Spring Boot) et déploiements containerisés.
- Aucune description précise des parcours utilisateur, des formulaires, de la navigation, de l'accessibilité ou de l'adaptation mobile n'est fournie dans ce rapport.

Conséquence méthodologique : le rapport ne permet pas de tirer de conclusions détaillées sur la qualité des parcours UX — seules des observations techniques et une note positive pour le Canada sont disponibles.

Recommandations pour un audit UX ultérieur :
1. Inventaire visuel : collecter captures d'écran / maquettes actuelles et lister les pages par pays.
2. Audit technique minimal : vérifier responsive / présence d'assets CSS/JS modernes et tester rendu mobile basique.
3. Audit d'accessibilité automatique (axe-core) sur parcours techniques identifiés dans le PDF (login, recherche, réservation si accessibles) pour obtenir une baseline.
4. Tests utilisateurs rapides (5–8 utilisateurs représentatifs) pour valider les hypothèses (notamment pour CA où le PDF signale une meilleure UX).
5. Synthèse et priorisation : produire une liste de correctifs UX à faible coût (formulaires, feedback, lisibilité) puis une roadmap pour la refonte visuelle si nécessaire.

Remarque : ces actions ne peuvent pas être réalisées à partir des seules sources fournies. Elles constituent une démarche recommandée pour un audit UX ultérieur et ne remettent pas en cause la conclusion du présent audit documentaire. Le CDC et les décisions produit pourront s'appuyer sur ces vérifications avant d'engager des développements UX coûteux.



### 2.4 Modèle

Constats tirés exclusivement de `Contexte/DFSJA P10 Description technique de l'existant.pdf` :

- Données et schémas : chaque pays possède sa propre base de données avec des schémas divergents. Le partage d'information est « inexistant ou via échanges manuels ».
- Architecture applicative : état dominant de monolithes web (100 % monolithes, aucune architecture microservice mentionnée).
- APIs : limitées, hétérogènes et non unifiées entre pays (le document signale explicitement l'absence d'APIs unifiées).
- Particularités pays : modèles et règles métier présentent des différences (ex. UK et US présentent des règles et modèles parfois différents des dérivés FR).

Implications techniques (déductions directement liées aux constats ci‑dessus) :

- Absence d'un modèle canonique partagé : toute interopérabilité nécessite mapping entre schémas nationaux.
- Difficulté de consolidation des données en temps réel en l'absence d'APIs unifiées et de mécanismes d'échange automatisés.
- Migration vers une plateforme centralisée nécessitera une phase d'alignement de modèles et de normalisation des formats.

### 2.5 Analyse des points forts, limites et risques

Les points ci‑dessous reprennent les éléments factuels et métriques fournis par le même PDF, suivis des risques opérationnels qui en découlent.

Points forts  :
- Simplicité d'architecture actuelle : pile majoritairement monolithique, qui facilite la compréhension initiale et la maintenance locale (par équipes locales).
- Certaines implantations cloud (UK/CA/US) montrent des pratiques de déploiement et sauvegarde plus industrialisées (US : application containerisée, sauvegardes Azure automatisées avec tests de restauration réguliers).

Limites  :
- Disponibilité et opérations : FR/DE/ES/IT présentent une disponibilité moyenne de 97.2 % et des déploiements majoritairement manuels ; taux de réussite des déploiements ~82 % contre ~91 % pour UK/CA/US.
- Sauvegardes et redondance : FR/DE/ES/IT utilisent backups manuels (1×/j) sans tests de restauration ; UK/CA ont snapshots quotidiens sans tests réguliers ; US a sauvegardes automatisées et tests.
- Sécurité : hashage des mots de passe en SHA‑1 pour FR/DE/ES/IT (héritage historique) ; TLS 1.0 encore utilisé sur certaines instances FR/IT ; secrets stockés dans fichiers de configuration sur serveurs OVH pour FR/DE/ES/IT.
- APIs et intégration : APIs limitées et hétérogènes, pas de contrat unifié ; partage d'information essentiellement manuel.
- Charge et résilience : charge maximale sans dégradation notablement plus basse pour FR/DE/ES/IT (~150 req/s) comparée au US (~350 req/s). Taux d'erreur en pics : jusqu'à 4 % pour FR/DE/ES/IT.
- Taux de vulnérabilités connues : FR ~41 % des packages présentent vulnérabilités connues (vs US ~11 %).

Risques (conséquences directes des faits ci‑dessus) :
- Disponibilité : absence de réplication et sauvegardes non testées expose à des temps d'indisponibilité et perte de données en cas d'incident.
- Sécurité : usage de SHA‑1, TLS 1.0 et secrets non centralisés constituent des risques critiques exploitables pour compromission de comptes et fuite de données.
- Opérationnel : déploiements manuels et faible taux de réussite augmentent le risque d'erreurs en production et allongent le MTTR (FR/DE/ES/IT ~2 h 45).
- Scalabilité : schémas divergents et absence d'APIs unifiées complexifient la montée en charge et la consolidation multi‑pays.
- Conformité et dette technique : taux élevé de dépendances vulnérables (FR) et pratiques de gestion des secrets insuffisantes augmentent l'effort de remédiation et le coût de mise en conformité.

Ces constats doivent servir de base factuelle pour toute priorisation technique : corrections de sécurité immédiates (migration des hash et TLS), industrialisation des déploiements, automatisation des sauvegardes et définition d'une stratégie de normalisation des modèles de données avant toute consolidation.


## 3. Conclusion de l'audit

L'existant permet d'assurer le fonctionnement des applications nationales, mais il ne répond pas suffisamment aux objectifs de centralisation, d'homogénéisation et d'évolutivité du projet cible.

| Critère | Évaluation | Justification |
|---|---|---|
| Maintenabilité | Insuffisante | Les technologies, les pratiques de déploiement et les modèles de données diffèrent selon les pays, avec plusieurs applications historiques. |
| Sécurité | Insuffisante sur certaines applications | Les environnements historiques utilisent encore SHA-1, TLS 1.0 et, pour certains, des secrets stockés dans des fichiers de configuration. |
| Disponibilité | Inégale | Les environnements cloud présentent de meilleurs indicateurs que les environnements historiques, mais la redondance des bases reste incomplète. |
| Évolutivité | Limitée | L'architecture est majoritairement monolithique et les bases nationales ne partagent pas de modèle canonique. |
| Interopérabilité | Insuffisante | Les APIs sont limitées et hétérogènes ; les échanges de données sont inexistants ou principalement manuels. |
| Expérience utilisateur | Non évaluable complètement | Les documents fournis ne décrivent pas suffisamment les parcours, l'accessibilité, le responsive ou les interfaces par pays. |

Cette conclusion justifie la conception d'une architecture centralisée reposant sur un modèle de données commun, des APIs harmonisées, une gestion moderne des secrets, des mécanismes de sauvegarde testés et un processus de déploiement industrialisé. Elle ne constitue pas une validation de l'architecture cible : cette validation relève de la proposition d'architecture et de la PoC.

