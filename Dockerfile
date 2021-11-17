# syntax=docker/dockerfile:1
FROM python:3.9.9-slim-buster

ENV PYTHONUNBUFFERED=1

RUN apt-get update && \
    apt-get install -y jq unzip curl && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install
    

WORKDIR /code
COPY requirements.txt /code/

COPY scripts/entrypoint /entrypoint
RUN sed -i 's/\r//' /entrypoint
RUN chmod +x /entrypoint

RUN pip install -r requirements.txt
COPY . /code/

ENTRYPOINT ["/entrypoint"]