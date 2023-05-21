FROM ubuntu:20.04 as base

# Set DEBIAN_FRONTEND to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt install -y ca-certificates

RUN apt install -y sudo
RUN apt install -y ssh
RUN apt install -y netplan.io
RUN apt install -y nano

# Install WLAN packages
RUN apt install -y wireless-tools
RUN apt install -y wpasupplicant

# Install basic networking tools
RUN apt install -y iputils-ping
RUN apt install -y dnsutils

# Install basic text editor
RUN apt install -y vim

# Install GUI (XFCE)
RUN apt install -y xfce4

# Install our resizerootfs service
COPY root/etc/systemd/ /etc/systemd

RUN systemctl enable resizerootfs
RUN systemctl enable ssh
RUN systemctl enable systemd-networkd
RUN systemctl enable setup-resolve

RUN mkdir -p /opt/nvidia/l4t-packages
RUN touch /opt/nvidia/l4t-packages/.nv-l4t-disable-boot-fw-update-in-preinstall

COPY root/etc/apt/ /etc/apt
COPY root/usr/share/keyrings /usr/share/keyrings
RUN apt update

# nv-l4t-usb-device-mode
RUN apt install -y bridge-utils

# Install NVIDIA Jetson packages
RUN apt install -y -o Dpkg::Options::="--force-overwrite" \
    nvidia-l4t-core \
    nvidia-l4t-init \
    nvidia-l4t-bootloader \
    nvidia-l4t-camera \
    nvidia-l4t-initrd \
    nvidia-l4t-xusb-firmware \
    nvidia-l4t-kernel \
    nvidia-l4t-kernel-dtbs \
    nvidia-l4t-kernel-headers \
    nvidia-l4t-cuda \
    jetson-gpio-common \
    python3-jetson-gpio

RUN rm -rf /opt/nvidia/l4t-packages

COPY root/ /

# Create a user and set the password
RUN useradd -ms /bin/bash jetson
RUN echo 'nano:1234' | chpasswd

RUN usermod -a -G sudo nano