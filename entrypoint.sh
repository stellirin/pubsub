#!/bin/sh

function pubsub() {
    python /publisher.py ${PUBSUB_PROJECT_ID} $@
}

/wait-for.sh ${PUBSUB_EMULATOR_HOST}

# A super dumb attempt at preventing collisions
sleep $(od -A n -N 2 -t u /dev/urandom | tr -d " " | rev | cut -c 1-1)

for TOPIC in $(pubsub list)
do
    # The string itself contains quotes so just escape them here for simplicity
    if [ ${TOPIC} = \"projects/${PUBSUB_PROJECT_ID}/topics/${PUBSUB_TOPIC_ID}\" ]
    then
        echo "Topic exists: name: ${TOPIC}"
        exit 0
    fi
done

pubsub create ${PUBSUB_TOPIC_ID}
