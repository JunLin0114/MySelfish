#!/bin/bash

# Loads script libraries.
. "/usr/share/misc/shflags" || exit 1

# Flags
DEFINE_string board "noboard" "Override board reported by target"
DEFINE_string partition "nopart" "Override kernel partition reported by target"

# Parse command line
FLAGS_HELP="usage: $0 [flags]"
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"
if [[ $# -gt 0 ]]; then
	die "invalid arguments: \"$*\""
fi

set -e
get_bootargs() {
  cat "${HOME}/trunk/src/build/images/${FLAGS_board}/latest/config.txt"
}
make_kernelimage() {
  local bootloader_path
  local kernel_image
  local config_path="$(mktemp /tmp/config.txt.XXXXX)"
  bootloader_path="/lib64/bootstub/bootstub.efi"
  kernel_image="/build/${FLAGS_board}/boot/vmlinuz"
  get_bootargs > "${config_path}"
  vbutil_kernel --pack /tmp/new_kern.bin \
    --keyblock /usr/share/vboot/devkeys/kernel.keyblock \
    --signprivate /usr/share/vboot/devkeys/kernel_data_key.vbprivk \
    --version 1 \
    --config ${config_path} \
    --bootloader "${bootloader_path}" \
    --vmlinuz "${kernel_image}" \
    --arch x86
  rm "${config_path}"
}

copy_kernelimage() {
  sudo dd of="${FLAGS_partition}" bs=4K < "/tmp/new_kern.bin"
}

main() {
    echo "${FLAGS_board}"
if [[ ${FLAGS_board} = "noboard" ]]; then
    echo "Board name must be specified!"
    exit 1
fi
    echo "${FLAGS_partition}"
if ! [ -a ${FLAGS_partition} ]; then
    echo "Partition ${FLAGS_partition} does not exist"
    exit 1
fi
if [[ "${FLAGS_partition}" == /dev/sda* ]]; then
    echo "Partition ${FLAGS_partition} may be the system partition and is not Permitted to be Overwrited!!"
    exit 1
fi
if ! [[ "${FLAGS_partition}" == /dev/sd*2 ]]; then
    echo "Kernel partition should be in /dev/sdx2"
    exit 1
fi
read -p "Write Linux kernel to ${FLAGS_partition} (it will overwrite the content of the partition!!) ?(Y/N)" choice
case "${choice}" in 
  y|Y ) echo ;;
  n|N ) exit 1 ;;
esac

make_kernelimage
copy_kernelimage
}

main "$@"
