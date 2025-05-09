#!/bin/bash
set -e

SCRIPT_DIR=$(realpath $(dirname ${BASH_SOURCE[0]}))
source ${SCRIPT_DIR}/env.sh

echo -e "${CYAN}Remove toolset at /usr/local/bin${NC}"
sudo rm -f /usr/local/bin/{ar,as,ld,ld.gold,objcopy,objdump,ranlib}
echo -e "${CYAN}Remove apt source${NC}"
sudo rm -f /etc/apt/sources.list.d/intel-sgx.list

echo -e "${CYAN}Restore ${LINUX_SGX_SRC_DIR}${NC}"
cd ${LINUX_SGX_SRC_DIR}
make distclean -s
# comment to avoid user forget to git add recent modification
git restore .
git clean -fdx
