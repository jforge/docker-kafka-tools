#!/usr/bin/env bash
#
# checks some kafka tools on the generated image
#
function usage {
    printf "Usage:\n"
    printf "$0 --bootstrap-server|-bs <hostname:port> [--replication|-r <replication-factor>] [--partitions|-p <number_of_partitions>] [--topic|-t <topic name>]\n"
    exit 1
}

function argparse {
  echo "Parameters: $*"

  if [ $# -eq 0 ]; then
      usage
  fi

  while [ $# -gt 0 ]; do
    case "$1" in
      --bootstrap-server|-bs)
        # the URI authority of a kafka cluster bootstrap-server, e.g. localhost:9092
        export BOOTSTRAP_SERVER_URI="${2}"
        shift
        ;;
      --replication|-r)
        # optional: the number of replicas to spread over the brokers of the cluster (default: 1)
        export REPLICATION_FACTOR="${2}"
        shift
        ;;
      --partitions|-p)
        # optional: number of partitions for the topic (default: 1)
        export PARTITIONS=${2}
        shift
        ;;
      --topic|-t)
        # optional: name of the topic to test with (default: sample-topic-<random-uuid>)
        export SAMPLE_TOPIC="${2}"
        shift
        ;;
      *)
        printf "ERROR: Parameters invalid\n"
        usage
    esac
    shift
  done
}

#
# init
export BOOTSTRAP_SERVER_URI="localhost:9092"
export REPLICATION_FACTOR=1
export PARTITIONS=1
export SAMPLE_TOPIC=sample-topic-$(uuidgen | tr "[:upper:]" "[:lower:]")

argparse $*

if [ -z "${BOOTSTRAP_SERVER_URI}" ]; then
  usage
fi

echo "💥 Create topic:"
docker run --rm jforge/kafka-tools kafka-topics.sh --bootstrap-server ${BOOTSTRAP_SERVER_URI} \
  --create --topic ${SAMPLE_TOPIC} \
  --partitions ${PARTITIONS} --replication-factor ${REPLICATION_FACTOR}

echo "💥 Describe topic:"
docker run --rm jforge/kafka-tools kafka-topics.sh --bootstrap-server ${BOOTSTRAP_SERVER_URI} --describe --topic ${SAMPLE_TOPIC}

echo "💥 List topics:"
docker run --rm jforge/kafka-tools kafka-topics.sh --bootstrap-server ${BOOTSTRAP_SERVER_URI} --list
