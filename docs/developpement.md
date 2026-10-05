---
title: Développement
description: Architecture de l'image, build local et release Docker Hub
sidebar_position: 4
---

# Développement

## Architecture

```
entrypoint.sh  ── charge config.yaml (env prioritaire) ──> variables d'environnement
      │
      └─> yacron (crontab.yml)
              ├─ job « speedtest »          : selon CRON
              └─ job « speedtest_onstart »  : @reboot
                      │
                      └─> speedtest2mqtt.sh : discovery HA → speedtest → mosquitto_pub
```

- `entrypoint.sh` convertit `config.yaml` en variables (via `ruamel.yaml` du venv de yacron), écrit
  l'environnement dans `/var/tmp/container.env`, injecte le `cron` dans `crontab.yml` puis lance `yacron`.
- `speedtest2mqtt.sh` déclare les capteurs, exécute `speedtest -f json-pretty`, extrait les champs avec `jq`
  et publie le JSON.
- Le binaire Ookla est choisi selon `TARGETARCH` : `amd64`, `arm` (armv7) ou `arm64` (`aarch64`).

## Commandes

```bash
make help            # liste des commandes
make docker-build    # image locale speedtest2mqtt:latest, sans push
make docker-release  # release complète (voir ci-dessous)
```

## Release

`make docker-release` (via `docker-release.sh`) :

1. refuse de partir si le répertoire de travail n'est pas propre ou si `docker login` n'a pas été fait ;
2. incrémente le patch du fichier `VERSION` (sans commit), juste avant le build ;
3. construit l'image avec les labels OCI (version, révision = dernier commit, date) ;
4. pousse `latest`, `X.Y.Z` et la référence git courte sur Docker Hub ;
5. **seulement si tout a réussi** : commite `VERSION` (« 🔖 Release X.Y.Z ») et pose le tag git `vX.Y.Z`.

En cas d'échec (build, push, droits Docker Hub insuffisants…), `VERSION` est restaurée : aucun commit ni tag n'est
créé et le dépôt reste propre ; on peut relancer la release après correction.

`DOCKER_USER` (défaut `mathmath350`) permet de changer de compte. Il reste à pousser :
`git push origin <branche> --tags`.

Pour une montée mineure ou majeure, éditer `VERSION` à la main avant la release (ex. `0.2.0` ; le patch repart de
là au passage suivant).

## Publier la documentation avec Docusaurus

Le dossier `docs/` est directement utilisable comme dossier de documentation Docusaurus (front matter et
`_category_.json` fournis). Dans un site Docusaurus existant, le copier ou le monter dans son `docs/`, par exemple
`docs/speedtest2mqtt/`.
