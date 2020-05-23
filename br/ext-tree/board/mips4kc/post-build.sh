#!/bin/bash
if [ "$MYDIR" != "" -a -d "$MYDIR" ]
then
    FLOG=$MYDIR/post-build.log
else
    FLOG=/tmp/post-build.log
fi

echo -n "-----> STARTING "            > $FLOG
date                                 >> $FLOG
echo "parameters: $*"                >> $FLOG
echo "BR2EXT:            $BR2EXT"    >> $FLOG
echo "BRDIR:             $BRDIR"     >> $FLOG
echo "IOTROOT:           $IOTROOT"   >> $FLOG
echo "IOTFIRM:           $IOTFIRM"   >> $FLOG
ls $1                                >> $FLOG

DSTROOT="$1"
echo "DSTROOT:           $DSTROOT"   >> $FLOG
#--------------------------------------------------------------------
# configure eth0 up with dhcp
#--------------------------------------------------------------------                                                                             
if grep eth0 $1/etc/network/interfaces >> /tmp/post-build.log
then
    echo "eth0 already configured" >> /tmp/post-build.log
else
    echo "configuring eth0 in interfaces" >> /tmp/post-build.log
    echo >> $DSTROOT/etc/network/interfaces
    echo "auto eth0" >> $1/etc/network/interfaces
    echo "iface eth0 inet dhcp" >> $1/etc/network/interfaces
    echo "  wait-delay 15" >> $1/etc/network/interfaces
fi
#--------------------------------------------------------------------
# copy IOT device root file system if it does exists and it is
# the right one
#--------------------------------------------------------------------
if [ "$IOTROOT" != "" -a -e "$IOTROOT/bin/assistant" ]
then
    echo "copying IOT device root file system" >> $FLOG
    rsync -rav --delete $IOTROOT/ $DSTROOT/mips-root/ >> $FLOG 2>&1
else
    echo "WARNING - IOT device root file system not found" >> $FLOG
fi
#--------------------------------------------------------------------
# copy IOT device firmware files and scripts if it does exists and
# it is the right one
#--------------------------------------------------------------------
mkdir -v $DSTROOT/mips-firm >> $FLOG 2>&1
if [ -e $MYDIR/../qr/set-nandsim.sh ]
then
    cp -v $MYDIR/../qr/set-nandsim.sh $DSTROOT/mips-firm/ >> $FLOG 2>&1
    echo "Creating a 128Mb empty file in /root for eeprom emulation" >> $FLOG 2>&1
    dd if=/dev/zero of=$DSTROOT/root/nandsim.bin bs=1M count=128     >> $FLOG 2>&1
fi    

if [ "$IOTFIRM" != "" -a -e "$IOTFIRM/01-bootloader.bin" ]
then
    cp -v $IOTFIRM/0*.bin             $DSTROOT/mips-firm/ >> $FLOG 2>&1
else
    echo "WARNING - IOT firmware not found" >> $FLOG
fi
echo -n "-----> ENDING   "           >> $FLOG
date                                 >> $FLOG
