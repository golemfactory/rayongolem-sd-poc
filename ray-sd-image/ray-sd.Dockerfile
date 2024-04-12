ARG BASE
FROM ${BASE}

WORKDIR /app
COPY ray-sd-image/ray-sd.requirements.txt .
RUN pip install -r ray-sd.requirements.txt

WORKDIR /root