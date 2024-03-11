#!/bin/bash
#REPO_HOST=http://llvm.org/git

#Needs to be run from root dir of repo
set e, x
COMPILER_DIR=$(readlink -f `dirname $0`/..)
PROJECT_ROOT_DIR=`dirname ${COMPILER_DIR}`
THIS_DIR=`dirname \`readlink -f $0\``
LLVM_DIR=${PROJECT_ROOT_DIR}/llvm/llvm-release_11x
CLANG_DIR=${PROJECT_ROOT_DIR}/llvm/clang-release_11x
SYM_LINK='ln -sfn'



#################################  SETUP LLVM  #################################
# All paths used in this explaination are relative to the root dir of the repo
# Uses Release 40 of LLVM an Clang (Version 4.0) that was downloaded from then
# Github mirror.  Extracts these archives to ../llvm/llvm-release_40 and
# ../llvm/clang-release_40.  Then uses setup_symlinks, to patch in the HEXBOX
# changes.  The source for the HEXBOX changes are in <ThisRepoRoot>/llvm
################################################################################
if [ ! -e ${LLVM_DIR} ]
then

  mkdir -p ${PROJECT_ROOT_DIR}/llvm/build
  #  SYM_LINK in clang
  unzip -o ${COMPILER_DIR}/3rd_party/llvm-release_11x.zip -d ${COMPILER_DIR}/../llvm/

fi

if [ ! -e ${CLANG_DIR} ]
then
  unzip -o ${COMPILER_DIR}/3rd_party/clang-release_11x.zip -d ${COMPILER_DIR}/../llvm/
  ${SYM_LINK} ${CLANG_DIR} ${LLVM_DIR}/tools/clang
fi

${COMPILER_DIR}/llvm/setup_symlinks.sh

################################################################################


######################     Build GCC    ########################################
# Checks to see if the appropriate version of GCC has been build and placed at
# the correct location, if not builds it, using the archive src in this
# repo.  Uses a slightly modified (Builds linker with plugin support) archive.
################################################################################
if [ ! -e ${PROJECT_ROOT_DIR}/gcc/bins ]
then
  mkdir -p ${PROJECT_ROOT_DIR}/gcc
  cd ${PROJECT_ROOT_DIR}/gcc
  if [ ! -e gcc-arm-none-eabi-6-2017-q1-update/pkg ]
  then
    file_size=$(wc -c < ${COMPILER_DIR}/3rd_party/gcc-arm-none-eabi-6-2017-q1-update-src.tar.bz2)

    if [ "$file_size" -lt 1024 ]; then
        echo "Downloading GCC"
      wget -O ${COMPILER_DIR}/3rd_party/gcc-arm-none-eabi-6-2017-q1-update-src.tar.bz2 "https://developer.arm.com/-/media/Files/downloads/gnu-rm/6_1-2017q1/gcc-arm-none-eabi-6-2017-q1-update-src.tar.bz2?rev=9a8be9e87ddd4841ac76c6ccb81151ba&revision=9a8be9e8-7ddd-4841-ac76-c6ccb81151ba?product=Downloads,Invariant,,Source,6-2017-q1-update"
    fi
     cp ${COMPILER_DIR}/3rd_party/gcc-arm-none-eabi-6-2017-q1-update-src.tar.bz2 .
     tar -xjf gcc-arm-none-eabi-6-2017-q1-update-src.tar.bz2
     cd gcc-arm-none-eabi-6-2017-q1-update
     cp ${COMPILER_DIR}/ci_scripts/gcc_build_toolchain.sh build-toolchain.sh
     cd src
     find -name '*.tar.*' | xargs -I% tar -xf %
     cd ..
     cp -rf ${COMPILER_DIR}/3rd_party/errors.h ${PROJECT_ROOT_DIR}/gcc/gcc-arm-none-eabi-6-2017-q1-update/src/binutils/gold/errors.h
     ./build-prerequisites.sh --skip_steps=mingw32
     ./build-toolchain.sh --skip_steps=mingw32
     cd ${PROJECT_ROOT_DIR}/gcc
  fi
  cd ${PROJECT_ROOT_DIR}/gcc/gcc-arm-none-eabi-6-2017-q1-update/pkg
  if [ ! -e gcc-arm-none-eabi-6-2018-q3-update-linux.tar.bz2 ]; then
    cp ${COMPILER_DIR}/3rd_party/gcc-arm-none-eabi-6-2018-q3-update-linux.tar.bz2 .
  fi
  tar -xjf gcc-arm-none-eabi-6-2018-q3-update-linux.tar.bz2
  mv gcc-arm-none-eabi-6-2018-q3-update ../../bins
  cd ${COMPILER_DIR}
fi


###############################################################################
