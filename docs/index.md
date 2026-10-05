---
id: index
title: speedtest2mqtt
description: Mesure de bande passante Ookla Speedtest publiée sur MQTT avec auto-discovery Home Assistant
sidebar_position: 0
---

# speedtest2mqtt

Image Docker (Alpine) qui exécute périodiquement le [CLI Ookla Speedtest](https://www.speedtest.net/apps/cli),
publie le résultat en JSON sur un broker MQTT et déclare les capteurs dans Home Assistant par auto-discovery.

- Installation et premier lancement : [Installation](installation.md)
- Paramètres `config.yaml` / `.env` : [Configuration](configuration.md)
- Capteurs, topics et format des messages : [Home Assistant et MQTT](home-assistant.md)
- Architecture, build et release : [Développement](developpement.md)

## Fonctionnement

1. Au démarrage du conteneur, un test est lancé immédiatement, puis selon l'expression `cron`
   (par défaut 4 fois par jour : 0 h, 6 h, 12 h, 18 h).
2. Chaque exécution publie d'abord la déclaration des capteurs (topic de discovery, retenu), puis lance le test.
3. Le résultat est publié (retenu par défaut) sur `<mqtt_topic>/<site_name normalisé>`.

Une exécution ne peut pas en chevaucher une autre (`concurrencyPolicy: Forbid`).

## Contenu du dépôt

| Chemin | Rôle |
|---|---|
| `src/` | Code embarqué dans l'image : `entrypoint.sh`, `speedtest2mqtt.sh`, `crontab.yml` |
| `docs/` | Cette documentation (compatible Docusaurus) |
| `Dockerfile` | Image Alpine : `speedtest`, `mosquitto-clients`, `jq`, `yacron` |
| `Makefile`, `docker-release.sh`, `VERSION` | Build et release |
| `config.example.yaml`, `.env.example`, `docker-compose.yml` | Modèles de déploiement |
