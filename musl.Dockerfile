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
    ccache gcc musl-dev patchelf libffi-dev shadow
apk add --no-cache upx || true
EOF

# Python static libs
RUN cd /opt/_internal && tar xf static-libs-for-embedding-only.tar.xz && cd -

# Create a non-root user
RUN useradd -ms /bin/sh pydock

# Switch to the new user
USER pydock

# Set working directory
WORKDIR /home/pydock

# Setup common
COPY setup.sh /home/pydock/setup.sh
RUN /home/pydock/setup.sh
