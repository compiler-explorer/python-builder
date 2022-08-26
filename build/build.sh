#!/bin/bash

set -ex

VERSION=$1
OUTPUT=/root/python-${VERSION}.tar.xz
S3OUTPUT=""
if echo $2 | grep s3://; then
    S3OUTPUT=$2
else
    OUTPUT=${2-/root/python-${VERSION}.tar.xz}
fi

PREFIX_DIR=/opt/compiler-explorer/python-${VERSION}

curl -sL https://www.python.org/ftp/python/${VERSION}/Python-${VERSION}.tgz | tar zxf -
pushd Python-${VERSION}
./configure \
    --prefix=${PREFIX_DIR} \
    --without-pymalloc

make -j$(nproc)
make install
popd

# strip executables
find ${PREFIX_DIR} -type f -perm /u+x -exec strip -d {} \;

# delete tests and static libraries to save disk space
find ${PREFIX_DIR} -type d -name test -exec rm -rf {} +
find ${PREFIX_DIR} -type f -name *.a -delete

export XZ_DEFAULTS="-T 0"
tar Jcf ${OUTPUT} -C /opt/compiler-explorer .

if [[ ! -z "${S3OUTPUT}" ]]; then
    aws s3 cp --storage-class REDUCED_REDUNDANCY "${OUTPUT}" "${S3OUTPUT}"
fi
