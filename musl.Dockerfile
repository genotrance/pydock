ARG ARCH=amd64
ARG TAG=genotrance/pydock

FROM $TAG:musl_base_$ARCH AS musl

RUN <<EOF
# Exit on error
set -e

# Install packages
apk update --no-cache && apk upgrade --no-cache
apk add --no-cache curl psmisc \
    python3 python3-dev \
    dbus gnome-keyring openssh \
    ccache gcc musl-dev patchelf libffi-dev
apk add --no-cache upx || true
EOF

COPY setup.sh /root/setup.sh

# Setup common
RUN /root/setup.sh
