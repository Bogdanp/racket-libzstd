#!/usr/bin/env bash

set -euxo pipefail

git submodule update --init

pushd zstd
export PREFIX="$(pwd)/../artifacts/macos-aarch64"

make clean
make install
popd
