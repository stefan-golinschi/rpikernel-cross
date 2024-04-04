# Crosscompiled build of RPi Kernel

## Get the right kernel version

On the RaspberryPi, you need to find the exact commit hash of the kernel source code that was used to produce the Linux image.

```bash
zgrep '* firmware as of' /usr/share/doc/raspberrypi-bootloader/changelog.Debian.gz | head -1

# On this rpi, the output is this:
# * firmware as of 4c6c5389d55d419e38f00116829d5a0f30c7bfbf
```

Now, you need to download the Linux source code from git using the commit hash as reference. The source code is located here: `https://github.com/raspberrypi/linux`.

```bash
mkdir store/
cd store/
COMMIT_HASH=4c6c5389d55d419e38f00116829d5a0f30c7bfbf \
VERSION="6.1.19"
wget https://github.com/raspberrypi/linux/archive/${COMMIT_HASH}.zip -O linux-${VERSION}.zip
unzip linux-${VERSION}.zip
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
    └── linux-6449a0ba6843fe70523eeb7855984054f36f6d24
```

Now copy the config to the linux kernel source code root folder, renaming to `.config`.

```bash
cp store/config-rpi.txt store/linux-6449a0ba6843fe70523eeb7855984054f36f6d24/.config
```

## Start building and customizing the Linux kernel

### Enter the docker development environment

#### Build the Dockerfile

```bash
docker build -t rpi-linux:ubuntu_23.04 .
```

#### Start a container

```bash
docker run -it --rm -v $PWD/store:/work:rw rpi-linux:ubuntu_23.04
```

### Set Env

```bash
export KERNEL=kernel7
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
```

### Menuconfig

```
make menuconfig
make -j$(nproc)
```


## Test the new modules

First, copy the modules from the host to the Raspberry Pi.

```bash
scp \
./drivers/input/touchscreen/ad7879-i2c.ko \
./drivers/input/touchscreen/ad7879.ko \
pi@<rpi ip address>:/home/pi
```

After that, load the module and their dependencies:

```bash
modprobe i2c-gpio
modprobe regman-i2c
insmod /home/pi/ad7879.ko 
insmod /home/pi/ad7879-i2c.ko 
```
