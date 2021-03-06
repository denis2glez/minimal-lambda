# minimal-λ

## Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Usage](#usage)
- [Deployment](#deployment)

## About <a name = "about"></a>

Exploring the possibilities of writing AWS Lambda Functions on Rust.

## Getting Started <a name = "getting_started"></a>

These instructions will get you a copy of the project up and running on your local machine for
development and testing purposes. See [Deployment](#deployment) for notes on how to deploy the
lambda function to AWS.

### Prerequisites

For development, you need a Linux environment for now. Otherwise, you could try to cross-compile
from your system to Linux, but in some cases it is not possible while in others it has various
limitations. In this case, you can install Docker to continue.

If you are running Windows, you can instead use
the Windows Subsystem for Linux ([WSL](https://docs.microsoft.com/en-us/windows/wsl/install)).

- Install [Rust](https://www.rust-lang.org/tools/install).
- Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html).
- Install [Docker](https://docs.docker.com/get-docker/) (optional).
- Have an [AWS account](https://aws.amazon.com/account).

> Please note that most AWS services **have a cost**. Although the AWS Lambda free tier includes one
> million free requests per month. See the [lambda pricing](https://aws.amazon.com/lambda/pricing)
> for more details.

### Installing

#### Arch Linux
If you are using Arch Linux or a derivative, you could install the development dependencies by
running the following commands.
```sh
sudo pacman -S curl unzip rust
```

#### Debian
If you are using Debian or a derivative (e.g. Ubuntu, Linux Mint), it is recommended to install Rust
using the standard installation script. You could install the development dependencies by running
the following commands.
```sh
sudo apt install curl unzip
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

While it is possible to install AWS CLI from the repositories, it is likely an older version (i.e. v1).
In this case, it is recommended to use the
[official installation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
Assuming that you are running on x86, you can install it executing

```sh
curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
unzip awscliv2.zip
sudo ./aws/install
```

### Setup

Once you have installed the required dependencies you need to decide which target you'd like to use.
For x86 or ARM lambda functions you'll want to use `x86_64-unknown-linux-gnu` or
`aarch64-unknown-linux-gnu`, respectively. In our case we will use x86, therefore we add the
target

```sh
rustup target add x86_64-unknown-linux-gnu
```

We focus here on building for [Amazon Linux 2](https://aws.amazon.com/amazon-linux-2).

## Build <a name = "build"></a>

When building the project be sure to specify the correct target

```sh
cargo build --release --target x86_64-unknown-linux-gnu
```

Next, the path of the built binary will depend on the target selected. When using a [custom AWS
Lambda runtime](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-custom.html) our function's
deployment package should be in the form of an executable file named `bootstrap`, that we are going
to compress it before supplying it.

```sh
cp target/x86_64-unknown-linux-gnu/release/minimal-λ ./bootstrap
zip lambda.zip bootstrap
rm bootstrap
```

## Deployment <a name = "deployment"></a>

Be sure to create first the role `lambda-role` in AWS. To setup our function in `AWS` we can use
the following command
```sh
aws lambda create-function \
    --function-name function_hello \
    --handler my-function.handler \
    --zip-file fileb://lambda.zip \
    --runtime provided.al2 \
    --role arn:aws:iam::xxxxxxxxxxxx:role/lambda-role \
    --environment Variables={RUST_BACKTRACE=1}
```
where

- `function-name` denotes the name of the function we wish to create.
- `handler` it is usually a reference to the corresponding handler function, but in our
  case we provide the runtime.
- `zip-file` the zip file to use.
- `role` the role our function should use for execution.
- `environment` sets the environment attribute on your lambda resource.

## Usage <a name = "usage"></a>

We can now use our lambda function by running the following command

```sh
aws lambda invoke \
    --function-name function_hello \
    --payload '{"first_name": "Mr.", "last_name": "John Doe"}' \
    --cli-binary-format raw-in-base64-out
    output.json
```

### Issues

If you are (un)lucky enough to get an error of the form

```sh
/var/task/bootstrap: /lib64/libc.so.6: version `GLIBC_X.XX' not found (required by /var/task/bootstrap)
```

Don't panic, it's just that `glibc`'s version on Amazon Linux 2 is different than on your system.

A first solution would be to compile the project statically using musl libc

```sh
rustup target add x86_64-unknown-linux-musl
```

and repeat the procedure keeping in mind that the target is `x86_64-unknown-linux-musl`. But for
performance-sensitive code, it is currently recommended to bring an alternative high-performance
`malloc` implementation.

Alternatively, you could use Docker to build the project. Once you have Docker installed, running
the script `scripts/build_with_docker.sh` will build the project in Docker and then copy back the
artifacts into the standard `target` directory of your host. From here you can continue the
procedure in the same way as if you had compiled it locally.