#!/bin/bash
set -e

SCRIPT_DIR=$(realpath $(dirname ${BASH_SOURCE[0]}))
source ${SCRIPT_DIR}/../env.sh

# install sgxsdk
sudo ${LINUX_SGX_SRC_DIR}/linux/installer/bin/sgx_linux_x64_sdk_*.bin <<EOF
no
/opt/intel/
EOF

# install sgxpsw
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