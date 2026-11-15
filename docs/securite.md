# Sécurité

Belsign traite des données personnelles : identité, adresse, image, signature manuscrite, et parfois des données de mineurs. Ce document décrit les protections intégrées et ce qui reste à la charge de l'exploitant.

## Ce que fait l'application

### Accès

- **Connexion** :
  - mots de passe hachés avec bcrypt, 12 caractères minimum ;
  - blocage temporaire après plusieurs échecs, par compte et par adresse IP ;
  - temps de réponse identique, que le compte existe ou non ;
  - email insensible à la casse.
- **Sessions** :
  - cookie `HttpOnly`, `SameSite=Strict`, `Secure` et préfixé `__Host-` en HTTPS ;
  - mode strict, identifiant renouvelé à la connexion ;
  - expiration après une heure d'inactivité (`SESSION_LIFETIME`) ;
  - fichiers de session rangés dans `storage/sessions/`, pas dans le dossier temporaire partagé de l'hébergement.
- **Fermeture des sessions** : désactiver un compte ou changer son mot de passe ferme immédiatement ses autres sessions.
- **Rôles vérifiés côté serveur sur chaque page** :
  - un utilisateur n'accède qu'aux documents qu'il a créés ;
  - les pages d'administration sont réservées aux administrateurs ;
  - un administrateur ne peut ni rétrograder ni désactiver son propre compte.
- **Protection CSRF** : chaque action qui modifie quelque chose exige un jeton propre à la session.

### Intégrité des documents signés

- **Document figé à la validation** :
  - le PDF est généré une seule fois et ne l'est plus jamais ensuite, même si le modèle change ;
  - les signatures ne peuvent plus être modifiées ;
  - un second clic sur « Valider » n'a aucun effet, et les emails ne partent qu'une fois.
- **Empreinte** : l'empreinte SHA-256 de chaque PDF est enregistrée en base (`documents.pdf_sha256`), avec l'heure de validation (`validated_at`). Elle permet de prouver qu'un fichier n'a pas été modifié.
- **Contrôle des signatures** : la taille et le format PNG sont vérifiés, puis l'image est ré-encodée avant d'être enregistrée.

### Contenus et fichiers

- **Modèles** : le texte est filtré par liste blanche à l'enregistrement et à l'affichage. Seules la mise en forme de l'éditeur et les champs du catalogue sont conservés : ni script, ni attribut d'événement, ni lien `javascript:`, ni style.
- **PDF** : Dompdf est configuré sans ressources distantes, sans JavaScript et sans PHP, et confiné à son dossier.
- **Images envoyées** (logos, icône) :
  - PNG, JPEG ou WebP, 2 Mo maximum ;
  - toujours décodées puis ré-encodées en PNG ;
  - le SVG est refusé.
- **Champs saisis** :
  - dates vérifiées côté serveur ;
  - longueur limitée ;
  - valeurs insérées dans le document comme du texte, jamais comme du HTML.
- **Fichiers** : les noms de fichiers ne contiennent que des caractères sûrs, et les chemins sont vérifiés avant écriture et lecture.

### Navigateur et serveur

- **En-têtes de sécurité** envoyés par PHP, donc même sans `mod_headers` :
  - `Content-Security-Policy` stricte : scripts de l'application uniquement, avec un jeton unique par page ;
  - `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy` ;
  - `Strict-Transport-Security` en HTTPS.
- **Redirection HTTPS** : en production, si `APP_URL` commence par `https://`, toute requête en HTTP est redirigée vers HTTPS.
- **Fichiers non exposés** :
  - seul `public/` est exposé ;
  - si le domaine pointe sur le dossier de l'application, le `.htaccess` redirige tout vers `public/` ;
  - chaque dossier sensible (`config/`, `src/`, `storage/`, `vendor/`, `scripts/`) interdit en plus tout accès direct.
- **Erreurs** : elles ne sont jamais affichées en production. Elles sont écrites dans `storage/logs/app.log`.
- **Version** : ni la version de PHP ni celle de l'application ne sont exposées publiquement.

### Installeur

- **Code d'installation** : il faut saisir le code du fichier `storage/CODE-INSTALLATION.txt`, lisible uniquement par FTP. Personne ne peut donc installer l'application à votre place.
- **Désactivation** : l'installeur se désactive définitivement après l'installation. Il refuse aussi de s'exécuter si une base contenant des comptes existe déjà, par exemple si `config/.env` a été perdu.
- **Tout ou rien** : la base, le compte administrateur et la configuration sont créés en une seule fois ; en cas d'échec, rien n'est conservé.
- **Hébergement** : l'installeur vérifie que les fichiers internes ne sont pas lisibles depuis le web.

## Ce qui reste à votre charge

1. **HTTPS obligatoire** : activez le certificat SSL et indiquez une adresse en `https://` dans l'installeur.
2. **Sauvegardes** : programmez `scripts/backup.php` et copiez régulièrement les archives **hors du serveur**. Elles contiennent des données personnelles : stockez-les chiffrées.
3. **Comptes** :
   - un compte par personne, jamais de compte partagé ;
   - désactivez les comptes des personnes qui partent ;
   - réservez le rôle administrateur au strict nécessaire.
4. **Mises à jour** : installez les nouvelles versions, qui contiennent les correctifs de sécurité. Gardez aussi PHP à jour (version maintenue) dans l'espace client.
5. **Vérification après installation** : `https://sign.domaine.fr/config/.env` et `https://sign.domaine.fr/storage/database.sqlite` doivent renvoyer une erreur.
6. **RGPD** :
   - informez les personnes ; le message affiché avant chaque document sert à ça ;
   - définissez une durée de conservation des documents ;
   - tenez votre registre des traitements.

## Signaler une faille

Signalez-la en privé depuis l'onglet *Security* du dépôt GitHub (*Report a vulnerability*), en décrivant le problème et la façon de le reproduire. Ne la publiez pas avant sa correction.
