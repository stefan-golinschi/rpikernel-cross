# Crosscompiled build of RPi Kernel

 - uname `Linux raspberrypi 6.6.25-v8+ #1751 SMP PREEMPT Fri Apr  5 15:18:12 BST 2024 aarch64 GNU/Linux`

## Get the kernel commit hash

On RaspberryPi:

```bash
JUST_CHECK=1 rpi-update
FW_REV:269e5ea259b947eb038fefbc6c7eba23bce54df6
BOOTLOADER_REV:61023cbd32725a07e094f9b2d01df302f4ddabba

FW_REV=$(JUST_CHECK=1 rpi-update|grep FW_REV|cut -d ":" -f 2)
GIT_HASH=$(wget -qO- https://raw.githubusercontent.com/raspberrypi/rpi-firmware/$FW_REV/git_hash)

echo $GIT_HASH
ae8a4ce56fcac6cfd2bf9c3bbbdd939725c1ae45
```

On build host:

```bash
export GIT_HASH=ae8a4ce56fcac6cfd2bf9c3bbbdd939725c1ae45
wget https://github.com/raspberrypi/linux/archive/${GIT_HASH}.zip -O linux-${GIT_HASH}.zip
cd linux-${GIT_HASH}
```


## Get the kernel config
Now you need the original config file from the RaspberryPi.

```bash
modprobe configs
zcat /proc/config.gz | tee config.txt

# Transfer the config from the rpi to the host
scp pi@<rpi ip address>:/home/pi/config.txt config-rpi.txt
```

After this, the directory structure will look like this:

```
.
├── Dockerfile
├── README.md
└── store
    ├── config-rpi.txt
    ├── linux-6.1.19.zip
    └── linux-<commit_hash>
```

Now copy the config to the linux kernel source code root folder, renaming to `.config`.

```bash
cp store/config-rpi.txt store/linux-<commit_hash>/.config
```

## Build
```bash

docker build -t rpi-linux:ubuntu_23.04 .
docker run -it --rm -v $PWD/store:/work:rw rpi-linux:ubuntu_23.04

export KERNEL=kernel8
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
make menuconfig
make -j$(nproc)
```