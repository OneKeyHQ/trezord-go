How to build

## Before start

We are using Ubuntu 22.10 as build environment. And cross build for all other platforms.

## Dependencies

```shell
# add arm package repo, mainly for xxx-dev library packages for cross compiling
sudo sed -i 's/^deb/deb [arch=amd64]/g' /etc/apt/sources.list
sudo dpkg --add-architecture arm64
sudo dpkg --add-architecture armhf
sudo tee -a /etc/apt/sources.list.d/source-arm.list > /dev/null <<EOT
deb [arch=armhf,arm64] http://ports.ubuntu.com/ kinetic main restricted
deb [arch=armhf,arm64] http://ports.ubuntu.com/ kinetic-updates main restricted
deb [arch=armhf,arm64] http://ports.ubuntu.com/ kinetic universe
deb [arch=armhf,arm64] http://ports.ubuntu.com/ kinetic-updates universe
deb [arch=armhf,arm64] http://ports.ubuntu.com/ kinetic multiverse
deb [arch=armhf,arm64] http://ports.ubuntu.com/ kinetic-updates multiverse
deb [arch=armhf,arm64] http://ports.ubuntu.com/ kinetic-backports main restricted universe multiverse
EOT
sudo apt update

# go
sudo apt install -y --no-install-recommends build-essential libtool pkg-config libc6-dev
sudo apt install -y --no-install-recommends golang

# Linux Common
sudo apt install -y ruby-dev rpm tar xz-utils
sudo gem i fpm -f --no-document

# Linux ARM (could not coexist with gcc-multilib)
sudo apt install -y --no-install-recommends gcc-aarch64-linux-gnu g++-aarch64-linux-gnu cpp-aarch64-linux-gnu binutils-aarch64-linux-gnu
sudo apt install -y --no-install-recommends gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf cpp-arm-linux-gnueabihf binutils-arm-linux-gnueabihf
sudo apt install -y --no-install-recommends gcc-arm-linux-gnueabi g++-arm-linux-gnueabi cpp-arm-linux-gnueabi binutils-arm-linux-gnueabi

# Linux ARM X86 X64
sudo apt install -y --no-install-recommends gcc-multilib

# Windows
sudo apt install -y --no-install-recommends build-essential wget msitools dos2unix libtool nsis
sudo apt install -y --no-install-recommends gcc-multilib
sudo apt install -y --no-install-recommends gcc-mingw-w64 g++-mingw-w64 binutils-mingw-w64 mingw-w64-common mingw-w64-i686-dev mingw-w64-x86-64-dev
sudo apt install -y --no-install-recommends automake autoconf autotools-dev autoconf-archive

# OSX
# N/A using GitHub OSX runner
```



## Build Binary

### Linux

```shell
# build binary
export CGO_ENABLED=1 GOOS=linux GOARCH=amd64 CC="gcc"
go build -ldflags="-X 'main.version=$VERSION'" -v -o "onekeyd_${GOOS}_${GOARCH}" .
export CGO_ENABLED=1 GOOS=linux GOARCH=386 CC="gcc"
go build -ldflags="-X 'main.version=$VERSION'" -v -o "onekeyd_${GOOS}_i${GOARCH}" .
export CGO_ENABLED=1 GOOS=linux GOARCH=arm64 CC="aarch64-linux-gnu-gcc"
go build -ldflags="-X 'main.version=$VERSION'" -v -o "onekeyd_${GOOS}_${GOARCH}" .
export CGO_ENABLED=1 GOOS=linux GOARCH=arm CC="arm-linux-gnueabihf-gcc"
go build -ldflags="-X 'main.version=$VERSION'" -v -o "onekeyd_${GOOS}_${GOARCH}hf" .
export CGO_ENABLED=1 GOOS=linux GOARCH=arm CC="arm-linux-gnueabi-gcc"
go build -ldflags="-X 'main.version=$VERSION'" -v -o "onekeyd_${GOOS}_${GOARCH}" .

# package it ?
```



### Windows 

```shell
# build binary
export CGO_ENABLED=1 GOOS=windows GOARCH=amd64 CC="x86_64-w64-mingw32-gcc"
go build -ldflags="-H windowsgui -X 'main.version=$VERSION'" -v -o "onekeyd_${GOOS}_${GOARCH}.exe" .
export CGO_ENABLED=1 GOOS=windows GOARCH=386 CC="i686-w64-mingw32-gcc"
go build -ldflags="-H windowsgui -X 'main.version=$VERSION'" -v -o "onekeyd_${GOOS}_i${GOARCH}.exe" .

# package it ?
```



### Mac OS

**Note: following has to be done in Mac OS !!!**

```shell
# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# install go
brew install go
```



```shell
# build binary
export CGO_ENABLED=1 GOOS=darwin GOARCH=amd64 CC=""
go build -ldflags="-X 'main.version=$VERSION'" -v -o "onekeyd_${GOOS}_${GOARCH}" .
export CGO_ENABLED=1 GOOS=darwin GOARCH=arm64 CC=""
go build -ldflags="-X 'main.version=$VERSION'" -v -o "onekeyd_${GOOS}_${GOARCH}" .

# package it ?
```



## Build Package

`release` folder contains packaging scripts, they all made to be used with the same work flow:
1. Copy binaries `onekeyd_[OS]_*` into `release/[os]/input_files`
2. `cd release/[os]/ && ./build.sh && cd..`
3. Get generated packages in `release/[os]/output`