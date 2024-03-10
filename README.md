manylinux+musllinux images from quay.io/pypa + apps + venvs

genotrance/pydock:glibc_base = manylinux2014
genotrance/pydock:musl_base = musllinux_1_1

Use --platform to load amd64, 386 or arm64 images.

genotrance/pydock:glibc and genotrance/pydock:musl include venvs in $HOME/pyvenv
and are used to build Px and pymcurl wheels and binaries.

base.sh copies and pushes all base images from quay.io to docker hub
app.sh builds the Dockerfiles and pushes images to docker hub