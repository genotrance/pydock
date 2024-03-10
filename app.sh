#! /bin/bash

source .env

MUSLS=""
MUSLSV=""
GLIBS=""
GLIBSV=""
for arch in amd64 386 arm64; do
    dtag=$TAG:musl_$arch
    dtagv=$TAG:musl_$arch-$VERSION
    docker build -f musl.Dockerfile --build-arg ARCH=$arch --build-arg TAG=$TAG -t $dtag .
    docker tag $dtag $dtagv
    docker push $dtag
    docker push $dtagv
    MUSLS="$MUSLS $dtag"
    MUSLSV="$MUSLSV $dtagv"

    dtag=$TAG:glibc_$arch
    dtagv=$TAG:glibc_$arch-$VERSION
    docker build -f glibc.Dockerfile --build-arg ARCH=$arch --build-arg TAG=$TAG -t $dtag .
    docker tag $dtag $dtagv
    docker push $dtag
    docker push $dtagv
    GLIBS="$GLIBS $dtag"
    GLIBSV="$GLIBSV $dtagv"
done

# Create single manifest for all base images
docker manifest create $TAG:musl $MUSLS
docker manifest create $TAG:musl-$VERSION $MUSLSV
docker manifest create $TAG:glibc $GLIBS
docker manifest create $TAG:glibc-$VERSION $GLIBSV

# Push manifests
docker manifest push $TAG:musl
docker manifest push $TAG:musl-$VERSION
docker manifest push $TAG:glibc
docker manifest push $TAG:glibc-$VERSION
