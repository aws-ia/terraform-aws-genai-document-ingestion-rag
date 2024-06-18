#!/bin/bash
set -e


BASEDIR=$(dirname "$0")
echo "Script basedir is $BASEDIR"

cd $BASEDIR

echo "Current dir is $(pwd)"
docker build -t ${REPOSITORY_URL}:${IMAGE_NAME} .

docker push ${REPOSITORY_URL}:${IMAGE_NAME}
