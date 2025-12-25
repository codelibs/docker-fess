FROM ghcr.io/codelibs/fess:15.4.0-noble

RUN apt-get update && \
    apt-get install -y \
    libxcomposite1 libxfixes3 libatk1.0-0 libatk-bridge2.0-0 libxkbcommon0 libxdamage1 libgbm1 libasound2t64 libatspi2.0-0 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

