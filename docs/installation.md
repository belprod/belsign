# Installation, mise à jour et sauvegarde

Ce guide sert à installer Belsign sur un hébergement mutualisé comme OVH, o2switch, Infomaniak, Hostinger ou IONOS, sans accès SSH. Tout se fait depuis l'espace client de l'hébergeur, un client FTP (FileZilla, par exemple) et le navigateur. Comptez une quinzaine de minutes.

Dans tout ce guide, `sign.domaine.fr` désigne l'adresse choisie pour l'application. Remplacez-la par la vôtre.

## Avant de commencer

Il vous faut :

- un hébergement avec **PHP 8.1 ou plus récent**, la version se choisit dans l'espace client ;
- l'archive `belsign-X.Y.Z.zip`, à télécharger sur la [page des versions](https://github.com/belprod/belsign/releases/latest) ;
- les accès FTP de l'hébergement.

L'application doit occuper **toute une adresse** : un sous-domaine comme `sign.domaine.fr`, ou un domaine entier. Elle ne fonctionne pas dans un sous-dossier comme `domaine.fr/sign`.

Pas besoin de créer de base de données : l'application utilise SQLite, un simple fichier créé automatiquement.

## 1. Créer le sous-domaine et le certificat SSL

Dans l'espace client de l'hébergeur :

1. Créez le sous-domaine `sign.domaine.fr` :
   - chez OVH : *Hébergements* > *Multisite* > *Ajouter un domaine ou sous-domaine* ;
   - chez o2switch : *cPanel* > *Domaines*.
