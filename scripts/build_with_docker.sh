# set this to either linux/arm64 for ARM functions, or linux/amd64 for x86 functions.
LAMBDA_ARCH="linux/amd64"
# corresponding with the above, set this to aarch64 or x86_64 -unknown-linux-gnu for ARM or x86 functions.
RUST_TARGET="x86_64-unknown-linux-gnu"
# Set this to a specific version of rust you want to compile for, or to latest if you want the latest stable version.
RUST_VERSION="latest"

docker run \
    --platform ${LAMBDA_ARCH} \
    --rm --user "$(id -u)":"$(id -g)" \
    -v "${PWD}":/usr/src/minimal-lambda -w /usr/src/minimal-lambda rust:${RUST_VERSION} \
    cargo build --release --target ${RUST_TARGET}
