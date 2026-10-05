---
title: Configuration
description: config.yaml, .env et variables d'environnement de speedtest2mqtt
sidebar_position: 2
---

# Configuration

Priorité : **variable d'environnement > `config.yaml` > valeur par défaut**.

## `config.yaml`

Monté en lecture seule dans le conteneur (`/home/foo/config.yaml`, modifiable via `CONFIG_FILE`).
Modèle : `config.example.yaml`. Les clés sont le nom de la variable en minuscules.

| Clé / variable | Défaut | Rôle |
|---|---|---|
| `mqtt_host` / `MQTT_HOST` | `localhost` | Broker MQTT |
| `mqtt_id` / `MQTT_ID` | `speedtest2mqtt` | Client ID MQTT |
| `mqtt_topic` / `MQTT_TOPIC` | `speedtest` | Préfixe des topics |
| `mqtt_options` / `MQTT_OPTIONS` | `-r` | Options passées à `mosquitto_pub` (`-r` = message retenu) |
| `discovery_topic` / `DISCOVERY_TOPIC` | `homeassistant` | Préfixe de discovery Home Assistant |
| `site_name` / `SITE_NAME` | `Home` | Nom du site : appareil HA et fin du topic |
| `cron` / `CRON` | `0 0,6,12,18 * * *` | Fréquence des tests (cron à 5 champs) |

## Identifiants (`.env`)

Modèle : `.env.example`. Fichier en mode 600, jamais dans git ni dans l'image.

| Variable | Défaut | Rôle |
|---|---|---|
| `MQTT_USER` | `user` | Utilisateur MQTT |
| `MQTT_PASS` | `pass` | Mot de passe MQTT |

Tout paramètre de `config.yaml` peut aussi être défini ici pour le surcharger.

## Exemples de `cron`

| Expression | Fréquence |
|---|---|
| `0 0,6,12,18 * * *` | 4 fois par jour (défaut) |
| `0 * * * *` | toutes les heures |
| `*/30 * * * *` | toutes les 30 minutes |

:::caution
Chaque test consomme de la bande passante (plusieurs centaines de Mo) : évitez les fréquences très élevées.
:::
