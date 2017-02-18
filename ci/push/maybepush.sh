#!/bin/sh
set -e
source /codebase/dalton_check.sh

if [[ $DALTON_SHOULD_BUILD == "true" ]]; then
  echo "logging in as $DOCKER_USERNAME..."
  docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

  echo "retagging $IMAGE_NAME:$DALTON_TAG"
  docker tag production:latest $IMAGE_NAME:$DALTON_TAG

  echo "pushing $IMAGE_NAME:$DALTON_TAG"
  docker push $IMAGE_NAME:$DALTON_TAG
else echo "This is not a build that should be pushed, skipping";
fi
