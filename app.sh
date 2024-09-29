#! /bin/bash

source .env

set -e

# Check if --push is specified in command line
PUSH_FLAG=""
for arg in "$@"
do
    if [ "$arg" == "--push" ]; then
        PUSH_FLAG="true"
        break
    fi
done

MUSLS=""
MUSLSV=""
GLIBS=""
GLIBSV=""
for arch in amd64 386 arm64; do
    dtag=$TAG:musl_$arch
    dtagv=$TAG:musl_$arch-$VERSION
    docker build -f musl.Dockerfile --build-arg ARCH=$arch --platform linux/$arch --build-arg TAG=$TAG -t $dtag .
    docker tag $dtag $dtagv
    if [ "$PUSH_FLAG" == "true" ]; then
        docker push $dtag
        docker push $dtagv
    fi
    MUSLS="$MUSLS $dtag"
    MUSLSV="$MUSLSV $dtagv"

    dtag=$TAG:glibc_$arch
    dtagv=$TAG:glibc_$arch-$VERSION
    docker build -f glibc.Dockerfile --build-arg ARCH=$arch --platform linux/$arch --build-arg TAG=$TAG -t $dtag .
    docker tag $dtag $dtagv
    if [ "$PUSH_FLAG" == "true" ]; then
        docker push $dtag
        docker push $dtagv
    fi
    GLIBS="$GLIBS $dtag"
    GLIBSV="$GLIBSV $dtagv"
done

# Create single manifest for all base images
docker manifest create $TAG:musl $MUSLS --amend
docker manifest create $TAG:musl-$VERSION $MUSLSV --amend
docker manifest create $TAG:glibc $GLIBS --amend
docker manifest create $TAG:glibc-$VERSION $GLIBSV --amend

# Push manifests
if [ "$PUSH_FLAG" == "true" ]; then
    docker manifest push $TAG:musl
    docker manifest push $TAG:musl-$VERSION
    docker manifest push $TAG:glibc
    docker manifest push $TAG:glibc-$VERSION
fi
