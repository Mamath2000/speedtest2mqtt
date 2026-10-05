---
title: Home Assistant et MQTT
description: Capteurs auto-découverts, topics et format du message JSON
sidebar_position: 3
---

# Home Assistant et MQTT

## Normalisation du nom de site

`site_name` est mis en minuscules et les `.`, espaces et `-` sont remplacés par `_` :
`Maison Paris` devient `maison_paris`. Ce nom (`<site>`) sert dans les topics et les identifiants.

## Topics

| Rôle | Topic |
|---|---|
| Résultat (état) | `<mqtt_topic>/<site>` |
| Discovery d'un capteur | `<discovery_topic>/sensor/<mqtt_topic>_<site>/<champ>/config` |

Les déclarations sont publiées avec `-r` (retenues) à chaque exécution.

## Capteurs

Tous regroupés dans l'appareil `Speedtest2mqtt [<site_name>]`, `unique_id` = `speedtest_<site>_<champ>`.

| Capteur | Unité | Classe | Notes |
|---|---|---|---|
| Download | Mbit/s | `data_rate` | mesure |
| Upload | Mbit/s | `data_rate` | mesure |
| Ping | ms | — | mesure |
| Server name, host, country, id, location | — | — | catégorie « diagnostic » |
| Timestamp | — | — | date du test |

Chaque capteur expose le message JSON complet en attributs.

## Message JSON

```json
{
  "download": "754.16",
  "downraw": "94270299",
  "upload": "672.80",
  "upraw": "84099576",
  "ping": "17.630",
  "packetloss": "0",
  "jitter": "0.535",
  "serverid": "52534",
  "servername": "Virtual Technologies and Solutions",
  "servercountry": "France",
  "serverlocation": "Paris",
  "serverhost": "speedtest-prs.vts.bf",
  "timestamp": "2024-02-13T14:37:17Z"
}
```

`download` et `upload` sont en Mbit/s (arrondis à 2 décimales), `downraw` et `upraw` en octets/s tels que
renvoyés par Ookla. Un exemple complet de sortie brute du CLI est dans [`sample.json`](sample.json).
