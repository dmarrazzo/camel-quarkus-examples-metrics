# Camel K Kafka Metrics Bridge

## Local execution

```sh
etc/scripts/start-kafka.sh

mvn clean quarkus:dev -DskipTests 

etc/scripts/inject.sh
etc/scripts/scrape.sh
```

## Deploy in OpenShift

```sh
oc new-project metrics
oc apply -f k8s/01-kafka.yaml
oc apply -f k8s/02-camel-k-ip.yaml
oc apply -f k8s/03-kafka-metrics-binding.yaml
```