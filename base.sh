#! /bin/bash

source .env

set -e

PYPA=quay.io/pypa
MUSL=musllinux_1_1_
GLIBC=manylinux2014_

# quay.io arch to docker arch
archtogoarch() {
    if [ "$1" = "x86_64" ]; then
        goarch=amd64
    elif [ "$1" = "i686" ]; then
        goarch=386
    elif [ "$1" = "aarch64" ]; then
        goarch=arm64
    fi
}

PUSH_FLAG=""
for arg in "$@"
do
    if [ "$arg" == "--push" ]; then
        PUSH_FLAG="true"
        break
    fi
done

# Repost quay.io images to docker
MUSLS=""
MUSLSV=""
GLIBS=""
GLIBSV=""
for arch in x86_64 i686 aarch64; do
    archtogoarch $arch

    docker pull $PYPA/$MUSL$arch
    dtag=$TAG:musl_base_$goarch
    dtagv=$TAG:musl_base_$goarch-$VERSION
    docker tag $PYPA/$MUSL$arch $dtag
    docker tag $PYPA/$MUSL$arch $dtagv
    if [ "$PUSH_FLAG" == "true" ]; then
        docker push $dtag
        docker push $dtagv
    fi
    MUSLS="$MUSLS $dtag"
    MUSLSV="$MUSLSV $dtagv"

    docker pull $PYPA/$GLIBC$arch
    dtag=$TAG:glibc_base_$goarch
    dtagv=$TAG:glibc_base_$goarch-$VERSION
    docker tag $PYPA/$GLIBC$arch $dtag
    docker tag $PYPA/$GLIBC$arch $dtagv
    if [ "$PUSH_FLAG" == "true" ]; then
        docker push $dtag
        docker push $dtagv
    fi
    GLIBS="$GLIBS $dtag"
    GLIBSV="$GLIBSV $dtagv"
done

# Create single manifest for all base images
docker manifest create $TAG:musl_base $MUSLS --amend    
docker manifest create $TAG:musl_base-$VERSION $MUSLSV --amend
docker manifest create $TAG:glibc_base $GLIBS --amend
docker manifest create $TAG:glibc_base-$VERSION $GLIBSV --amend

if [ "$PUSH_FLAG" == "true" ]; then
    # Push manifests
    docker manifest push $TAG:musl_base
    docker manifest push $TAG:musl_base-$VERSION
    docker manifest push $TAG:glibc_base
    docker manifest push $TAG:glibc_base-$VERSION
fi
