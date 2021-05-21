# :: Header
    FROM alpine:3.13
    ENV XMRIG_VERSION="6.12.1"


# :: Run
    USER root

    # :: prepare
        RUN set -ex; \
            mkdir -p /xmrig; \
            mkdir -p /xmrig/bin; \
            mkdir -p /xmrig/etc; \
            addgroup --gid 1000 xmrig; \
            adduser --uid 1000 -H -D -G xmrig -h /xmrig xmrig; \
            apk --update --no-cache add \
                curl \
                kmod; \
            apk --update --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/ add \
                msr-tools

    # :: install
        ADD https://github.com/xmrig/xmrig/archive/refs/tags/v${XMRIG_VERSION}.tar.gz /tmp

        RUN set -ex; \
            apk --update --no-cache --virtual .build add \
                make \
                cmake \
                libstdc++ \
                gcc \
                g++ \
                automake \
                libtool \
                autoconf \
                linux-headers; \
            cd /tmp; \
            tar -xzvf v${XMRIG_VERSION}.tar.gz; \
            cd xmrig-${XMRIG_VERSION}/scripts; \
            ./build_deps.sh; \
            cmake .. -DXMRIG_DEPS=scripts/deps -DBUILD_STATIC=ON; \
            make -j$(nproc); \
            cp xmrig /xmrig/bin; \
            rm -rf /tmp/*; \
            apk del .build

    # :: copy root filesystem changes
        COPY ./rootfs /

    # :: docker -u 1000:1000 (no root initiative)
        RUN set -ex; \
            chown -R xmrig:xmrig \
            /xmrig;


# :: Volumes
    VOLUME ["/xmrig/etc"]


# :: Monitor
    RUN chmod +x /usr/local/bin/healthcheck.sh
    HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1


# :: Start
    RUN chmod +x /usr/local/bin/entrypoint.sh
    USER xmrig
    ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]