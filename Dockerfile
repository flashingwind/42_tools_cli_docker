FROM python:3.10-alpine

LABEL "maintainer"="miida < miida@student.42tokyo.jp>"
LABEL "repository"="https://github.com/flashingwind/docker_42_c_tools"

RUN apk update && \
    apk add alpine-sdk cmake clang clang-extra-tools libressl-dev bash vim nano

RUN pip install --upgrade pip \
&& python3 -m pip install --disable-pip-version-check --no-cache-dir norminette
&& python3 -m pip install --disable-pip-version-check --no-cache-dir c-formatter-42 \

WORKDIR /code

