---
title: Installation
description: Déployer speedtest2mqtt avec docker compose ou docker run
sidebar_position: 1
---

# Installation

## Prérequis

- Docker et Docker Compose.
- Un broker MQTT joignable depuis le conteneur (Mosquitto, intégration MQTT de Home Assistant…).

## Docker Compose (recommandé)

```bash
make init            # crée config.yaml et .env depuis les exemples, sans rien écraser
```

Éditer ensuite :

- `config.yaml` : broker, nom du site, fréquence (voir [Configuration](configuration.md)) ;
- `.env` : `MQTT_USER` et `MQTT_PASS` (mode 600, jamais dans git).

Puis :

```bash
docker compose up -d
docker compose logs -f speedtest2mqtt
```

Le `docker-compose.yml` fourni :

```yaml
services:
  speedtest2mqtt:
    image: mathmath350/speedtest2mqtt:latest
    container_name: speedtest2mqtt
    restart: unless-stopped
    env_file: .env
    volumes:
      - ./config.yaml:/home/foo/config.yaml:ro
```

## Docker seul

Sans `config.yaml`, tout passe par variables d'environnement :

```bash
docker run -d --name speedtest2mqtt --restart unless-stopped \
  -e MQTT_HOST=192.168.1.10 -e MQTT_USER=user -e MQTT_PASS=changeme \
  -e SITE_NAME=Home -e CRON="0 * * * *" \
  mathmath350/speedtest2mqtt:latest
```

## Vérifier

Les logs affichent la version, le chargement de `config.yaml`, la déclaration des capteurs puis les valeurs
mesurées (download, upload, ping, jitter). Les entités apparaissent dans Home Assistant sous un appareil
« Speedtest2mqtt [Site] ».

## Licence Ookla

L'image utilise le CLI Ookla et **accepte automatiquement** la licence et le RGPD
(`--accept-license --accept-gdpr`). Usage personnel et non commercial uniquement :
[EULA](https://www.speedtest.net/about/eula), [conditions](https://www.speedtest.net/about/terms),
[confidentialité](https://www.speedtest.net/about/privacy). Ookla peut collecter des données considérées comme
personnelles (adresse IP, identifiants d'appareil, localisation).
