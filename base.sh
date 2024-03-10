#! /bin/bash

source .env

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
    docker push $dtag
    docker push $dtagv
    MUSLS="$MUSLS $dtag"
    MUSLSV="$MUSLSV $dtagv"

    docker pull $PYPA/$GLIBC$arch
    dtag=$TAG:glibc_base_$goarch
    dtagv=$TAG:glibc_base_$goarch-$VERSION
    docker tag $PYPA/$GLIBC$arch $dtag
    docker tag $PYPA/$GLIBC$arch $dtagv
    docker push $dtag
    docker push $dtagv
    GLIBS="$GLIBS $dtag"
    GLIBSV="$GLIBSV $dtagv"
done

# Create single manifest for all base images
docker manifest create $TAG:musl_base $MUSLS
docker manifest create $TAG:musl_base-$VERSION $MUSLSV
docker manifest create $TAG:glibc_base $GLIBS
docker manifest create $TAG:glibc_base-$VERSION $GLIBSV

# Push manifests
docker manifest push $TAG:musl_base
docker manifest push $TAG:musl_base-$VERSION
docker manifest push $TAG:glibc_base
docker manifest push $TAG:glibc_base-$VERSION
