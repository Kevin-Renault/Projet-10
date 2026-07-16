Comment allez-vous procéder ?
Image
Cette mission suit un scénario de projet professionnel.

Vous pouvez suivre les étapes pour vous aider à réaliser vos livrables.

Avant de démarrer, nous vous conseillons de :

lire toute la mission et ses documents liés ;
prendre des notes sur ce que vous avez compris ;
consulter les étapes pour vous guider ;
préparer une liste de questions pour votre première session de mentorat.
Prêt à mener la mission ?
Image
Vous êtes lead développeur au sein de l’entreprise Your Car Your Way, spécialisée dans la location de voitures à l’échelle internationale.

Logo d'entreprise Your Car Your Way

Your Car Your Way est une entreprise historique du secteur, présente depuis plus de vingt ans sur le marché européen et récemment implantée en Amérique du Nord. Sa croissance rapide s’est accompagnée d’une multiplication d’applications web distinctes selon les pays, entraînant quelques problèmes :

une complexité technique,
des incohérences fonctionnelles,
des difficultés de maintenance.
Vous pouvez lire la description technique des applications web existantes.

L’entreprise souhaite désormais concevoir une nouvelle application web centralisée, destinée à l’ensemble de ses clients, afin d’unifier les usages, améliorer l’expérience utilisateur et poser des bases techniques pérennes, évolutives et conformes aux exigences réglementaires, notamment en matière d’accessibilité.

Vous êtes chargé :

de reprendre les besoins métier existants,
d’auditer les choix techniques actuels,
de concevoir une architecture applicative complète,
de mettre en place l’environnement de développement.
La nouvelle architecture applicative devra répondre aux enjeux fonctionnels, techniques et réglementaires du projet.

Vous recevez un message de Leilani, CEO de Your Car Your Way, qui vous confie la mission suivante :

Une première version du cahier des charges a été rédigée par nos équipes, mais elle reste incomplète.

Avant de lancer le développement de la nouvelle application, j’ai besoin d’une vision claire, structurée et argumentée de la solution cible.

Je souhaite que vous consolidiez les exigences, proposiez une architecture technique robuste et validiez vos choix par une preuve de concept ciblée.

Dans ce cadre, vous devrez produire les livrables suivants :

Un cahier des charges au format PDF, présentant l’analyse des besoins utilisateurs (y compris les personnes en situation de handicap) et les spécifications fonctionnelles.
Une proposition d’architecture au format PDF, intégrant :
l’audit de l’existant,
les spécifications techniques,
la modélisation de l’architecture (diagrammes UML),
le modèle de données,
la sélection et la justification des solutions technologiques,
la modélisation de l’intégration des composants tiers,
des bonnes pratiques couvrant sécurité, accessibilité et impact écologique.
Un repository GitHub contenant une preuve de concept (PoC), démontrant la faisabilité des choix architecturaux retenus, ainsi que la structure des données associée.
Vous écrivez également un README avec des instructions pour la mise en place destinées aux développeurs juniors de l'équipe.
Votre rôle est d’agir en développeur senior, en adoptant une posture de conseil, d’analyse et de décision. Il ne s’agit pas de développer l’application complète — ce que vous savez déjà faire — mais de poser un cadre architectural solide.

Enfin, vous devrez justifier votre proposition aux parties prenantes non-techniques sur les plans fonctionnelle, technique et réglementaire.

Le projet se déroule en quatre stades.

Vous êtes libre de les aborder dans l'ordre qui vous convient.

 

Étapes

Etape 1 - Analyser les besoins fonctionnels et traduiser en spécifications fonctionnelles.


Vous commencez par analyser les éléments existants afin de consolider une vision claire et exhaustive des besoins du projet.

À partir des besoins consolidés, vous formalisez les spécifications nécessaires à la conception de la solution.

Prérequis

Avoir :

pris connaissance du contexte de Your Car Your Way ;
lu la version initiale du cahier des charges.
Résultat attendu

