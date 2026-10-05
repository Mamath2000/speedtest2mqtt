#!/bin/bash
# Build / release Docker de speedtest2mqtt.
#   build   : image locale speedtest2mqtt:latest (aucun push)
#   release : version +1 (fichier VERSION) commitée « Release X.Y.Z », build, push Docker Hub
#             (latest, X.Y.Z, ref git), tag git vX.Y.Z — l'image X.Y.Z contient exactement ce commit
set -e

APP_NAME="speedtest2mqtt"
DOCKER_USER=${DOCKER_USER:-"mathmath350"}
action=${1:-build}

for cmd in docker git; do
    command -v $cmd >/dev/null 2>&1 || { echo "❌ $cmd est requis mais non installé."; exit 1; }
done

if [ "$action" = "build" ]; then
    docker build -t "$APP_NAME:latest" .
    echo "✅ Image locale $APP_NAME:latest construite (aucun push)"
    exit 0
fi

if [ "$action" != "release" ]; then
    echo "Usage: $0 [build|release]"
    exit 1
fi

docker info 2>/dev/null | grep -q Username || { echo "❌ Non connecté à Docker Hub (docker login)."; exit 1; }
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ Working directory non propre, commitez d'abord :"
    git status --short
    exit 1
fi

VERSION=$(tr -d '[:space:]' < VERSION)
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"
NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
echo "📦 Version : $VERSION → $NEW_VERSION"

echo "$NEW_VERSION" > VERSION
trap 'echo "❌ Échec : version restaurée"; git checkout -- VERSION' ERR
git add VERSION
git commit -q -m "🔖 Release $NEW_VERSION"
trap - ERR
trap 'echo "❌ Échec du build/push : annuler le commit de release avec  git reset --hard HEAD~1"' ERR
GIT_REF=$(git rev-parse --short HEAD)

docker build \
    --label "org.opencontainers.image.version=$NEW_VERSION" \
    --label "org.opencontainers.image.revision=$GIT_REF" \
    --label "org.opencontainers.image.created=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    -t "$DOCKER_USER/$APP_NAME:latest" \
    -t "$DOCKER_USER/$APP_NAME:$NEW_VERSION" \
    -t "$DOCKER_USER/$APP_NAME:$GIT_REF" \
    .
for tag in latest "$NEW_VERSION" "$GIT_REF"; do
    docker push -q "$DOCKER_USER/$APP_NAME:$tag"
done
git tag "v$NEW_VERSION"

echo "✅ Version $NEW_VERSION publiée : $DOCKER_USER/$APP_NAME:{latest,$NEW_VERSION,$GIT_REF}"
echo "🔄 À pousser : git push origin <branche> --tags"
