ARG PYTHON_VERSION
FROM python:${PYTHON_VERSION}-slim

RUN pip install -U pip
RUN pip install poetry && \
    poetry config virtualenvs.create false
