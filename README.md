# Camel K Kafka Metrics Bridge

## Local execution

```sh
etc/scripts/start-kafka.sh

mvn clean quarkus:dev -DskipTests 

etc/scripts/inject.sh
etc/scripts/scrape.sh
```

## Deploy in OpenShift


Create a project, the Kafka broker and a topic:

```sh
oc new-project metrics
oc apply -f k8s/01-kafka.yaml
```

Install the Integration Platform and the Kamelets:

```sh
oc apply -f k8s/02-camel-k-ip.yaml
oc apply -f src/main/resources/kamelets/ephemeral-kafka-source.kamelet.yaml
oc apply -f src/main/resources/kamelets/metrics-bridge.kamelet.yaml
```

Deploy the KameletBinding:

```sh
oc apply -f k8s/03-kafka-metrics-binding.yaml
```