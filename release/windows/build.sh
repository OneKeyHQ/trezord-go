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
mkdir target/i386
mkdir target/amd64
rm -rf output
mkdir output

build_devcon() {

    # devcon
    cd target
    git clone --no-recursive https://github.com/microsoft/Windows-driver-samples.git --branch main --single-branch --filter=blob:none --depth 1 --sparse windows-driver-samples
    cd windows-driver-samples
    git checkout 8ef4a1cacff8c9967d870f9bfdfa8b3f21754a7f
    git sparse-checkout set setup/devcon
    git apply ../../devcon_patch_8ef4a1cacff8c9967d870f9bfdfa8b3f21754a7f.patch
    cd ..
    mv ./windows-driver-samples/setup/devcon ./devcon
    rm -rf windows-driver-samples
    cd ..

    # amd64
    cp -r ./target/devcon ./target/amd64/devcon
    cd ./target/amd64/devcon
    x86_64-w64-mingw32-windmc msg.mc
    x86_64-w64-mingw32-windres devcon.rc rc.so
    x86_64-w64-mingw32-g++ -municode -Wno-write-strings -DWIN32_LEAN_AND_MEAN=1 -DUNICODE -D_UNICODE *.cpp rc.so -lsetupapi -lole32 -static-libstdc++ -static-libgcc -o devcon.exe
    mv devcon.exe ../../../output/devcon_amd64.exe
    cd ../../../

    # i386
    cp -r ./target/devcon ./target/i386/devcon
    cd ./target/i386/devcon
    i686-w64-mingw32-windmc msg.mc
    i686-w64-mingw32-windres devcon.rc rc.so
    i686-w64-mingw32-g++ -municode -Wno-write-strings -DWIN32_LEAN_AND_MEAN=1 -DUNICODE -D_UNICODE *.cpp rc.so -lsetupapi -lole32 -static-libstdc++ -static-libgcc -o devcon.exe
    mv devcon.exe ../../../output/devcon_i386.exe
    cd ../../../
}

build_wdi() {

    # get wdf
    cd target
    # from https://learn.microsoft.com/en-us/windows-hardware/drivers/wdf/installation-components-for-kmdf-drivers
    # from https://go.microsoft.com/fwlink/p/?LinkID=253170
    wget "https://download.microsoft.com/download/0/5/F/05FD6919-6250-425B-86ED-9B095E54065A/wdfcoinstaller.msi"
    # if the link no longer available, use following instead
    # wget https://web.archive.org/web/20230309055750/https://download.microsoft.com/download/0/5/F/05FD6919-6250-425B-86ED-9B095E54065A/wdfcoinstaller.msi
    msiextract wdfcoinstaller.msi -C wdf_msi
    rm -f wdfcoinstaller.msi
    mv "wdf_msi/Program Files/Windows Kits/8.0/" ./wdk
    rm -rf wdf_msi
    cd ..

    # get libwdi
    cd target
    git clone --recursive https://github.com/pbatard/libwdi.git libwdi
    cd libwdi
    git checkout 90278c538a8fb5fd82aab25ae7f5a9887ca468ce #tags/v1.5.0
    cd ..
    cd ..

    # common build options
    BUILD_OPTIONS='--enable-toggable-debug --enable-examples-build --disable-debug --disable-shared'
    DRIVERS_PATHS='--with-wdkdir=../../../wdk --with-wdfver=1011 --with-libusb0='' --with-libusbk='''

    # amd64
    cp -r ./target/libwdi ./target/amd64/libwdi
    cd target/amd64/libwdi
    # --host seems broken, configure will not respect it, manually focing it
    CC_FOR_BUILD=gcc CC=x86_64-w64-mingw32-gcc ./autogen.sh --host=x86_64-w64-mingw32 $BUILD_OPTIONS $DRIVERS_PATHS --disable-32bit
    echo '#define COINSTALLER_DIR "wdf"' >>config.h #add missing COINSTALLER_DIR because of some bug in m4 with AC_CHECK_FILES and cross-compilation
    echo '#define X64_DIR "x64"' >>config.h         #seems the script having issue to setup this config, manually focing it
    make -j8 -C libwdi all
    make -j8 -C examples wdi-simple.exe
    mv examples/wdi-simple.exe ../../../output/wdi-simple_amd64.exe
    cd ../../../

    # i386
    cp -r ./target/libwdi ./target/i386/libwdi
    cd target/i386/libwdi
    # --host seems broken, configure will not respect it, manually focing it
    CC_FOR_BUILD=gcc CC=i686-w64-mingw32-gcc ./autogen.sh --host=i686-w64-mingw32 $BUILD_OPTIONS $DRIVERS_PATHS --disable-64bit
    echo '#define COINSTALLER_DIR "wdf"' >>config.h #add missing COINSTALLER_DIR because of some bug in m4 with AC_CHECK_FILES and cross-compilation
    make -j8 -C libwdi all
    make -j8 -C examples wdi-simple.exe
    mv examples/wdi-simple.exe ../../../output/wdi-simple_i386.exe
    cd ../../../
}

build_package() {

    mkdir ./target/installer
    cp ./onekeyd.nsis ./target/installer/
    cp ./onekeyd.ico ./target/installer/
    cp ./output/devcon_*.exe ./target/installer/
    cp ./output/wdi-simple_*.exe ./target/installer/
    cp ./input_files/onekeyd_windows_*.exe ./target/installer/
    cd ./target/installer/
    makensis -D"BuildVersion=$VERSION" onekeyd.nsis
    mv onekey-bridge-$VERSION-install.exe ../../output/
    cd ../../
}

# main
build_devcon
build_wdi
build_package

# cleanup
# rm -rf target
