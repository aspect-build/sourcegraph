# This Dockerfile was generated from github.com/sourcegraph/godockerize. It
# was not written by a human, and as such looks janky. As you change this
# file, please don't be scared to make it more pleasant / remove hadolint
# ignores.

# Install p4 CLI (keep this up to date with cmd/server/Dockerfile)
FROM sourcegraph/alpine-3.14:200740_2023-02-22_a1b4fb9100c1@sha256:a5b6731db64e742e1e11d31df443d60f756d892bc90d4581c5ddbfe4259d1302 AS p4cli

# hadolint ignore=DL3003
RUN wget http://cdist2.perforce.com/perforce/r21.2/bin.linux26x86_64/p4 && \
    mv p4 /usr/local/bin/p4 && \
    chmod +x /usr/local/bin/p4

FROM sourcegraph/alpine-3.14:200740_2023-02-22_a1b4fb9100c1@sha256:a5b6731db64e742e1e11d31df443d60f756d892bc90d4581c5ddbfe4259d1302 AS p4-fusion

COPY p4-fusion-install-alpine.sh /p4-fusion-install-alpine.sh
RUN /p4-fusion-install-alpine.sh

FROM sourcegraph/alpine-3.14:200740_2023-02-22_a1b4fb9100c1@sha256:a5b6731db64e742e1e11d31df443d60f756d892bc90d4581c5ddbfe4259d1302 AS coursier

RUN wget -O coursier.gz https://github.com/coursier/coursier/releases/download/v2.1.0-RC4/cs-x86_64-pc-linux-static.gz && \
    gzip -d coursier.gz && \
    mv coursier /usr/local/bin/coursier && \
    chmod +x /usr/local/bin/coursier

FROM sourcegraph/alpine-3.14:200740_2023-02-22_a1b4fb9100c1@sha256:a5b6731db64e742e1e11d31df443d60f756d892bc90d4581c5ddbfe4259d1302

ARG COMMIT_SHA="unknown"
ARG DATE="unknown"
ARG VERSION="unknown"

LABEL org.opencontainers.image.revision=${COMMIT_SHA}
LABEL org.opencontainers.image.created=${DATE}
LABEL org.opencontainers.image.version=${VERSION}
LABEL com.sourcegraph.github.url=https://github.com/sourcegraph/sourcegraph/commit/${COMMIT_SHA}

RUN apk add --no-cache \
    # Minimal version requirement to address vulnerabilities
    # https://github.blog/2023-02-14-git-security-vulnerabilities-announced-3/
    'git>=2.39.2-r0' --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main \
    git-lfs \
    git-p4 \
    && apk add --no-cache  \
    openssh-client \
    # We require libstdc++ for p4-fusion
    libstdc++ \
    python2 \
    python3 \
    bash

COPY --from=p4cli /usr/local/bin/p4 /usr/local/bin/p4

COPY --from=p4-fusion /usr/local/bin/p4-fusion /usr/local/bin/p4-fusion

COPY --from=coursier /usr/local/bin/coursier /usr/local/bin/coursier

# This is a trick to include libraries required by p4,
# please refer to https://blog.tilander.org/docker-perforce/
# hadolint ignore=DL4006
RUN wget -O - https://github.com/jtilander/p4d/raw/4600d741720f85d77852dcca7c182e96ad613358/lib/lib-x64.tgz | tar zx --directory /

RUN mkdir -p /data/repos && chown -R sourcegraph:sourcegraph /data/repos
USER sourcegraph

WORKDIR /

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/gitserver"]
COPY gitserver /usr/local/bin/
