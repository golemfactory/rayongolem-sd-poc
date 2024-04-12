ARG BASE
FROM ${BASE}

ARG RAY_ON_GOLEM_TAG
ENV RAY_ON_GOLEM_REPO="https://github.com/golemfactory/ray-on-golem"

WORKDIR /app

RUN curl -L ${RAY_ON_GOLEM_REPO}/archive/refs/tags/${RAY_ON_GOLEM_TAG}.zip -o ray-on-golem.zip
RUN RAY_ON_GOLEM_TAG_DIR=$(echo "$RAY_ON_GOLEM_TAG" | sed s/\\//-/) \
    && export RAY_ON_GOLEM_DIR="ray-on-golem-${RAY_ON_GOLEM_TAG_DIR}/" \
    && unzip ray-on-golem.zip \
        ${RAY_ON_GOLEM_DIR}pyproject.toml \
        ${RAY_ON_GOLEM_DIR}README.md \
        ${RAY_ON_GOLEM_DIR}ray_on_golem/* \
        -d tmp \
    && mv -v tmp/${RAY_ON_GOLEM_DIR}* .
RUN rm ray-on-golem.zip
RUN rm -r tmp

RUN poetry install --no-interaction --no-ansi --only ray

RUN pip config set global.index-url https://pypi.dev.golem.network/simple
RUN pip install pillow

RUN rm -r /root/.cache
RUN mv /root /root_copy

VOLUME /root
WORKDIR /root
