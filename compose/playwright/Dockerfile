FROM ghcr.io/codelibs/fess:14.19.1

RUN apt-get update && \
    apt-get install -y \
    libatk1.0-0 libatk-bridge2.0-0 libxkbcommon0 libxdamage1 libgbm1 libasound2 libatspi2.0-0 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

