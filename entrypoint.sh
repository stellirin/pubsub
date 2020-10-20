#!/bin/sh

function pubsub() {
    python3 /publisher.py ${PUBSUB_PROJECT_ID} $@
}

/wait-for.sh ${PUBSUB_EMULATOR_HOST}

# Split the comma separated topics
PUBSUB_TOPIC_ID=$(echo ${PUBSUB_TOPIC_ID} | tr ',' ' ')

# A super dumb attempt at preventing collisions
sleep $(od -A n -N 2 -t u /dev/urandom | tr -d " " | rev | cut -c 1-1)

for TOPIC_ID in ${PUBSUB_TOPIC_ID}
do
    TOPIC_EXISTS=false

    for TOPIC in $(pubsub list)
    do
        # The string itself contains quotes so just escape them here for simplicity
        if [ ${TOPIC} = \"projects/${PUBSUB_PROJECT_ID}/topics/${TOPIC_ID}\" ]
        then
            echo "Topic exists: name: ${TOPIC_ID}"
            TOPIC_EXISTS=true
        fi
    done

    if [ "${TOPIC_EXISTS}" = "false" ]
    then
        echo "Creating topic: ${TOPIC_ID}"
        pubsub create ${TOPIC_ID}
    fi

done
