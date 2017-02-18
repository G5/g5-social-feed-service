#!/bin/bash
set -e
source /codebase/dalton_check.sh

if [[ $DALTON_SHOULD_BUILD == "true" ]]; then
  cirunner notify $IMAGE_NAME $DALTON_TAG
fi
