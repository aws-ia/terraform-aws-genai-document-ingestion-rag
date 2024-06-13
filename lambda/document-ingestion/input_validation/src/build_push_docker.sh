#!/bin/bash
set -e
cd
# Variables
IMAGE_NAME="${REPOSITORY_URL}:latest"

BASEDIR=$(dirname "$0")
echo "script basedir is $BASEDIR"

cd $BASEDIR

echo "current dir is ${pwd}"

docker build  -t $IMAGE_NAME .

# Authenticate Docker with ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $REPOSITORY_URL

# Push the Docker image to ECR
docker push $IMAGE_NAME
