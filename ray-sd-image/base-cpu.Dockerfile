ARG PYTHON_VERSION
FROM python:${PYTHON_VERSION}-slim

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
        unzip \
    && rm -rf /var/lib/apt/lists/*

RUN echo "UseDNS no" >> /etc/ssh/sshd_config && \
	echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
	echo "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
	echo "StrictModes no" >> /etc/ssh/sshd_config && \
	echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config && \
	echo "ClientAliveCountMax 3" >> /etc/ssh/sshd_config

RUN pip install -U pip
RUN pip install poetry && \
    poetry config virtualenvs.create false
