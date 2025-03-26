FROM ubuntu/python:3.12-24.04_stable

RUN mkdir -p /shared_data/www/index /logs /output /configs

RUN apt-get update && apt-get install -y \
    procps \
    vim \
    tzdata \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

ENV TZ=UTC

ENV EDITOR=vim

WORKDIR /home

RUN git clone --single-branch --branch dev https://github.com/gm-ds/saber /home/
RUN pip install --no-cache-dir -r requirements.txt

ENV SABER_PASSWORD="toOverwrite"

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["serve"]