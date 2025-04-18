FROM ubuntu:latest

RUN mkdir -p /shared_data/www/index /logs /output /configs

RUN apt-get update && apt-get install -y \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    python3-pip \
    procps \
    vim \
    tzdata \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

ENV TZ=UTC

ENV EDITOR=vim

WORKDIR /home/saber

RUN git clone --single-branch --branch main https://github.com/gm-ds/saber /home/saber/

RUN python3.12 -m venv /home/saber/venv
RUN /home/saber/venv/bin/pip install --upgrade pip
RUN /home/saber/venv/bin/pip install --no-cache-dir -r /home/saber/requirements.txt

ENV PATH="/home/saber/venv/bin:$PATH"


ENV SABER_PASSWORD="toOverwrite"

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["serve"]