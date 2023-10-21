#!/usr/bin/env bash
#
# checks some kafka tools on the generated image
#

BOOTSTRAP_SERVER_URI=${1:-localhost:9092}
REPLICATION_FACTOR=${2:-1}
PARTITIONS=${3:-3}

SAMPLE_TOPIC=sample-topic-$(uuidgen | tr "[:upper:]" "[:lower:]")

echo "💥 Create topic:"
docker run --rm kafka-tools kafka-topics.sh --bootstrap-server ${BOOTSTRAP_SERVER_URI} \
  --create --topic ${SAMPLE_TOPIC} \
  --partitions ${PARTITIONS} --replication-factor ${REPLICATION_FACTOR}

echo "💥 Describe topic:"
docker run --rm kafka-tools kafka-topics.sh --bootstrap-server ${BOOTSTRAP_SERVER_URI} --describe ${SAMPLE_TOPIC}

echo "💥 List topics:"
docker run --rm kafka-tools kafka-topics.sh --bootstrap-server ${BOOTSTRAP_SERVER_URI} --list
