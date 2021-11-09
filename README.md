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
- Rust
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)


### Installing

```sh
sudo pacman -S rust aws-cli
```
Once you have installed the required prerequisites you need to decide which target you'd like to use.
For x86 or ARM lambda functions you'll want to use `x86_64-unknown-linux-gnu` or `aarch64-unknown-linux-gnu`, respectively. In our case we will use x86, therefore we add the
target

```sh
rustup target add x86_64-unknown-linux-gnu
```


## Usage <a name = "usage"></a>


## Deployment <a name = "deployment"></a>

