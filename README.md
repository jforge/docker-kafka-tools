# Yet another kafka tools image

This image contains the official Kafka binaries with focus 
on running command line tools for working with Kafka topics.

A secondary goal is to minimize the image size.

## Another extra kafka tools image?

We face since years the bad practice of docker images permanently increasing
in size with even simple requirements for using tools with simple scripts.

With Kafka, I don't want to have a pure Kafka client tools image based on the
kafka server images like from confluent reaching 1 GB in size. They contain
everything we need, but 1 GB for calling a script to list topics is unacceptable.

On the other hand, I wanted to be still with Java, so I don't care about 
alternative solutions (right now), sorry ;-)

## Build

The minimal image size of 145 MB was reachable with an 
OpenJDK base image plus some Kafka cleanup:

```
docker build -f Dockerfile.alpine.openjdk-jre-alpine -t jforge/kafka-tools .
```

Override Java version for the Dockerfile based on alpine:

```
docker build -f Dockerfile.alpine --build-arg JAVA_VERSION=17 -t jforge/kafka-tools .
```

### Different base images

Kafka still supports Java 8 in Kafka 3.6, but this will disappear in future release.
Still, the JRE 8 image is the smallest compared to newer JREs:

| Base Image               | Java | Image Size (minimized) |
|:-------------------------|-----:|-----------------------:|
| alpine:3.18              |    8 |                 164 MB |
| alpine:3.18              |   11 |                 239 MB |
| alpine:3.18              |   17 |                 266 MB |
| alpine:3.18 + python-dev |   17 |                 564 MB |
| __openjdk jre alpine__   |    8 |             __145 MB__ |
| corretto jre alpine      |    8 |                 177 MB |

`OpenJDK` images are deprecated, but I prefer the JRE 8 due to the minimal image size.
Switch to `Amazon Corretto`, if you prefer non-deprecated base images.

Further information:

- I haven't investigated the Java runtime images from `ìbm-semeru-runtimes`, `imbjava`, `sapmachine` 
any further (they seem all to be bigger).
- For `eclipse-temurin` Java runtime images a simple test shows heap space errors, which seem to be resolvable
with adding the security option `--security-opt seccomp=unconfined` to the docker run call.
See [Seccomp security profiles for Docker](https://docs.docker.com/engine/security/seccomp/) for details.
For me, this adds unacceptable user-facing complexity, therefore skipped.
- The alternative which includes the [Python kafka-tools](https://pypi.org/project/kafka-tools/) is not 
efficiently created (777 MB image size), I left it here for some special case.
- The applied cleanup includes removing a very big jar file for a Kafka Streams dependency to RocksDB. 
So far, I didn't see a toxic effect.
Please notify me in case, you get into trouble with this.

## Run

```
docker run --rm kafka-tools kafka-topics.sh <args>
```

## Examples

### Create a topic
```
docker run --rm kafka-tools kafka-topics.sh \
    --bootstrap-server localhost:9092 \
    --create --topic sample-topic \
    --partitions 20 --replication-factor 3
```

### Describe topic

```
docker run --rm kafka-tools kafka-topics.sh \
    --bootstrap-server localhost:9092 \
    --describe sample-topic
```

### List topics

```
docker run --rm kafka-tools kafka-topics.sh \
    --bootstrap-server localhost:9092 \
    --list
```

### Publish events

```
docker run --rm -it kafka-tools kafka-console-producer.sh \
    --bootstrap-server localhost:9092 \
    --topic sample-topic
```

### Consume events

```
docker run --rm -it kafka-tools kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic sample-topic --from-beginning
```


## References

- [Kafka Basic operations](http://kafka.apache.org/documentation.html#basic_ops)
- [Kafka Java prerequisites](https://kafka.apache.org/documentation.html#java)
- [Docker Hub Amazon Corretto](https://hub.docker.com/_/amazoncorretto)
- [Docker Hub OpenJDK](https://hub.docker.com/_/openjdk)
