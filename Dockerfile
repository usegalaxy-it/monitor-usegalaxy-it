FROM python:3.9-slim

RUN mkdir -p /shared_data/www/index
RUN mkdir /logs
RUN mkdir /output
RUN mkdir /configs

RUN apt-get update && apt-get install -y \
    procps \
    tzdata \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

ENV TZ=UTC

WORKDIR /home

RUN git clone --single-branch --branch dev https://github.com/gm-ds/saber /home/
RUN pip install --no-cache-dir -r requirements.txt

ENV SABER_PASSWORD="toOverwrite"

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["serve"]