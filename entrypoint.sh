#!/bin/sh

function topic() {
    python3 /publisher.py ${PUBSUB_PROJECT_ID} $@
}

function subscription() {
    python3 /subscriber.py ${PUBSUB_PROJECT_ID} $@
}

/wait-for.sh ${PUBSUB_EMULATOR_HOST}

# Split the comma separated topics
PUBSUB_TOPIC_ID=$(echo ${PUBSUB_TOPIC_ID} | tr ',' ' ')

# Split the comma separated subscriptions
PUBSUB_SUBSCRIPTION_ID=$(echo ${PUBSUB_SUBSCRIPTION_ID} | tr ',' ' ')

# A super dumb attempt at preventing collisions
sleep $(od -A n -N 2 -t u /dev/urandom | tr -d " " | rev | cut -c 1-1)

for TOPIC_ID in ${PUBSUB_TOPIC_ID}
do
    TOPIC_EXISTS=false

    for TOPIC in $(topic list)
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
        topic create "${TOPIC_ID}"
    fi

    for SUBSCRIPTION_ID in ${PUBSUB_SUBSCRIPTION_ID}
    do
        SUBSCRIPTION_EXISTS=false

        for SUBSCRIPTION in $(subscription list-in-topic ${TOPIC_ID})
        do
            # The string itself contains quotes so just escape them here for simplicity
            if [ ${SUBSCRIPTION} = \"projects/${PUBSUB_PROJECT_ID}/subscriptions/${TOPIC_ID}.${SUBSCRIPTION_ID}\" ]
            then
                echo "Subscription exists: name: ${TOPIC_ID}.${SUBSCRIPTION_ID}"
                SUBSCRIPTION_EXISTS=true
            fi
        done

        if [ "${SUBSCRIPTION_EXISTS}" = "false" ]
        then
            echo "Creating topic: ${TOPIC_ID}"
            subscription create "${TOPIC_ID}" "${TOPIC_ID}.${SUBSCRIPTION_ID}"
        fi

    done

done
