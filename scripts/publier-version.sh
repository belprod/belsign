#!/usr/bin/env bash
#
# Publie une version de Belsign sur GitHub.
#
#   bash scripts/publier-version.sh /chemin/vers/les-sources-de-belsign
#
# Prerequis : l'archive a ete construite dans les sources
# (bash scripts/build-dist.sh -> dist/belsign-X.Y.Z.zip) et la commande
# gh est connectee au compte GitHub (gh auth status).
#
# Etapes : synchronise le changelog et la documentation depuis les
# sources, commite, cree le tag vX.Y.Z, puis - apres confirmation -
# pousse le depot et cree la version GitHub avec l'archive, son empreinte
# et les notes extraites du changelog.

set -euo pipefail

SRC="${1:?Indiquez le chemin des sources de Belsign}"
cd "$(dirname "$0")/.."

VERSION="$(tr -d '[:space:]' < "${SRC}/VERSION")"
TAG="v${VERSION}"
ZIP="${SRC}/dist/belsign-${VERSION}.zip"

[ -f "${ZIP}" ] || { echo "Archive introuvable : ${ZIP} (lancez bash scripts/build-dist.sh dans les sources)" >&2; exit 1; }
[ -f "${ZIP}.sha256" ] || { echo "Empreinte introuvable : ${ZIP}.sha256" >&2; exit 1; }
(cd "$(dirname "${ZIP}")" && shasum -a 256 -c "$(basename "${ZIP}").sha256" >/dev/null) || { echo "Empreinte invalide." >&2; exit 1; }

if git rev-parse "${TAG}" >/dev/null 2>&1; then
    echo "Le tag ${TAG} existe deja. Incrementez VERSION dans les sources." >&2
    exit 1
fi

echo "> Synchronisation du changelog et de la documentation (${VERSION})"
cp "${SRC}/CHANGELOG.md" CHANGELOG.md
cp "${SRC}/docs/installation.md" "${SRC}/docs/securite.md" docs/
sed -e 's#(voir `LICENSE`)#(voir [LICENSE](../LICENSE))#' \
    -e "s#L'archive embarque#L'archive téléchargeable embarque#" \
    -e "s#se trouve dans le dossier du composant#se trouve dans l'archive, au chemin indiqué#" \
    "${SRC}/THIRD-PARTY-LICENSES.md" > docs/composants-tiers.md

# Notes de version : la section du changelog correspondant a cette version.
NOTES="$(mktemp)"
awk -v v="${VERSION}" '
    $0 ~ "^## \\[" v "\\]" { found = 1; next }
    found && /^## \[/ { exit }
    found { print }
' CHANGELOG.md > "${NOTES}"

if [ ! -s "${NOTES}" ]; then
    echo "Aucune section [${VERSION}] dans CHANGELOG.md." >&2
    exit 1
fi

{
    echo
    echo "---"
    echo
    echo "**Installation** : téléchargez \`belsign-${VERSION}.zip\` ci-dessous, puis suivez le [guide d'installation](https://github.com/belprod/belsign/blob/main/docs/installation.md)."
    echo "**Mise à jour** : envoyez le contenu de l'archive par FTP en écrasant les fichiers ; la base se met à jour automatiquement."
    echo
    echo "Empreinte SHA-256 : \`$(cut -d' ' -f1 "${ZIP}.sha256")\`"
} >> "${NOTES}"

git add -A
if ! git diff --cached --quiet; then
    git commit -q -m "Version ${VERSION}"
fi
git tag -a "${TAG}" -m "Belsign ${VERSION}"

echo
echo "Pret a publier ${TAG} :"
echo "  archive : $(basename "${ZIP}") ($(du -h "${ZIP}" | cut -f1))"
echo "  depot   : $(git remote get-url origin 2>/dev/null || echo 'aucun remote origin')"
echo
read -r -p "Pousser le depot et publier la version sur GitHub ? (o/N) " answer

if [ "${answer}" != "o" ] && [ "${answer}" != "O" ]; then
    echo "Annule. Le commit et le tag ${TAG} restent en local (git tag -d ${TAG} pour retirer le tag)."
    exit 0
fi

git push origin HEAD --follow-tags
gh release create "${TAG}" "${ZIP}" "${ZIP}.sha256" --title "Belsign ${VERSION}" --notes-file "${NOTES}" --verify-tag
echo "Version publiee : $(gh release view "${TAG}" --json url -q .url)"
