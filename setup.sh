#! /bin/sh

set -e

# Venv related
VPATH="import sys; print('py' + sys.version.split()[0])"

setup_venv() {
    VENV=$HOME/pyvenv/`$1 -c "$VPATH"`
    echo "Setup $VENV"
    $1 -m venv $VENV
    . $VENV/bin/activate
}

activate_venv() {
    VENV=$HOME/pyvenv/`$1 -c "$VPATH"`
    echo "Activate $VENV"
    . $VENV/bin/activate
}

# Pick latest-1 python
#   Nuitka support lags behind Python releases
export PY="/opt/python/`ls -v /opt/python | grep cp | tail -n 2 | head -n 1`/bin/python3"

# Run for all Python versions
for pyver in `ls /opt/python/cp* -d -v`
do
    # Setup venv for this Python version
    setup_venv $pyver/bin/python3

    # Install tools
    python3 -m pip install --upgrade pip setuptools build wheel
done

setup_venv $PY

python3 -m pip install --upgrade pip setuptools build wheel auditwheel nuitka
python3 -m pip cache purge

# Python static libs
cd /opt/_internal && tar xf static-libs-for-embedding-only.tar.xz && cd -
