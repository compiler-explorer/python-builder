#!/bin/bash

set -ex

ROOT=$(pwd)
VERSION=$1
FULLNAME=python-${VERSION}.tar.xz
OUTPUT=${ROOT}/${FULLNAME}
S3OUTPUT=
if [[ $2 =~ ^s3:// ]]; then
    S3OUTPUT=$2
else
    if [[ -d "${2}" ]]; then
        OUTPUT=$2/${FULLNAME}
    else
        OUTPUT=${2-$OUTPUT}
    fi
fi

REVISION="python-${VERSION}"
echo "ce-build-revision:${REVISION}"
echo "ce-build-output:${OUTPUT}"

PREFIX_DIR=/opt/compiler-explorer/python-${VERSION}

curl -sL https://www.python.org/ftp/python/${VERSION}/Python-${VERSION}.tgz | tar zxf -
pushd Python-${VERSION}
./configure \
    --prefix=${PREFIX_DIR} \
    --without-ensurepip \
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

echo "ce-build-status:OK"
