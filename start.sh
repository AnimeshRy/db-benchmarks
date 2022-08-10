#!/bin/bash
set -e
usage()
{
    cat << USAGE >&2
Usage:s]
    -d DATABASE | --database=DATABASE       Database name default
    -b | --build       Rebuild docker image
USAGE
    exit 1
}
DATABASES="postgresql mysql mariadb sqlite"
BUILD=0
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -d|--database)
      DATABASES="$2"
      shift # past argument
      shift # past value
      ;;
    -b|--build)
      BUILD=1
      echo "with build"
      shift # past argument
      ;;
    *)    # unknown option
      usage
      ;;
    -h|--help)
      usage
      ;;
  esac
done
if [ $BUILD -eq 1 ]; then
  CONF="docker/postgresql/docker-compose.yml"
  docker-compose -p ddbench -f $CONF build
fi
for DATABASE in $DATABASES
  do
    CONF="docker/$DATABASE/docker-compose.yml"
    echo "Testing $DATABASE"
    docker-compose -p ddbench -f $CONF run django
    docker-compose -p ddbench -f $CONF down
  done
python create_graph.py