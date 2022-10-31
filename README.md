# Camel K Kafka Metrics Bridge

## Local execution

Run the the kamelets logic through a Camel Quarkus [Route](etc/data/routes.yaml).

```sh
etc/scripts/start-kafka.sh

mvn clean quarkus:dev -DskipTests 

etc/scripts/inject.sh
etc/scripts/scrape.sh
```

## Deploy in OpenShift

Run the the kamelets logic through a [KameletBinding](k8s/03-kafka-metrics-binding.yaml) handled by the Camel K Operator.

**PREREQUISITE**: _Camel K Operator v1.10.2 or above_

**WARNING**: The current version of the Camel K Operator relies on the [Microprofile Metrics Component](https://camel.apache.org/components/3.18.x/microprofile-metrics-component.html). In future versions, it will be replaced by [Micrometer Component](https://camel.apache.org/components/3.18.x/micrometer-component.html), when it will happen the kamelet code will requires a limited refactoring.

### Kamelet deployment

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

### Test the behavior

Inject a message in Kafka:

```sh
oc exec -it my-cluster-kafka-0 -- bin/kafka-console-producer.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9092 \
  --topic metrics
```

When prompted (`>`) type in the following message: `{ "type": "counter", "name": "foo" }`

Inspect the metrics:

- Open a remote shell in the Kamelet pod:

  ```sh
  oc rsh (oc get pods -l camel.apache.org/integration=kafka-metrics -o=jsonpath='{.items[0].metadata.name}')
  ```

- Inside the pod probe the metrics:

  ```sh
  curl -s http://localhost:8080/q/metrics | grep foo
  ```

