FROM ghcr.io/userver-framework/ubuntu-22.04-userver@sha256:fca9c8ac7e97b4e2b042d822facbb152aec10a9d4e09c0862e44c50640f3f303

RUN apt-get update \
    && apt-get install -y --no-install-recommends clang-14 \
    && rm -rf /var/lib/apt/lists/*