# Changelog

Les changements notables de chaque version. Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/), numérotation [SemVer](https://semver.org/lang/fr/).

## [1.1.0] — 2026-11-16

### Nouveautés

- **Bilingue français / anglais** : toute l'interface, installeur compris. Chacun choisit sa langue (sélecteur FR / EN, mémorisé sur le compte). La langue par défaut se règle dans l'installeur et dans les réglages. Les emails partent dans la langue du destinataire.
- **Texte standard en anglais** : à la création d'un modèle, on choisit la langue du document.
- **Double authentification obligatoire pour les administrateurs** :
  - code à 6 chiffres d'une application (Google Authenticator, 1Password…), configurée par QR code à la première connexion ;
  - codes de secours à usage unique ;
  - réinitialisation possible par un autre administrateur ou par `scripts/reset-2fa.php`.
- **Invitations par email** : l'administrateur invite un utilisateur ou un administrateur, qui crée lui-même son compte et son mot de passe. Le lien reste affiché à l'administrateur si l'email n'arrive pas.
- **Mot de passe oublié** : lien de réinitialisation par email, valable 1 heure.
- **Mon compte** : changer son mot de passe et sa langue, régénérer ses codes de secours.
- **Pré-remplissage** : le client, le lieu, la date et le support du document précédent sont repris pendant la session de tournage, et la date du jour est proposée par défaut.
- **Export groupé** depuis l'historique : ZIP des PDF et tableau récapitulatif ouvrable dans Excel.
- **Téléchargement d'une sauvegarde** complète en un clic (Réglages > Sauvegarde et mises à jour).
- **Mise à jour en un clic** depuis les versions publiées sur GitHub :
  - empreinte SHA-256 vérifiée et contenu de l'archive contrôlé ;
  - sauvegarde automatique juste avant ;
  - `config/.env` et `storage/` ne sont jamais touchés.

### Modifié

- L'administrateur ne choisit plus le mot de passe des autres comptes : il les invite, ou leur envoie un lien de réinitialisation.
- Le menu est réorganisé : « Personnalisation » et la nouvelle page système sont regroupées dans « Réglages », et « Mon compte » remplace l'affichage de l'email.
- Mode `MAIL_DRIVER=log` pour le développement : les emails sont écrits dans `storage/logs/mail.log` au lieu d'être envoyés.

### Mise à jour depuis la 1.0.x

Envoyez les fichiers par FTP, comme d'habitude : la base se met à jour toute seule. Le menu Réglages proposera ensuite les mises à jour suivantes en un clic. **À la prochaine connexion, chaque administrateur configure sa double authentification** : gardez votre téléphone à portée de main.

## [1.0.2] — 2026-11-15

### Corrigé

- Quand le domaine pointe sur le dossier de l'application (et non sur `public/`), comme souvent chez IONOS :
  - erreur 500 sur toutes les pages : la redirection vers `public/` précise désormais sa base (`RewriteBase /`) et ne peut plus boucler ;
  - boucle de redirection vers l'installeur (« trop de redirections ») : l'installeur est maintenant reconnu quel que soit le chemin de redirection.

## [1.0.1] — 2026-11-15

### Corrigé

- Erreur 500 sur toutes les pages chez les hébergeurs qui interdisent la directive `Options` dans les fichiers `.htaccess` (notamment IONOS). Les dossiers sans page d'index contiennent désormais un fichier `index.html` vide, pour qu'aucun dossier ne soit jamais listé.

## [1.0.0] — 2026-11-15

Première version publique de Belsign, publiée sous licence MIT.

### Signature de documents

- Parcours en 4 étapes : choix du modèle, message d'information, saisie, signature manuscrite, puis relecture et validation.
- PDF généré à la validation, nommé `AAAA-MM-JJ_Client_Nom_Prénom.pdf` pour un tri chronologique de A à Z.
- Dates affichées au format JJ/MM/AAAA.
- Personnes mineures : case dédiée, champs et signatures des représentants légaux. La signature du second représentant n'est demandée que s'il a été saisi.
- Copie PDF par email, réglable pour chaque modèle : à la personne qui signe, dont l'email est alors demandé automatiquement, et/ou à l'utilisateur qui fait remplir la fiche.

### Modèles

- Éditeur de modèles pensé pour l'ordinateur : le document est présenté comme une page A4, avec un panneau latéral pour insérer champs et signatures en un clic.
- Un nouveau modèle part toujours d'un texte standard de consentement au droit à l'image, ou de la copie d'un modèle existant.
- Interrupteur « Personnes mineures » pour chaque modèle. Les passages réservés aux mineurs restent dans le texte, grisés, quand l'option est désactivée.
- Zones de signature retirables depuis le panneau.
- Logo du client, avec taille et position réglables.
- Aperçu avec des données fictives, même avant d'enregistrer.
- Enregistrement avec Cmd/Ctrl+S et alerte en cas de modifications non enregistrées.

### Administration

- Tableau de bord : documents signés ce mois-ci, documents à finaliser, modèles proposés, copies email en échec, graphiques par mois et par client, derniers documents.
- Historique des documents avec recherche par client, nom, prénom et date.
- Gestion des utilisateurs, avec les rôles administrateur et utilisateur.
- Personnalisation : nom de l'application, logo, icône d'onglet et couleur d'accent.
- Aide intégrée.

### Installation et exploitation

- Installeur dans le navigateur pour hébergement mutualisé : vérification de l'hébergement, création de la base et du premier administrateur. Il est protégé par un code d'installation et se désactive une fois l'installation terminée.
- Mises à jour sans SSH : la base se met à niveau automatiquement au premier chargement d'une page.
- Fonctionne avec le domaine pointé sur `public/` ou sur le dossier de l'application, grâce à la redirection par `.htaccess`.
- Sauvegarde complète (base, PDF, signatures, logos) par `scripts/backup.php`, à programmer en tâche planifiée.
- Archive de distribution allégée, d'environ 3 Mo.

### Sécurité

Audit complet avant la mise en production. Les failles corrigées :

- **Élevée** :
  - une date piégée permettait d'écrire le PDF hors de son dossier. Les dates sont désormais vérifiées et les chemins contrôlés ;
  - un document validé pouvait encore être modifié : signatures remplacées, PDF régénéré à chaque téléchargement, emails renvoyés. Il est désormais figé, et son empreinte SHA-256 est enregistrée.
- **Moyenne** :
  - le HTML des modèles est filtré par liste blanche, à l'enregistrement et à l'affichage ;
  - JavaScript est désactivé dans Dompdf ;
  - l'installeur demande un code lu par FTP, et refuse de s'exécuter si une base existe déjà ;
  - le blocage des connexions se fait par compte et par adresse IP, avec un temps de réponse constant ;
  - des en-têtes de sécurité sont envoyés par PHP, dont une CSP avec jeton unique par page, et le HTTPS est imposé en production ;
  - les sessions sont durcies : mode strict, dossier privé, expiration après inactivité, fermeture des sessions au changement de mot de passe.
- **Faible** :
  - les signatures sont vérifiées et ré-encodées ;
  - les logos des modèles sont ré-encodés en PNG ;
  - les mots de passe font 12 caractères minimum partout ;
  - les erreurs de l'installeur ne sont plus affichées en détail ;
  - `X-Powered-By` est retiré ;
  - les scripts en ligne de commande vérifient leur contexte d'exécution avant tout chargement ;
  - les emails sont comparés sans tenir compte de la casse.

### Interface

- Design sobre, pensé d'abord pour le mobile. Les tableaux deviennent des fiches sur téléphone.
- Menu burger sur mobile et tablette.
