#!/bin/bash
# Priorité : variable d'environnement > config.yaml > défaut (dans speedtest2mqtt.sh)
CONFIG_FILE=${CONFIG_FILE:-/home/foo/config.yaml}

if [ -f "$CONFIG_FILE" ]; then
    echo "chargement de ${CONFIG_FILE}"
    eval "$(/yacronenv/bin/python - "$CONFIG_FILE" <<'PY'
import os, shlex, sys
from ruamel.yaml import YAML
keys = ["mqtt_host", "mqtt_id", "mqtt_topic", "mqtt_options", "mqtt_user", "mqtt_pass",
        "discovery_topic", "site_name", "cron"]
cfg = YAML(typ="safe").load(open(sys.argv[1])) or {}
for k in keys:
    if k in cfg and cfg[k] is not None and k.upper() not in os.environ:
        print("export %s=%s" % (k.upper(), shlex.quote(str(cfg[k]))))
PY
)"
fi

CRON=${CRON:-0 0,6,12,18 * * *}
echo "speedtest2mqtt $(cat /opt/VERSION 2>/dev/null) has been started "

declare | grep -Ev 'BASHOPTS|BASH_VERSINFO|EUID|PPID|SHELLOPTS|UID' > /var/tmp/container.env
sed -i "/schedule1/c\    schedule: \"${CRON}\"" /home/foo/crontab.yml
sed -i "/schedule2/c\    schedule: \"@reboot\"" /home/foo/crontab.yml

echo "starting cron (${CRON})"
/yacronenv/bin/yacron -c /home/foo/crontab.yml
