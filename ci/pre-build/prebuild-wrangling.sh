#!/bin/bash
set -e

/codebase/ci/pre-build/write-gemfury-token.sh
cd /codebase
echo "Phoning home for build instructions..."
cirunner check $IMAGE_NAME

echo "Dalton says:"
cat dalton_check.sh
