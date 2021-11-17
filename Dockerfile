# syntax=docker/dockerfile:1
FROM python:3

ARG secret_id=parrot_db_secret
ARG aws_region=sa-east-1

ENV AWS_SECRET_ID=$secret_id
ENV AWS_REGION=$aws_region

ENV PYTHONUNBUFFERED=1

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
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