# minimal-λ

## Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Usage](#usage)
- [Deployment](#deployment)

## About <a name = "about"></a>

Exploring the possibilities of writing AWS Lambdas Functions on Rust.

## Getting Started <a name = "getting_started"></a>

These instructions will get you a copy of the project up and running on your local machine for
development and testing purposes. See [Deployment](#deployment) for notes on how to deploy the
project on a live system.

### Prerequisites

For development, you need a Unix-like environment for now. If you are running Windows, you can use
the Windows Subsystem for Linux ([WSL](https://docs.microsoft.com/en-us/windows/wsl/install)).

- Install [Rust](https://www.rust-lang.org/tools/install).
- Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html).
- Have an [AWS account](https://aws.amazon.com/account).

> Please note that most AWS services **have a cost**. Although the AWS Lambda free tier includes one
> million free requests per month. See the [lambda pricing](https://aws.amazon.com/lambda/pricing)
> for more details.

### Installing

#### Arch Linux
If you are using Arch Linux or a derivative, you could install all the development dependencies by
running the following commands.
```sh
sudo pacman -S rust aws-cli
```

#### Debian
If you are using Debian or a derivative (e.g. Ubuntu, Linux Mint), it is recommended to install Rust
using the standard installation script. You could install all the development dependencies by running
the following commands.
```sh
sudo pacman -S curl aws-cli
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
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
- `handler` the handler is usually a reference to the corresponding handler function, but in our
  case we provide the runtime.
- `zip-file` the zip file to use.
- `role` the role our function should assume for execution.
- `environment` sets the environment attribute on you lambda resource.

## Usage <a name = "usage"></a>

We can now use our lambda function by running the following command

```sh
aws lambda invoke \
    --function-name function_hello \
    --payload '{"first_name": "Mr.", "last_name": "John Doe"}' \
    --cli-binary-format raw-in-base64-out
    output.json
```

If you are (un)lucky enough to get an error of the form

```sh
/var/task/bootstrap: /lib64/libc.so.6: version `GLIBC_X.XX' not found (required by /var/task/bootstrap)
```

don't panic, it's just that `glibc`'s version on Amazon Linux 2 is different than on your system.

A first solution would be to compile the project statically using musl libc

```sh
rustup target add x86_64-unknown-linux-musl
```

and repeat the procedure keeping in mind that the target is `x86_64-unknown-linux-musl`.