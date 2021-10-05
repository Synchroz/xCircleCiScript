#!/usr/bin/env bash
echo "Downloading few Dependecies . . ."
git clone --depth=1 https://github.com/Synchroz/Santoni-4.9-synchroz santoni
git clone --depth=1 https://github.com/mvaisakh/gcc-build gcc

# Main
KERNEL_NAME=Sirius # IMPORTANT ! Declare your kernel name
KERNEL_ROOTDIR=$(pwd)/santoni # IMPORTANT ! Fill with your kernel source root directory.
DEVICE_CODENAME=santoni # IMPORTANT ! Declare your device codename
DEVICE_DEFCONFIG=santoni_defconfig # IMPORTANT ! Declare your kernel source defconfig file here.
GCC_ROOTDIR=$(pwd)/gcc # IMPORTANT! Put your clang directory here.
export KBUILD_BUILD_USER=Synchroz # Change with your own name or else.
export KBUILD_BUILD_HOST=Bloodedge # Change with your own hostname.
IMAGE=$(pwd)/santoni/out/arch/arm64/boot/Image.gz-dtb
DATE=$(date +"%F-%S")
START=$(date +"%s")
PATH="${PATH}:${GCC_ROOTDIR}/bin"

# Checking environtment
# Warning !! Dont Change anything there without known reason.
function check() {
echo ================================================
echo xKernelCompiler CircleCI Edition
echo version : rev1.5 - gaspoll
echo ================================================
echo BUILDER NAME = ${KBUILD_BUILD_USER}
echo BUILDER HOSTNAME = ${KBUILD_BUILD_HOST}
echo DEVICE_DEFCONFIG = ${DEVICE_DEFCONFIG}
echo GCC_VERSION = $(${GCC_ROOTDIR}/bin/gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')
echo GCC_ROOTDIR = ${GCC_ROOTDIR}
echo KERNEL_ROOTDIR = ${KERNEL_ROOTDIR}
echo ================================================
}

# Compiler
function compile() {

   # Your Telegram Group
   curl -s -X POST "https://api.telegram.org/bot2030871213:AAEnZeoBtgl-jdsIaXfoGswrkKtCNQ0hK2U/sendMessage" \
        -d chat_id="-1001567409765" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b>xKernelCompiler</b>%0ABUILDER NAME : <code>${KBUILD_BUILD_USER}</code>%0ABUILDER HOST : <code>${KBUILD_BUILD_HOST}</code>%0ADEVICE DEFCONFIG : <code>${DEVICE_DEFCONFIG}</code>%0AGCC VERSION : <code>$(${GCC_ROOTDIR}/bin/gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</code>%0AGCC ROOTDIR : <code>${GCC_ROOTDIR}</code>%0AKERNEL ROOTDIR : <code>${KERNEL_ROOTDIR}</code>"

  cd ${KERNEL_ROOTDIR}
  make -j$(nproc) O=out ARCH=arm64 ${DEVICE_DEFCONFIG}
  make -j$(nproc) ARCH=arm64 O=out \
	LD=${GCC_ROOTDIR}/bin/gcc \
	CROSS_COMPILE=${GCC_ROOTDIR}/bin/aarch64-linux-gnu- \
	CROSS_COMPILE_ARM32=${GCC_ROOTDIR}/bin/arm-linux-gnueabi-

   if ! [ -a "$IMAGE" ]; then
	finerr
	exit 1
   fi
    git clone --depth=1 https://github.com/Synchroz/AnyKernel AnyKernel
	cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
}

# Push
function push() {
    cd AnyKernel
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot2030871213:AAEnZeoBtgl-jdsIaXfoGswrkKtCNQ0hK2U/sendDocument" \
        -F chat_id="-1001567409765" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Compile took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>Xiaomi Redmi 4X (santoni)</b> | <b>$(${CLANG_ROOTDIR}/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</b>"

}
# Fin Error
function finerr() {
    curl -s -X POST "https://api.telegram.org/bot2030871213:AAEnZeoBtgl-jdsIaXfoGswrkKtCNQ0hK2U/sendMessage" \
        -d chat_id="-1001567409765" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build throw an error(s)"
    exit 1
}

# Zipping
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 ${KERNEL_NAME}-${DEVICE_CODENAME}-${DATE}.zip *
    cd ..
}
check
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push
