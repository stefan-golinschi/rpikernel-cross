FROM ubuntu:23.04

RUN apt-get update

RUN apt-get install -y \
    gcc-arm-linux-gnueabihf gcc-aarch64-linux-gnu \
    git bc bison flex libssl-dev make libc6-dev libncurses5-dev \
    crossbuild-essential-arm64 crossbuild-essential-armhf

RUN apt-get install wget unzip

WORKDIR /work