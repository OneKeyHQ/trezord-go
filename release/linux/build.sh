#!/bin/sh

# export VERSION='0.0.0'

if [ -z "$VERSION" ]; then
    echo "Env: VERSION is empty!"
    exit -1
fi

echo "Build for version $VERSION"

# setup
rm -rf target
mkdir target
rm -rf output
mkdir output

build_package() {

    # parms
    type=$1
    arch=$2

    # work dir
    mkdir -p ./target/$type/$arch

    # package source
    mkdir ./target/$type/$arch/package_root
    install -D -m 0755 ./input_files/onekeyd_linux_$arch ./target/$type/$arch/package_root/usr/bin/onekeyd
    install -D -m 0644 ./onekey.rules ./target/$type/$arch/package_root/lib/udev/rules.d/50-onekey.rules
    install -D -m 0644 ./onekeyd.service ./target/$type/$arch/package_root/usr/lib/systemd/system/onekeyd.service
    cd ./target/$type/$arch/package_root
    rm -f ../onekey-bridge-$VERSION-$arch.tar.xz
    tar -c -J -f ../onekey-bridge-$VERSION-$arch.tar.xz ./usr ./lib
    cd ../../../../

    # package build
    if [ "$type" = "deb" ]; then
        type_options='--deb-compression xz'
    fi

    if [ "$type" = "rpm" ]; then
        type_options='--rpm-compression xz'
    fi

    fpm \
        -s tar \
        -t $type \
        -a $arch \
        -n onekey-bridge \
        -v $VERSION \
        -d systemd \
        -p onekey-bridge-$VERSION-$arch.$type \
        $type_options \
        --license "LGPL-3.0" \
        --vendor "OneKey Ltd." \
        --description "Communication daemon for Onekey Devices" \
        --maintainer "OneKey <dev@onekey.so>" \
        --url "https://onekey.so/" \
        --category "Productivity/Security" \
        --before-install ./fpm.before-install.sh \
        --after-install ./fpm.after-install.sh \
        --before-upgrade ./fpm.before-remove.sh \
        --after-upgrade ./fpm.after-install.sh \
        --before-remove ./fpm.before-remove.sh \
        --after-remove ./fpm.after-remove.sh \
        ./target/$type/$arch/onekey-bridge-$VERSION-$arch.tar.xz

    mv onekey-bridge-$VERSION-$arch.$type ./output/
}

# main
build_package "deb" "amd64"
build_package "deb" "i386"
build_package "deb" "arm64"
build_package "deb" "armhf"
build_package "deb" "arm"

build_package "rpm" "amd64"
build_package "rpm" "i386"
build_package "rpm" "arm64"
build_package "rpm" "armhf"
build_package "rpm" "arm"

# cleanup
rm -rf target
