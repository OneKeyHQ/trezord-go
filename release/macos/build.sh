#!/bin/sh

# export VERSION='0.0.0'

if [ -z "$VERSION" ]; then
    echo "Env: VERSION is empty!"
    exit -1
fi

echo "Build for version $VERSION"

# export APPLE_DEVELOPER_CERTIFICATE_ID=0

# setup
rm -rf target
mkdir target
rm -rf output
mkdir output

# uninstaller
# - copy over
cp -r uninstaller target/
mkdir -p target/uninstaller/pkg
chmod +x target/uninstaller/scripts
cp ./logo.png target/uninstaller/
# - patch info
sed -i -e "s/VERSION/$VERSION/g" target/uninstaller/Distribution
# - build package
pkgbuild \
    --identifier "so.onekey.bridge" \
    --version "${VERSION}" \
    --scripts "target/uninstaller/scripts" \
    --nopayload \
    "target/uninstaller/pkg/so.onekey.bridge.uninstall.pkg"
# - build product
productbuild \
    --distribution "target/uninstaller/Distribution" \
    --resources "target/uninstaller/resources" \
    --package-path "target/uninstaller/pkg" \
    "target/so.onekey.bridge.uninstall.pkg"
# - sign
# mv target/so.onekey.bridge.uninstall.pkg target/so.onekey.bridge.uninstall_raw.pkg
# productsign \
#     --sign "Developer ID Installer: ${APPLE_DEVELOPER_CERTIFICATE_ID}" \
#     "target/so.onekey.bridge.uninstall_raw.pkg" \
#     "target/so.onekey.bridge.uninstall.pkg"
# pkgutil --check-signature "target/so.onekey.bridge.uninstall.pkg"
# - output
cp target/so.onekey.bridge.uninstall.pkg output/so.onekey.bridge.uninstall.pkg

# installer
# - copy over
cp -r installer target/
mkdir -p target/installer/pkg
chmod +x target/installer/scripts
cp ./logo.png target/installer/
cp target/so.onekey.bridge.uninstall.pkg target/installer/payload/Applications/Utilities/OneKey\ Bridge/
chmod +x input_files/onekeyd_darwin_*
cp input_files/onekeyd_darwin_* target/installer/payload/Applications/Utilities/OneKey\ Bridge/
# - patch info
sed -i -e "s/VERSION/$VERSION/g" target/installer/Distribution
# - build package
pkgbuild \
    --identifier "so.onekey.bridge" \
    --version "${VERSION}" \
    --scripts "target/installer/scripts" \
    --root "target/installer/payload" \
    "target/installer/pkg/so.onekey.bridge.install.pkg"
# - build product
productbuild \
    --distribution "target/installer/Distribution" \
    --resources "target/installer/resources" \
    --package-path "target/installer/pkg" \
    "target/so.onekey.bridge.install.pkg"
# - sign product
# mv target/so.onekey.bridge.install.pkg target/so.onekey.bridge.install_raw.pkg
# productsign \
#     --sign "Developer ID Installer: ${APPLE_DEVELOPER_CERTIFICATE_ID}" \
#     "target/so.onekey.bridge.install_raw.pkg" \
#     "target/so.onekey.bridge.install.pkg"
# pkgutil --check-signature "target/so.onekey.bridge.install.pkg"
# - output
cp target/so.onekey.bridge.install.pkg output/so.onekey.bridge.install.pkg

# cleanup
rm -rf target
