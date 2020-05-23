#!/bin/bash
export QEMU_AUDIO_DRV="none"
export MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export BRDIR="$( cd $MYDIR/../buildroot-2* && pwd )"
export BRIMG=$BRDIR/output/images


qemu-system-mipsel -M          malta \
		   -m          256 \
		   -kernel     $BRIMG/vmlinux \
		   -nographic  \
 		   -hda        $BRIMG/rootfs.ext2 \
                   -net        nic,model=e1000 \
                   -net        user,hostfwd=tcp::2222-:22,hostfwd=tcp::9000-:9000 \
		   -no-reboot  \
		   -append     "root=/dev/hda console=uart0"

echo
