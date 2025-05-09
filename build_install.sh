#!/bin/bash
set -e

SCRIPT_DIR=$(realpath $(dirname ${BASH_SOURCE[0]}))
source ${SCRIPT_DIR}/env.sh

sudo mkdir -p /etc/init

COMMON_FLAGS=""
if [ "$DEBUG_BUILD" -eq 1 ]; then
    export DEB_BUILD_OPTIONS=nostrip
    COMMON_FLAGS+=" DEBUG=1"
fi
echo -e "${YELLOW}COMMON_FLAGS: ${COMMON_FLAGS}${NC}"

#################### enter linux-sgx ####################
echo -e "${CYAN}Enter ${LINUX_SGX_SRC_DIR}${NC}"
cd ${LINUX_SGX_SRC_DIR}

#################### build sgxsdk ####################
# rule "sdk_install_pkg" depends on rule "sdk"
if ls ${LINUX_SGX_SRC_DIR}/linux/installer/bin/sgx_linux_x64_sdk_*.bin
then
    echo -e "${YELLOW}SGX SDK installer already exists${NC}"
else
    echo -e "${CYAN}Build sdk_install_pkg${NC}"
    make sdk_install_pkg_no_mitigation USE_OPT_LIBS=3 ${COMMON_FLAGS} -j${WORKER_NUM} -s
fi

#################### install sgxsdk ####################
if [ ! -d "${SGX_INSTALL_DIR}/sgxsdk" ]; then
    echo -e "${CYAN}Install SGX SDK at ${SGX_INSTALL_DIR}${NC}"
    sudo ${LINUX_SGX_SRC_DIR}/linux/installer/bin/sgx_linux_x64_sdk_*.bin <<EOF
no
${SGX_INSTALL_DIR}
EOF
else
    echo -e "${YELLOW}Already installed SGX SDK at ${SGX_INSTALL_DIR}${NC}"
fi
source ${SGX_INSTALL_DIR}/sgxsdk/environment

#################### build sgxpsw (relies on sgxsdk) ####################
# rule "deb_local_repo" depends on rule "deb_psw_pkg" which indirectly depends on rule "psw"
echo -e "${CYAN}Build psw${NC}"
make psw ${COMMON_FLAGS} -j${WORKER_NUM} -s
echo -e "${CYAN}Build deb_psw_pkg${NC}"
make deb_psw_pkg ${COMMON_FLAGS} -s

sudo dpkg -i ${LINUX_SGX_SRC_DIR}/linux/installer/deb/libsgx-urts/libsgx-urts_*_amd64.deb ${LINUX_SGX_SRC_DIR}/linux/installer/deb/libsgx-enclave-common/libsgx-enclave-common_*_amd64.deb

echo -e "${CYAN}Build deb_local_repo${NC}"
make deb_local_repo ${COMMON_FLAGS} -s

#################### install sgxpsw ####################
echo -e "${CYAN}Install SGX PSW${NC}"

sudo cp -r ${LINUX_SGX_SRC_DIR}/linux/installer/deb/sgx_debian_local_repo /opt/

sudo apt-get update
sudo apt-get install -y \
    libsgx-ae-epid libsgx-ae-id-enclave libsgx-ae-le libsgx-ae-pce libsgx-ae-qe3 libsgx-ae-qve \
    libsgx-aesm-ecdsa-plugin.* libsgx-aesm-epid-plugin.* libsgx-aesm-launch-plugin.* libsgx-aesm-pce-plugin.* libsgx-aesm-quote-ex-plugin.* \
    libsgx-dcap-default-qpl.* libsgx-dcap-ql.* libsgx-dcap-quote-verify.* \
    libsgx-enclave-common.* \
    libsgx-epid.* \
    libsgx-headers \
    libsgx-launch.* \
    libsgx-pce-logic.* libsgx-qe3-logic.* \
    libsgx-quote-ex.* \
    libsgx-ra-network.* libsgx-ra-uefi.* \
    libsgx-uae-service.* \
    libsgx-urts.* \
    sgx-aesm-service.*
