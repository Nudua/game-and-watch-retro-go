FROM ubuntu

WORKDIR /opt

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
        make wget curl sudo vim git unzip lz4 \
        python3 python-is-python3 libncurses5 \
        && \
    wget -O toolchain.tar.bz2 'https://github.com/kbeckmann/gcc-toolchains/raw/main/10-2020-q4-major/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2' && \
    tar xf toolchain.tar.bz2 && \
    rm -f toolchain.tar.bz2 && \
    useradd -m docker && echo "docker:docker" | chpasswd && \
    chown docker:docker /opt && \
    echo "docker ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

ENV GCC_PATH=/opt/gcc-arm-none-eabi-10-2020-q4-major/bin

USER docker

# Install openocd nightly
RUN wget https://nightly.link/kbeckmann/ubuntu-openocd-git-builder/workflows/docker/master/openocd-git.deb.zip && \
    unzip openocd-git.deb.zip && \
    sudo apt -y install ./openocd-git_*_amd64.deb
ENV OPENOCD="/opt/openocd-git/bin/openocd"

RUN git clone --depth 1 https://github.com/ghidraninja/game-and-watch-flashloader
RUN cd game-and-watch-flashloader && make -j$(nproc)

COPY . /opt/game-and-watch-retro-go
RUN sudo chown -R docker:docker /opt/game-and-watch-retro-go

WORKDIR /opt/game-and-watch-retro-go

CMD /bin/bash
