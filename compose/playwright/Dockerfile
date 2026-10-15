FROM ghcr.io/codelibs/fess:15.9.0-noble

# From 15.9 the Playwright crawler is a plugin and Node.js is no longer part of the
# distribution, so both are installed here along with the libraries Chromium needs.
RUN apt-get update && \
    apt-get install -y \
    libxcomposite1 libxfixes3 libatk1.0-0 libatk-bridge2.0-0 libxkbcommon0 libxdamage1 libgbm1 libasound2t64 libatspi2.0-0 \
    libpango-1.0-0 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    /usr/share/fess/bin/fess-setup install nodejs && \
    /usr/share/fess/bin/fess-setup install plugin fess-crawler-playwright:15.9.0 && \
    chown -R fess:fess /usr/share/fess/nodejs /usr/share/fess/app/WEB-INF/plugin
