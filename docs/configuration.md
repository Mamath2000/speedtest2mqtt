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

## Syntaxe de `cron`

Une expression `cron` contient **5 champs** séparés par des espaces :

```
0 0,6,12,18 * * *
```

| Champ | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| Rôle | minute | heure | jour du mois | mois | jour de la semaine |
| Valeurs permises | 0-59 | 0-23 | 1-31 | 1-12 | 0-7 (0 et 7 = dimanche) |
| Dans l'exemple | `0` | `0,6,12,18` | `*` | `*` | `*` |

Dans un champ :

| Symbole | Sens | Exemple |
|---|---|---|
| `*` | toutes les valeurs | `*` en heure = chaque heure |
| `,` | liste de valeurs **dans le même champ** | `0,6,12,18` en heure = à 0 h, 6 h, 12 h et 18 h |
| `-` | plage | `8-20` en heure = de 8 h à 20 h |
| `/` | pas | `*/30` en minute = toutes les 30 minutes |

La virgule ne sépare donc **pas** plusieurs expressions cron : `0 0,6,12,18 * * *` est une seule expression
« à la minute 0, aux heures 0, 6, 12 et 18, tous les jours ». À ne pas confondre avec `18 * * * *`, où le `18` est
la **minute** (chaque heure à HH:18).

Garder 5 champs : un 6ᵉ champ est lu comme l'année, sans effet utile ici.

## Exemples de `cron`

| Expression | Fréquence |
|---|---|
| `0 0,6,12,18 * * *` | 4 fois par jour, à 0 h, 6 h, 12 h, 18 h (défaut) |
| `0 * * * *` | toutes les heures, à la minute 0 |
| `*/30 * * * *` | toutes les 30 minutes |
| `15 7 * * 1-5` | à 7 h 15, du lundi au vendredi |

:::caution
Chaque test consomme de la bande passante (plusieurs centaines de Mo) : évitez les fréquences très élevées.
:::
