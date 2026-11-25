FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install --yes --no-install-recommends bash shellcheck \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY src/ src/
COPY test/main.sh test/verify.sh test/

USER 65534:65534
ENTRYPOINT ["bash", "test/main.sh"]
