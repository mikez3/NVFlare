#!/bin/bash
#
# Copyright (c) 2022, NVIDIA CORPORATION. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Argument(s):
#   BUILD_TYPE:   pytorch | tensorflow, tests to execute

set -ex
BUILD_TYPE=pytorch

if [[ $# -eq 1 ]]; then
    BUILD_TYPE=$1

elif [[ $# -gt 1 ]]; then
    echo "ERROR: too many parameters are provided"
    exit 1
fi

init_pipenv() {
    echo "initializing pip environment: $1"
    pipenv install -r $1
    export PYTHONPATH=$PWD
}

remove_pipenv() {
    echo "removing pip environment"
    pipenv --rm
    rm Pipfile Pipfile.lock
}

integration_test_pt() {
    echo "Run PT integration test..."
    init_pipenv requirements-dev.txt
    testFolder="tests/integration_test"
    rm -rf /tmp/snapshot-storage
    pushd ${testFolder}
    pipenv run ./run_integration_tests.sh -m pytorch
    popd
    rm -rf /tmp/snapshot-storage
    remove_pipenv
}

integration_test_tf() {
    echo "Run TF integration test..."
    # not using pipenv because we need tensorflow package from the container
    python -m pip install -r requirements-dev.txt
    export PYTHONPATH=$PWD
    testFolder="tests/integration_test"
    rm -rf /tmp/snapshot-storage
    pushd ${testFolder}
    ./run_integration_tests.sh -m tensorflow
    popd
    rm -rf /tmp/snapshot-storage
}

case $BUILD_TYPE in

    tensorflow)
        echo "Run TF tests..."
        integration_test_tf
        ;;

    pytorch)
        echo "Run PT tests..."
        integration_test_pt
        ;;

    *)
        echo "ERROR: unknown parameter: $BUILD_TYPE"
        ;;
esac


