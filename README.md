# PubSub Emulator

Easy emulation for local development on Kubernetes.

## Example PubSub Emulator
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

## Example PubSub Init Container
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
            value: "my-local-topic"
```