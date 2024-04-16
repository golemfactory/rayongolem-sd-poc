ARG BASE
FROM ${BASE}

ARG RAY_ON_GOLEM_TAG
ENV RAY_ON_GOLEM_REPO="https://github.com/golemfactory/ray-on-golem"

RUN apt-get update \
    && apt-get install -y \
        openssh-server \
        iproute2 \
        nmap \
        tcpdump \
        net-tools \
        netcat-traditional \
        screen \
        rsyslog \
        rsync \
        vim \
        curl \
        wget \
        unzip \
        git \
        git-lfs \
        mc

RUN git lfs install
RUN rm -rf /var/lib/apt/lists/*

RUN echo "UseDNS no" >> /etc/ssh/sshd_config && \
	echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
	echo "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
	echo "StrictModes no" >> /etc/ssh/sshd_config && \
	echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config && \
	echo "ClientAliveCountMax 3" >> /etc/ssh/sshd_config

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