2. Choisissez son **dossier racine**. Indiquez un nouveau dossier, par exemple `belsign/public`. Le dossier `belsign` recevra l'application à l'étape suivante.
3. Activez le **certificat SSL** (Let's Encrypt, gratuit) pour ce sous-domaine. L'application doit être utilisée en `https://`.

L'activation du sous-domaine et du certificat peut prendre de quelques minutes à quelques heures.

> **Si l'hébergeur ne permet pas de choisir `public/` comme racine**, faites pointer le sous-domaine sur le dossier `belsign`. Le fichier `.htaccess` fourni redirige alors automatiquement tout vers `public/`, et les dossiers sensibles restent inaccessibles.

## 2. Envoyer les fichiers

1. Décompressez `belsign-X.Y.Z.zip` sur votre ordinateur.
2. Avec le client FTP, envoyez **le contenu** du dossier `belsign-X.Y.Z` dans le dossier `belsign` du serveur, celui choisi à l'étape 1 (sans le `/public`).
3. Vérifiez que les fichiers cachés (dont le nom commence par un point, comme `.htaccess`) ont bien été envoyés. Dans FileZilla : *Serveur* > *Forcer l'affichage des fichiers cachés*.

## 3. Lancer l'installeur

Ouvrez `https://sign.domaine.fr` dans le navigateur. L'installeur s'affiche :

1. **Vérification de l'hébergement**. Corrigez les points en rouge, puis rechargez la page. Parmi les points vérifiés, l'installeur contrôle que les fichiers internes ne sont pas lisibles depuis le web :
   - pour la version de PHP, choisissez-la dans l'espace client ;
   - pour les droits d'écriture sur `config/` et `storage/`, faites un clic droit sur le dossier dans FileZilla > *Droits d'accès au fichier* > `755` ou `775`.
2. **Code d'installation** : l'installeur a créé le fichier `storage/CODE-INSTALLATION.txt`. Ouvrez-le avec le client FTP (clic droit > *Afficher/Éditer*) et recopiez le code. Il prouve que vous êtes bien le propriétaire de l'hébergement, et il est supprimé à la fin de l'installation.
3. **Paramètres** :
   - nom de l'application ;
   - email et mot de passe de l'administrateur (12 caractères minimum) ;
   - adresse d'expédition des emails ;
   - éventuellement un serveur SMTP (voir plus bas).
4. Cliquez sur **Installer**, puis connectez-vous.

Une fois l'installation terminée, l'installeur se désactive définitivement : personne ne peut le relancer.

> Si `config/.env` est un jour perdu, par exemple lors d'un transfert FTP, l'installeur refuse de s'exécuter sur une base existante. Renvoyez simplement votre copie de `config/.env`.

### Emails : SMTP ou pas ?

- **Sans SMTP**, les emails passent par la fonction d'envoi de l'hébergeur. Ça fonctionne souvent, mais ils risquent d'arriver en spam.
- **Avec SMTP (recommandé)**, créez une adresse email chez votre hébergeur (par exemple `no-reply@domaine.fr`) et reportez ses paramètres dans l'installeur. Les valeurs habituelles :

| Hébergeur | Serveur | Port | Chiffrement |
|---|---|---|---|
| OVH | `ssl0.ovh.net` | 465 | SSL |
| o2switch | `mail.domaine.fr` | 465 | SSL |
| Infomaniak | `mail.infomaniak.com` | 587 | TLS |
| Gmail / Google Workspace | `smtp.gmail.com` | 587 | TLS (mot de passe d'application) |

Ces réglages se modifient plus tard dans `config/.env`, à éditer par FTP.

## 4. Premiers pas

1. **Personnalisation** : nom, logo, couleur d'accent.
2. **Modèles** > *Nouveau modèle* : indiquez le client. Le texte standard est déjà prêt : adaptez-le, ajoutez le logo du client, puis enregistrez.
3. **Utilisateurs** : créez les comptes des personnes qui feront signer.
4. Programmez la **sauvegarde automatique** (voir ci-dessous).

L'aide intégrée, accessible depuis le menu **Aide**, détaille l'utilisation au quotidien.

## Mettre à jour l'application

1. Faites une **sauvegarde** (voir ci-dessous).
2. Décompressez la nouvelle archive et envoyez son contenu par FTP en **écrasant** les fichiers existants. L'archive ne contient ni `config/.env` ni aucune donnée : vos réglages, documents et signatures ne sont pas touchés.
3. Ouvrez l'application : la base se met à jour automatiquement au premier chargement d'une page.

La version installée est indiquée en bas de la page **Aide**.

## Sauvegarde

Toutes les données sont dans `storage/` :

| Élément | Emplacement |
|---|---|
| Base : utilisateurs, modèles, documents, réglages | `storage/database.sqlite` |
| PDF signés | `storage/pdfs/` |
| Signatures, logos des clients, logo de l'application | `storage/uploads/` |

Gardez aussi une copie de `config/.env`, qui contient le mot de passe SMTP.

**Sauvegarde automatique (recommandée).** Dans l'espace client, rubrique *Tâches planifiées* ou *Cron*, ajoutez une tâche quotidienne, par exemple à 3 h :

```
php /home/votre-compte/belsign/scripts/backup.php
```

Chez OVH, la tâche planifiée pointe directement sur le fichier `belsign/scripts/backup.php`, avec la version de PHP choisie.

Chaque exécution crée une archive datée dans `storage/backups/` et conserve les 30 plus récentes. La base y est copiée de façon cohérente, même si quelqu'un signe au même moment.

**Téléchargez régulièrement `storage/backups/` sur un autre support**, au moins une fois par semaine : une sauvegarde restée sur le serveur ne protège pas d'une panne du serveur.

**Sans tâche planifiée**, téléchargez le dossier `storage/` par FTP, de préférence quand personne n'utilise l'application.

## Restaurer une sauvegarde

1. Décompressez l'archive. Elle contient `database.sqlite`, `pdfs/` et `uploads/`.
2. Par FTP, remplacez sur le serveur `storage/database.sqlite`, `storage/pdfs/` et `storage/uploads/` par ces éléments. Ne supprimez pas les fichiers `.htaccess` de `storage/`.
3. Ouvrez l'application. Si la sauvegarde est plus ancienne que la version installée, la base est mise à jour automatiquement.

Faites un essai de restauration une première fois, sur une installation de test, pour vérifier que vos sauvegardes sont exploitables.

## Réinstaller de zéro

Supprimez `config/.env` et `storage/database.sqlite` par FTP, puis ouvrez l'application : l'installeur réapparaît. **Toutes les données sont alors perdues**, sauvegardez-les avant.

## Dépannage

| Symptôme | Solution |
|---|---|
| Page blanche ou « Erreur 500 » | Vérifiez la version de PHP (8.1 ou plus) et consultez `storage/logs/app.log`. |
| L'installeur signale un dossier non accessible en écriture | Mettez les droits `755` ou `775` sur `config/` et `storage/`, sous-dossiers compris. |
| « Fichiers internes protégés » en rouge | Le serveur ignore les fichiers `.htaccess` : faites pointer le domaine sur `public/`. |
| « Code d'installation incorrect » | Recopiez le contenu exact de `storage/CODE-INSTALLATION.txt`. Le code ne tient pas compte des majuscules. |
| Toutes les pages redirigent vers `https://` | `APP_URL` est en `https://` mais le certificat SSL n'est pas actif : activez-le, ou mettez temporairement `http://` dans `config/.env`. |
| « Installée à la racine du domaine » en rouge | L'application est dans un sous-dossier : créez un sous-domaine dédié. |
| Le site affiche la liste des fichiers, ou une erreur 403 sur toutes les pages | Le fichier `.htaccess` n'a pas été envoyé : affichez les fichiers cachés dans le client FTP et renvoyez-le. |
| Les emails n'arrivent pas | Configurez un serveur SMTP dans `config/.env`, et regardez le dossier spam. |
| Le logo ne s'enregistre pas | Image de 2 Mo maximum, au format PNG, JPEG ou WebP. |

### Vérifier que les données sont protégées

Après l'installation, ces adresses doivent afficher une erreur (403 ou 404), **jamais** un contenu :

- `https://sign.domaine.fr/config/.env`
- `https://sign.domaine.fr/storage/database.sqlite`

### Serveur Nginx (hors mutualisé)

Les fichiers `.htaccess` ne sont lus que par Apache. Avec Nginx, faites pointer `root` sur `public/` et transmettez les fichiers `.php` à PHP-FPM. Les autres dossiers ne sont alors jamais exposés :

```nginx
server {
    server_name sign.domaine.fr;
    root /var/www/belsign/public;
    index index.php;
    client_max_body_size 8M;

    location / { try_files $uri $uri/ =404; }
    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
    }
    location ~ /\. { deny all; }
}
```
