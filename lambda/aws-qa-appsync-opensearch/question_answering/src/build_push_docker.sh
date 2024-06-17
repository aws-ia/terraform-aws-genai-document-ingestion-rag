#!/bin/bash
set -e


BASEDIR=$(dirname "$0")
echo "Script basedir is $BASEDIR"

cd $BASEDIR

echo "Current dir is $(pwd)"

docker build -t ${REPOSITORY_URL}:${IMAGE_NAME} .

if ! docker system info | grep -q "$REPOSITORY_URL"; then
#if ! docker system info | grep -q "$REPOSITORY_URL"; then
    echo "Authenticating Docker with ECR..."
    if ! aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $REPOSITORY_URL; then
        echo "Failed to authenticate to ECR"
        exit 1
    fi
else
    echo "Already logged in to $REPOSITORY_URL"
fi

docker push ${REPOSITORY_URL}:${IMAGE_NAME}
