ARG ARCH=amd64
ARG TAG=genotrance/pydock

FROM $TAG:glibc_base_$ARCH AS glibc

RUN <<EOF
# Exit on error
set -e

# Avoid random mirror
# cd /etc/yum.repos.d
# for file in `ls`; do sed -i~ 's/^mirrorlist/#mirrorlist/' $file; done
# for file in `ls`; do sed -i~~ 's/^#baseurl/baseurl/' $file; done
cd

# Install packages
yum update -y
yum install -y psmisc \
    python3 python3-devel \
    gnome-keyring openssh \
    libffi-devel
yum install -y upx || true
yum install -y ccache || true
yum install -y patchelf || true
yum clean all
EOF

# Python static libs
RUN cd /opt/_internal && tar xf static-libs-for-embedding-only.tar.xz && cd -

# Create a non-root user
RUN useradd -ms /bin/bash pydock

# Switch to the new user
USER pydock

# Set working directory
WORKDIR /home/pydock

# Setup common
COPY ../setup.sh /home/pydock/setup.sh
RUN /home/pydock/setup.sh
