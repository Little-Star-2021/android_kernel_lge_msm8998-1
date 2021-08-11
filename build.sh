#!/bin/bash
PATH="$HOME/repo/proton-clang/bin:$PATH"
clang_path="$HOME/repo/proton-clang/bin"
gcc_path="aarch64-linux-gnu-"
gcc_32_path="arm-linux-gnueabi-"

source=`pwd`
START=$(date +"%s")

date="`date +"%m%d%H%M"`"

args="-j$(nproc --all) O=out \
	ARCH=arm64 \
	SUBARCH=arm64 "

print (){
case ${2} in
	"red")
	echo -e "\033[31m $1 \033[0m";;

	"blue")
	echo -e "\033[34m $1 \033[0m";;

	"yellow")
	echo -e "\033[33m $1 \033[0m";;

	"purple")
	echo -e "\033[35m $1 \033[0m";;

	"sky")
	echo -e "\033[36m $1 \033[0m";;

	"green")
	echo -e "\033[32m $1 \033[0m";;

	*)
	echo $1
	;;
	esac
}

print "You are building a snapshot version:$date" yellow

args+="LOCALVERSION=-$date "

args+="CC=${clang_path}/clang \
CLANG_TRIPLE=aarch64-linux-gnu- \
LLVM_AR=${clang_path}/llvm-ar \
LLVM_NM=${clang_path}/llvm-nm \
LD=${clang_path}/ld.lld \
OBJCOPY=${clang_path}/llvm-objcopy \
OBJDUMP=${clang_path}/llvm-objdump \
STRIP=${clang_path}/llvm-strip \
CROSS_COMPILE=$gcc_path "

args+="CROSS_COMPILE_ARM32=$gcc_32_path "

clean(){
	make mrproper
	make $args mrproper
}

build_joan(){
  export KBUILD_BUILD_USER="joan"
  export KBUILD_BUILD_HOST="YimoLieu"
  #PATH="$HOME/repo/proton-clang/bin:$PATH"
  print "Building Kernel for joan..." blue
  make $args vaccine_defconfig&&make $args
  if [ $? -ne 0 ]; then
    terminate "Error while building for joan!"
  fi
#  mkzip "joan-${1}"
}

build_z2_plus(){
	export KBUILD_BUILD_USER="z2_plus"
	export KBUILD_BUILD_HOST="LibXZR"
	print "Building Kernel for z2_plus..." blue
	make $args z2_plus_defconfig&&make $args
	if [ $? -ne 0 ]; then
    terminate "Error while building for z2_plus!"
    fi
	mkzip "z2_plus-${1}"
}

build_z2_plus_oc(){
	export KBUILD_BUILD_USER="z2_plus"
	export KBUILD_BUILD_HOST="LibXZR"
	print "Building panel-OC ${1}Hz Kernel for z2_plus..." blue
	sed -i "s/qcom,mdss-dsi-panel-framerate = <60>/qcom,mdss-dsi-panel-framerate = <${1}>/g" arch/arm64/boot/dts/qcom/zuk/dsi-panel-tianma-1080p-video.dtsi
	make $args z2_plus_defconfig&&make $args
	if [ $? -ne 0 ]; then
    terminate "Error while building panel-OC ${1}Hz kernel for z2_plus!"
    fi
	mkzip "z2_plus-${2}-${1}Hz"
	sed -i "s/qcom,mdss-dsi-panel-framerate = <${1}>/qcom,mdss-dsi-panel-framerate = <60>/g" arch/arm64/boot/dts/qcom/zuk/dsi-panel-tianma-1080p-video.dtsi
}

build_z2_row(){
	export KBUILD_BUILD_USER="z2_row"
	export KBUILD_BUILD_HOST="LibXZR"
	print "Building Kernel for z2_row..." blue
	make $args z2_row_defconfig&&make $args
	if [ $? -ne 0 ]; then
    terminate "Error while building for z2_row!"
    fi
	mkzip "z2_row-${1}"
}

mkzip (){
	zipname="Vaccine Kernel[4.4-250] $date.zip"
	cp -f out/arch/arm64/boot/Image.gz-dtb ~/repo/AnyKernel3
	cd ~/repo/AnyKernel3
	zip -r "$zipname" * -x .git README.md *placeholder
  rm ~/repo/AnyKernel3/Image.gz-dtb
	mv -f "$zipname" ${HOME}
	cd ${HOME}
	cd $source
	print "All done.Find it at ${HOME}/$zipname" green
}

terminate(){
  print "error" red
  exit 1
}

    clean
    build_joan ${p##*/}
    END=$(date +"%s")
	  KDURATION=`expr $END - $START`
    mkzip