Le cahier de charges complété :
les exigences fonctionnelles consolidées, structurées et cohérentes,
les spécifications fonctionnelles claires, priorisées et alignées avec les besoins métier.
Recommandations

D’abord, vous analysez les besoins métier dans le cahier des charges incomplet fourni :
Analysez les besoins du point de vue des différents profils utilisateurs.
Gardez en tête les utilisateurs qui sont des personnes en situation de handicap (PSH).
Identifiez les considérations transverses (accessibilité, sécurité, internationalisation).
Ensuite, vous formalisez les besoins fonctionnels sous une forme exploitable pour la suite de la conception.
Traduisez ces besoins sous forme d’user stories.
Rédigez ces user stories accompagnées de critères d’acceptation.
Outils

Éditeur de documents (Google Docs, Word ou équivalent).
Outils de rédaction structurée (Markdown, tableurs, outils de gestion de backlog).
Points de vigilance

Ne limitez-vous pas aux fonctionnalités explicitement listées dans la version initiale.
Mettez en avant la clarté :
Évitez toute ambiguïté ou formulation trop vague.
Maintenez une vision orientée architecture.
Ne sur-spécifiez pas des éléments relevant de l’implémentation détaillée.
Intégrez dès cette étape les enjeux d'accessibilité (RGAA, PSH) et d'impact écologique dans votre analyse des besoins.
Ressources

Suivez ce cours OpenClassrooms si vous en avez besoin : Réalisez un cahier de charges fonctionnel


Etape 2 - Auditez l'existant et analysez la stack technique

Vous lisez l’analyse technique des applications web distinctes qui existent actuellement dans les différents pays. Vous comprenez les enjeux clés des applications existantes ainsi que les choix techniques passés et leurs limites. Puis vous transformez l’analyse de l’existant en audit décrivant les forces, les faiblesses et les contraintes techniques.

Prérequis

Avoir consolidé les exigences et les spécifications fonctionnelles.
Résultat attendu

Les forces, faiblesses et contraintes techniques de l’existant sont identifiées dans la proposition d’architecture.
Recommandations

Lisez l’analyse technique fournie pour identifier l’architecture globale, les technologies utilisées et leurs interactions.
Identifier les problématiques de maintenabilité, de performance et d’évolutivité.
N'hésitez pas à définir ces critères et à les rappeler en introduction de votre audit.
La conclusion de l’audit devra expliquer comment l’existant valide (ou pas) ces critères.
Outils

Description technique existante.
Pour les diagrammes et les schémas d’architecture : Draw.io, Miro, Mermaid, UML, LucidChart, ou autres.
Points de vigilance

Ne confondez pas l’audit technique et la proposition de la solution.
Évitez les jugements non justifiés.
Ressources

Articles de veille sur l’audit d’architectures logicielles.
Cours OpenClassrooms Planifiez une politique d’audit au sein de votre entreprise.


Etape 3 - Concevez l'architecture et définissez les spécifications et les choix techniques


En basant des spécifications fonctionnelles et l’audit technique de l’existant, vous définissez les spécifications techniques pour la nouvelle application.

Vous concevez l’architecture cible de l’application et modélisez les données nécessaires. Vous choisissez les technologies les plus adaptées et justifiez vos décisions.

En plus, vous planifiez l’intégration de tous les composants tiers – dans l’architecture.

Prérequis

avoir défini les spécifications fonctionnelles (user stories)
Résultat attendu

La proposition d’architecture complète, y compris :
Les spécifications techniques alignées avec les objectifs du projet.
L’architecture applicative et le modèle de données sont formalisés en diagrammes et compréhensibles.
Le plan d’intégration des composants tiers dans l’architecture.
Les choix technologiques argumentés.
Recommandations

Assurez la cohérence entre les spécifications techniques et les spécifications fonctionnelles déjà définies à l’étape 1.
Utilisez des diagrammes UML adaptés (composants, déploiement, classes).
Concevez le modèle de données en cohérence avec les besoins métier et les usages futurs.
Comparez plusieurs solutions possibles avant de trancher.
Justifiez les choix technologiques en fonction des contraintes fonctionnelles, techniques et organisationnelles.
Outils

