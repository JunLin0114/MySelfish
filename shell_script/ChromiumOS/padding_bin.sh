#!/bin/sh
# Load shflags
SCRIPT=$(readlink -f "$0")
echo $SCRIPT
SCRIPT_PATH=$(dirname ${SCRIPT})
echo $SCRIPT_PATH
SHFLAGS_FILE="${SCRIPT_PATH}/shflags"
if [ -f ${SHFLAGS_FILE} ]; then
  . "${SHFLAGS_FILE}" || echo  "Couldn't find shflags"
else
  echo "cannot source shflags file"
  exit 1
fi

DEFINE_boolean new "${FLAGS_FALSE}" \
    "Create new file rahter than pad to an exist file"
DEFINE_boolean zero "${FLAGS_FALSE}" \
    "Padding the file with all 0s"
DEFINE_string size "256K" \
    "Size of bin file to be generated(in byte)"
DEFINE_string binfile "" \
    "assign bin file to add padding"
DEFINE_boolean top "${FLAGS_TRUE}" \
    "bin file is at the top or bottom of Padding? default:bottom "
    
FLAGS_HELP="usage: $0 [flags]"
FLAGS "$@" || exit 1


if [ "${FLAGS_new}" = ${FLAGS_TRUE} ]; then
    echo "Create a new bin file"
    if [ "${FLAGS_zero}" = ${FLAGS_TRUE} ]; then
        dd if=/dev/zero of=/tmp/padding_0.bin bs=${FLAGS_size} count=1 
    else
    # dd if=/dev/zero bs=512K count=1 | tr '\0' '\377' > /tmp/padding_1.bin
        dd if=/dev/zero bs=${FLAGS_size} count=1 | tr '\0' '\377' > /tmp/padding_1.bin
    fi
    exit 0
fi
if ! resolved=$(readlink -f "$(echo ${FLAGS_binfile})"); then
    echo --${FLAGS_binfile}
    echo --${resolved}
	echo "Bin File Path is Invalid"
    exit 1
fi

echo --${resolved}
FLAGS_binfile=${resolved}
echo "BIN File Name = ${FLAGS_binfile}"
if [ -e "${FLAGS_binfile}" ]; then
	eval BINFILE=${FLAGS_binfile}
	BIN_BASE_NAME=$( basename ${BINFILE} )
	if [ "${FLAGS_top}" = ${FLAGS_TRUE} ]; then
		echo "BASE name = ${BIN_BASE_NAME}"
		echo "Add padding at the bottom"
	  	{       # Patch temp image up to SPI_SIZE
			cat $FLAGS_binfile
			if [ "${FLAGS_zero}" = ${FLAGS_TRUE} ]; then
				dd if=/dev/zero bs=${FLAGS_size} count=1
			else
				dd if=/dev/zero bs=${FLAGS_size} count=1 | tr '\0' '\377'
			fi
		} > /tmp/${BIN_BASE_NAME}.pad
	else
		echo "BASE name = ${BIN_BASE_NAME}"
		echo "Add padding at the top"
	  	{       # Patch temp image up to SPI_SIZE
			if [ "${FLAGS_zero}" = ${FLAGS_TRUE} ]; then
				dd if=/dev/zero bs=${FLAGS_size} count=1
			else
				dd if=/dev/zero bs=${FLAGS_size} count=1 | tr '\0' '\377'
			fi
			cat $FLAGS_binfile
		} > /tmp/${BIN_BASE_NAME}.pad
	fi
fi
