# Camel K Kafka Metrics Bridge

## Local execution

```sh
etc/scripts/start-kafka.sh

mvn clean quarkus:dev -DskipTests 

etc/scripts/inject.sh
etc/scripts/scrape.sh
```

## Deploy in OpenShift

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

