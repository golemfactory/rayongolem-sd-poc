#/bin/bash
SCRIPT_DIR=$(dirname $0)
REPO="blueshade/ray-on-golem"
PYTHON_VERSION="3.10.13"
docker build -t ${REPO}:cpu-base-py${PYTHON_VERSION} -f $SCRIPT_DIR/base-cpu.Dockerfile --build-arg "PYTHON_VERSION=$PYTHON_VERSION" .

RAY_VERSION="2.9.3"
RAY_ON_GOLEM_TAG="0.10.0a0"

docker build -t $REPO:$RAY_ON_GOLEM_TAG-$PYTHON_VERSION-$RAY_VERSION -f $SCRIPT_DIR/ray-on-golem.Dockerfile --build-arg "BASE=${REPO}:cpu-base-py${PYTHON_VERSION}" --build-arg "RAY_ON_GOLEM_TAG=$RAY_ON_GOLEM_TAG" .