Outils de modélisation (Draw.io, Mermaid, Lucidchart).
Documentation officielle des technologies.
Outils de veille technique.
Points de vigilance

Évitez une architecture surdimensionnée : le niveau de détail doit rester cohérent avec les 65h du projet.
Veillez à la cohérence :
entre les vues métier, données et techniques ;
entre les exigences fonctionnelles et les contraintes techniques.
Évitez les choix basés uniquement sur des préférences personnelles.
Vérifiez la compatibilité entre les composants choisis, notamment dans le cadre de l’intégration des composants tiers (ex. fournisseur de service de paiement en ligne) dans l’architecture.
Intégrez des mécanismes de sécurité, d’accessibilité et d’impact écologique dès la conception.
Ne confondez pas conception et implémentation : vous modélisez et planifiez, vous ne déployez pas l'intégralité de la solution.
Ressources

Ces cours OpenClassrooms sur la conception et la modélisation :

Développement
Définissez votre architecture logicielle grâce aux standards reconnus
Difficile
4 heures
Pour être un architecte logiciel efficace, vous devrez maîtriser une grande variété de modèles d’architecture et la manière de les représenter.

Développement
Implémentez vos bases de données relationnelles avec SQL
Moyenne
6 heures
Apprenez à gérer vos bases de données relationnelles avec MySQL : créez votre base de donnée (BDD), manipulez ses données avec des requêtes SQL et modifiez sa structure.

Développement
Appliquez le principe du Domain-Driven Design à votre application
Facile
4 heures
Avec le Domain-Driven Design ou DDD, communiquez une architecture technique. Utilisez la méthode UML, les diagrammes de cas d’utilisation et de classe.

Développement
Modélisez vos bases de données
Moyenne
8 heures
Apprenez à modéliser vos bases de données avec des diagrammes de classe UML et à passer du modèle conceptuel de données au modèle relationnel.
Cours OpenClassrooms Mettez en place un système de veille informationnelle pour les choix technologiques.
Pour optimiser votre proposition d’architecture et mieux guider l’attention de votre lecteur, consultez ces conseils.



Etape 4 - Développez une preuve de concept (PoC)

Vous développez une preuve de concept (PoC) afin de valider la faisabilité de l’architecture. Cette PoC se focalise uniquement sur une fonctionnalité — la fonctionnalité de tchat — afin que limite son périmètre.

Vous initialisez l’environnement de développement et le README pour que les devs juniors puissent facilement intégrer le projet.

Prérequis

avoir finalisé la proposition d’architecture.
Résultat attendu

La preuve de concept de la fonctionnalité de tchat qui :
démontre la viabilité des choix architecturaux,
est développé dans un environnement de développement standard (gestion de versions du code, utilisation d’un IDE),
inclut un README ciblé aux devs juniors qui leur permet de s’intégrer facilement au projet.
Recommandations

Concentrez-vous uniquement sur le tchat pour garder un périmètre fonctionnel restreint et représentatif.
Mettez en évidence la structure technique plutôt que l’interface utilisateur.
Outils

Environnement de développement adapté à la stack choisie.
Dépôt GitHub.
Markdown.
Points de vigilance

Ne transformez pas la PoC en produit final. La PoC ne doit démontrer que la fonctionnalité de tchat.
Respectez les contraintes définies dans l’architecture, y compris l’intégration des composants tiers.
Ne laissez pas le README en dernier : rédigez-le en parallèle de l'initialisation de l'environnement de développement pour ne pas manquer de temps.
Relisez vos livrables avec le prisme "développeur junior qui découvre le projet" pour valider la clarté du README.
Ressources

Les documentations officielles des frameworks utilisés.
Cours OpenClassrooms Écrivez la documentation technique de votre projet

