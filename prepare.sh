#!/bin/bash
set -e

SCRIPT_DIR=$(realpath $(dirname ${BASH_SOURCE[0]}))
source ${SCRIPT_DIR}/env.sh

echo -e "${CYAN}Install dependencies${NC}"
sudo apt-get install -y build-essential ocaml ocamlbuild automake autoconf libtool wget python-is-python3 git perl protobuf-compiler debhelper reprepro unzip pkgconf lsb-release
sudo apt-get install -y libssl-dev libcurl4-openssl-dev libprotobuf-dev libboost-dev libboost-system-dev libboost-thread-dev libsystemd0
sudo apt-get install -y fakeroot
sudo apt-get install -y --allow-downgrades cmake=3.22.1-1ubuntu1 cmake-data=3.22.1-1ubuntu1

echo -e "${CYAN}Prepare in ${LINUX_SGX_SRC_DIR}${NC}"
cd ${LINUX_SGX_SRC_DIR}
make preparation
if [ -d "external/toolset/${UBUNTU_DIST}" ]
then
    echo -e "${CYAN}Install toolset for ${UBUNTU_DIST}${NC}"
    sudo cp external/toolset/${UBUNTU_DIST}/* /usr/local/bin
else
    echo -e "${YELLOW}No toolset for ${UBUNTU_DIST}${NC}"
fi

cd ${PROJECT_DIR}
echo -e "${CYAN}Set APT source${NC}"
SKIP_ENV=1 source ./utils/set_apt_source.sh

sudo mkdir -p /etc/init
