#/bin/bash
SCRIPT_DIR=$(dirname $0)
REPO="blueshade/ray-on-golem"
PYTHON_VERSION="3.10.13"
docker build -t ${REPO}:cpu-base-py${PYTHON_VERSION} -f $SCRIPT_DIR/base-cpu.Dockerfile --build-arg "PYTHON_VERSION=$PYTHON_VERSION" .

RAY_VERSION="2.9.3"
RAY_ON_GOLEM_TAG="0.10.0a0"
RAY_ON_GOLEM_BASE_IMAGE="$REPO:$RAY_ON_GOLEM_TAG-$PYTHON_VERSION-$RAY_VERSION"
docker build -t $RAY_ON_GOLEM_BASE_IMAGE -f $SCRIPT_DIR/ray-on-golem.Dockerfile --build-arg "BASE=${REPO}:cpu-base-py${PYTHON_VERSION}" --build-arg "RAY_ON_GOLEM_TAG=$RAY_ON_GOLEM_TAG" .

RAY_SD_REPO="blueshade/rayongolem-sd-poc"
RAY_SD_IMG_TAG="1.0"
docker build -t $RAY_SD_REPO:$RAY_SD_IMG_TAG -f $SCRIPT_DIR/ray-sd.Dockerfile --build-arg "BASE=$RAY_ON_GOLEM_BASE_IMAGE" . && \
  gvmkit-build $RAY_SD_REPO:$RAY_SD_IMG_TAG && \
  gvmkit-build $RAY_SD_REPO:$RAY_SD_IMG_TAG --push
