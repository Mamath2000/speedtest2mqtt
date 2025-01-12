#!/bin/bash
CRON=${CRON:-0 0,6,12,18 * * *}
echo "speedtest2mqtt has been started "

declare | grep -Ev 'BASHOPTS|BASH_VERSINFO|EUID|PPID|SHELLOPTS|UID' > /var/tmp/container.env
sed -i "/schedule1/c\    schedule: \"${CRON}\"" /home/foo/crontab.yml
sed -i "/schedule2/c\    schedule: \"@reboot\"" /home/foo/crontab.yml

echo "starting cron (${CRON})"
/yacronenv/bin/yacron -c /home/foo/crontab.yml
