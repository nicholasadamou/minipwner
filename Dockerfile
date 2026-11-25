FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install --yes --no-install-recommends bash shellcheck \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY install.sh test.sh ./
COPY OVERLAY/ OVERLAY/
USER 65534:65534
CMD ["bash", "test.sh"]
