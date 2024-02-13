#!/bin/bash
MQTT_HOST=${MQTT_HOST:-localhost}
MQTT_ID=${MQTT_ID:-speedtest2mqtt}
MQTT_TOPIC=${MQTT_TOPIC:-speedtest}
MQTT_OPTIONS=${MQTT_OPTIONS:-"-r"}
MQTT_USER=${MQTT_USER:-user}
MQTT_PASS=${MQTT_PASS:-pass}

DISCOVERY_TOPIC=${DISCOVERY_TOPIC:-homeassistant}
SITE_NAME=${SITE_NAME:-Home}
# TOPIC="${MQTT_TOPIC}/${SITE_NAME}"

## /////////////////////////////////////////////////////////////////////////////////////////////////
function createSensor_entity {
    
    local name="Speedtest2mqtt [${SITE_NAME}]"
    field=$(echo $1 | tr . _ | tr ' ' _ | tr - _ | tr '[:upper:]' '[:lower:]')
    local value_template=$2

    site=$(echo $SITE_NAME | tr . _ | tr ' ' _ | tr - _ | tr '[:upper:]' '[:lower:]')

    local unique_id="speedtest_${site}_${field}"
    local topic="${MQTT_TOPIC}/${site}"

    local icon="mdi:speedometer"
    if [ "$field" = "download" ] || [ "$field" = "upload" ]; then
        JSON_STRING='{
            "unique_id":"%s",
            "object_id":"%s",
            "name":"%s",
            "icon":"%s",
            "force_update":true,
            "has_entity_name":true,
            "unit_of_measurement":"Mbit/s",
            "device_class":"data_rate",
            "state_class":"measurement",
            "state_topic": "%s",
            "value_template": "%s",
            "device": {"identifiers":["speedtest_%s"],"manufacturer":"Mamath2000","name":"%s"},
            "json_attributes_topic":"%s",
            "json_attributes_template": "{{ value_json |tojson }}" }\n'
        PAYLOAD=`printf "$JSON_STRING" "${unique_id}" "${unique_id}" "$1" "${icon}" "${topic}" "${value_template}" "${site}" "${name}" "${topic}"`

    elif [ "$field" = "ping" ]; then
        JSON_STRING='{
            "unique_id":"%s",
            "object_id":"%s",
            "name":"%s",
            "icon":"%s",
            "force_update":true,
            "has_entity_name":true,
            "unit_of_measurement":"ms",
            "state_class":"measurement",
            "state_topic": "%s",
            "value_template": "%s",
            "device": {"identifiers":["speedtest_%s"],"manufacturer":"Mamath2000","name":"%s"},
            "json_attributes_topic":"%s",
            "json_attributes_template": "{{ value_json |tojson }}" }\n'
        PAYLOAD=`printf "$JSON_STRING" "${unique_id}" "${unique_id}" "$1" "${icon}" "${topic}"  "${value_template}" "${site}" "${name}" "${topic}"`

    else
        JSON_STRING='{
            "unique_id":"%s",
            "object_id":"%s",
            "name":"%s",
            "force_update":true,
            "has_entity_name":true,
            "entity_category": "diagnostic",
            "state_topic": "%s",
            "value_template": "%s",
            "icon": "mdi:server-outline",
            "device": {"identifiers":["speedtest_%s"],"manufacturer":"Mamath2000","name":"%s"},
            "json_attributes_topic":"%s",
            "json_attributes_template": "{{ value_json |tojson }}" }\n'
        PAYLOAD=`printf "$JSON_STRING" "${unique_id}" "${unique_id}" "$1" "${topic}" "${value_template}" "${site}" "${name}" "${topic}"`
    fi

    echo "Publish "$1" sensor for ${name}"
    /usr/bin/mosquitto_pub -r -h $MQTT_HOST \
        -u ${MQTT_USER} \
        -P ${MQTT_PASS} \
        -t "${DISCOVERY_TOPIC}/sensor/${MQTT_TOPIC}_${site}/${field}/config" \
        -m "$PAYLOAD"
}

## /////////////////////////////////////////////////////////////////////////////////////////////////
## DECLAR SENSORS IN HOME ASSISTANT
echo "Déclaration de l'entité Update (Home Assistant)"

createSensor_entity "Download" "{{ value_json.download | float(default=0) | round(0) }}"
createSensor_entity "Upload" "{{ value_json.upload | float(default=0) | round(0) }}"
createSensor_entity "Ping" "{{ value_json.ping | float(default=0) | round(0) }}"
createSensor_entity "Server name" "{{ value_json.servername }}"
createSensor_entity "Server host" "{{ value_json.serverhost }}"
createSensor_entity "Server country" "{{ value_json.servercountry }}"
createSensor_entity "Server id" "{{ value_json.serverid }}"
createSensor_entity "Server location" "{{ value_json.serverlocation }}"
createSensor_entity "Timestamp" "{{ as_datetime(value_json.timestamp).astimezone() }}"

file=~/ookla.json

echo "$(date -Iseconds) starting speedtest"

speedtest --accept-license --accept-gdpr -f json-pretty > ${file}

downraw=$(jq -r '.download.bandwidth' ${file})
download=$(printf %.2f\\n "$((downraw * 8))e-6")
upraw=$(jq -r '.upload.bandwidth' ${file})
upload=$(printf %.2f\\n "$((upraw * 8))e-6")
ping=$(jq -r '.ping.latency' ${file})
jitter=$(jq -r '.ping.jitter' ${file})
packetloss=$(jq -r '.packetLoss' ${file})
serverid=$(jq -r '.server.id' ${file})
servername=$(jq -r '.server.name' ${file})
servercountry=$(jq -r '.server.country' ${file})
serverlocation=$(jq -r '.server.location' ${file})
serverhost=$(jq -r '.server.host' ${file})
timestamp=$(jq -r '.timestamp' ${file})

echo "$(date -Iseconds) speedtest results"

echo "$(date -Iseconds) download = ${download} Mbps"
echo "$(date -Iseconds) upload =  ${upload} Mbps"
echo "$(date -Iseconds) ping =  ${ping} ms"
echo "$(date -Iseconds) jitter = ${jitter} ms"

JSON_STRING='{
    "download":"%s",
    "downraw":"%s",
    "upload":"%s",
    "upraw":"%s",
    "ping":"%s",
    "packetloss":"%s",
    "jitter":"%s",
    "serverid":"%s",
    "servername":"%s",
    "servercountry":"%s",
    "serverlocation":"%s",
    "serverhost":"%s",
    "timestamp":"%s"}\n'
PAYLOAD=`printf "$JSON_STRING" "${download}" "${downraw}" "${upload}" "${upraw}" "${ping}" "${jitter}" "${packetloss}" "${serverid}" "${servername}" "${servercountry}" "${serverlocation}" "${serverhost}" "${timestamp}"`

echo $PAYLOAD
topic="${MQTT_TOPIC}/$(echo $SITE_NAME | tr . _ | tr ' ' _ | tr - _ | tr '[:upper:]' '[:lower:]')"

/usr/bin/mosquitto_pub \
        ${MQTT_OPTIONS} \
        -h ${MQTT_HOST} \
        -i ${MQTT_ID} \
        -u ${MQTT_USER} -P ${MQTT_PASS} \
        -t ${topic} -m "${PAYLOAD}"

echo "$(date -Iseconds) sending results to ${MQTT_HOST} as clientID ${MQTT_ID} with options ${MQTT_OPTIONS} using user ${MQTT_USER}"
