# SPDX-FileCopyrightText: © 2026 Nfrastack <code@nfrastack.com>
#
# SPDX-License-Identifier: MIT

ARG \
    BASE_IMAGE

FROM docker.io/xyksolutions1/container-base:main

LABEL \
        org.opencontainers.image.title="CoreDNS" \
        org.opencontainers.image.description="DNS Server" \
        org.opencontainers.image.url="https://hub.docker.com/r/xyksolutions1/coredns" \
        org.opencontainers.image.documentation="https://github.com/xyksolutions1/container-coredns/blob/main/README.md" \
        org.opencontainers.image.source="https://github.com/xyksolutions1/container-coredns.git" \
        org.opencontainers.image.authors="xyksolutions1" \
        org.opencontainers.image.vendor="xyksolutions1" \
        org.opencontainers.image.licenses="MIT"

COPY CHANGELOG.md /usr/src/container/CHANGELOG.md
COPY LICENSE /usr/src/container/LICENSE
COPY README.md /usr/src/container/README.md

ARG \
    COREDNS_REPO_URL="https://github.com/coredns/coredns" \
    COREDNS_VERSION="v1.14.3"

ENV \
    CONTAINER_ENABLE_MESSAGING=FALSE \
    IMAGE_NAME="xyksolutions1/coredns" \
    IMAGE_REPO_URL="https://github.com/xyksolutions1/container-coredns/"

RUN echo "" && \
    COREDNS_BUILD_DEPS_ALPINE=" \
                                build-base \
                                git \
                            " \
                        && \
    COREDNS_RUN_DEPS_ALPINE=" \
                                iptables \
                                libc6-compat \
                                libstdc++ \
                                moreutils \
                                util-linux-misc \
                            " \
                        && \
    \
    source /container/base/functions/container/build && \
    container_build_log image && \
    create_user coredns 5353 coredns 5353 && \
    package update && \
    package upgrade && \
    package install \
                        COREDNS_BUILD_DEPS \
                        COREDNS_RUN_DEPS \
                        && \
    \
    package build go && \
    clone_git_repo "${COREDNS_REPO_URL}" "${COREDNS_VERSION}" && \
    make && \
    mv coredns /usr/local/bin && \
    container_build_log add "CoreDNS" "${COREDNS_VERSION}" "${COREDNS_REPO_URL}" && \
    package remove \
                    COREDNS_BUILD_DEPS \
                    && \
    package cleanup

EXPOSE 53
EXPOSE 53/udp

COPY rootfs /
