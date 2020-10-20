# PubSub Emulator

Easy emulation for local development on Kubernetes.

The `emulator` tag simply wraps the official PubSub emulator into a container.

The `init` tag can be used as an init container to create PubSub topics prior to starting the main service. It uses [wait-for](https://github.com/eficode/wait-for) to test if the pubsub emulator is alive.

## PubSub Emulator Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pubsub
  labels:
    app: pubsub

spec:
  replicas: 1
  selector:
    matchLabels:
      app: pubsub
  template:
    metadata:
      labels:
        app: pubsub
    spec:
      containers:
      - name: pubsub
        image: stellirin/pubsub:emulator
        imagePullPolicy: Always
        ports:
          - name: pubsub
            containerPort: 8085
```

## Init Container

PubSub topics on GCP are of the form `projects/project/topics/topic`. The emulator creates topics using the environment variables below:

### `PUBSUB_EMULATOR_HOST`

The URL to a PubSub emulator.

### `PUBSUB_PROJECT_ID`

A PubSub project ID.

### `PUBSUB_TOPIC_ID`

A PubSub topic ID. May be a comma separated list of topics to create multiple topics.

### Example

```yaml
initContainers:
  - name: pubsub
      image: stellirin/pubsub:init
      env:
        - name: PUBSUB_EMULATOR_HOST
            value: "pubsub:8085"
        - name: PUBSUB_PROJECT_ID
            value: "my-local-project"
        - name: PUBSUB_TOPIC_ID
            value: "my-local-topic-01,my-local-topic-02"
```

NOTE: The emulator automaticaly creates a subscription if it doesn't exist when a service asks for it.
