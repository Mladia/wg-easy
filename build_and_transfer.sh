#!/bin/bash
set -e

IMAGE_NAME=wg-easy:node-23
TAR_FILE=wg-easy.tar
DOCKERFILE_DIR=/home/nmlad/Repos/wg-easy
REMOTE_HOST=sunflower

echo "Building Docker image..."
docker build -t ${IMAGE_NAME} ${DOCKERFILE_DIR}

echo "Saving Docker image to tar file..."
docker save ${IMAGE_NAME} -o ${TAR_FILE}

echo "Transferring tar file to remote host ${REMOTE_HOST}..."
scp ${TAR_FILE} ${REMOTE_HOST}:~/

echo "Loading Docker image on remote host..."
ssh ${REMOTE_HOST} "docker load -i ~/${TAR_FILE} && rm ~/${TAR_FILE}"

echo "Cleaning up local tar file..."
rm ${TAR_FILE}

echo "Done."