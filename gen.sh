#!/bin/bash

# reference
# https://wiki.debian.org/DebianInstaller/Preseed/EditIso

set -e
set -u

ISOFILE=debian-11.6.0-amd64-netinst.iso
ISOFILE_FINAL=debian-netinst-preseed.iso
ISODIR=debian-iso
ISODIR_WRITE=$ISODIR-rw

function green(){
    echo -e "\x1B[32m=== $1 === \x1B[0m"
    if [ ! -z "${2}" ]; then
        echo -e "\x1B[33m* OK \x1B[0m"
        echo -e "\x1B[32m $($2) \x1B[0m"
    fi
}

cleanbuild() {
    rm -rf $ISODIR $ISODIR_WRITE irmod/ $ISOFILE_FINAL
}

mountiso(){
    [ -d $ISODIR ] || mkdir -p $ISODIR
    mount -o loop $ISOFILE $ISODIR 2> /dev/null 
}

copydir(){    
    rm -rf $ISODIR_WRITE || true
    [ -d $ISODIR_WRITE ] || mkdir -p $ISODIR_WRITE
    rsync -a -H --exclude=TRANS.TBL $ISODIR/ $ISODIR_WRITE 
}

umountiso(){
    umount $ISODIR 2> /dev/null
}


extract_rebuild(){
  chmod +w -R $ISODIR_WRITE/install.amd/
  gunzip $ISODIR_WRITE/install.amd/initrd.gz
  # add preseed.cfg file to archive initrd 
  echo preseed.cfg | cpio -H newc -o -A -F $ISODIR_WRITE/install.amd/initrd
  gzip $ISODIR_WRITE/install.amd/initrd
  chmod -w -R $ISODIR_WRITE/install.amd/
}


modifyboot(){
    sed 's/initrd.gz/initrd.gz file=\/preseed.cfg/' -i $ISODIR_WRITE/isolinux/txt.cfg
    sed 's/timeout 0/timeout 1/' -i $ISODIR_WRITE/isolinux/isolinux.cfg
    sed 's/default vesamenu.c32/default install/' -i $ISODIR_WRITE/isolinux/isolinux.cfg
}

buildinitrd(){
    cd irmod
    find . | cpio -H newc --create | gzip -9 > ../$ISODIR_WRITE/install.amd/initrd.gz
}

delirmod(){
    rm -fr irmod/
}

fixmd5(){
    cd $ISODIR_WRITE
    chmod +w md5sum.txt
    md5sum $(find -follow -type f 2> /dev/null ) > md5sum.txt 
    chmod -w md5sum.txt
}


makeiso(){
    genisoimage -o $ISOFILE_FINAL \
       -r -J -no-emul-boot -boot-load-size 4 \
       -boot-info-table \
       -b isolinux/isolinux.bin \
       -c isolinux/boot.cat ./$ISODIR_WRITE 2> /dev/null
}


generate_hostname(){

    rm  variables.tf 
    cat > variables.tf <<EOL
    variable "vm_name"  {
        description = "VM name"
        default = "$1"
    }
EOL

    cat >> variables.tf <<EOL
    variable "libvirt_disk_path" {
        description = "path for libvirt pool"
        default     = "/var/lib/libvirt/pool/${1}-pool"   
    }
EOL

    cat >> variables.tf <<EOL
    variable "libvirt_pool_name" {
        description = "path for libvirt pool"
        default     = "${1}-pool"   
    }
EOL
    sed -i "s/d-i netcfg\/get_hostname string .*/d-i netcfg\/get_hostname string $1/g" preseed.cfg
}


if [ $# -lt 1 ]
  then
    green "INFO" ""
    echo "No arguments supplied"
    echo "usage ./gen.sh <vm_name>"
    exit 1
fi


green "GENERATE VARIABLE " "generate_hostname $1"
green "CLEAN BUILD" cleanbuild
green 'MOUNTING ISO9660 FILESYSTEM...' mountiso
green 'COPING TO WRITABLE DIR...' copydir
green 'UNMOUNT ISO DIR' umountiso
green "EXTRACT INITRD" extract_rebuild
green "MODIFY BOOT" modifyboot
green "FIX MD5" fixmd5
green "MAKE ISO" makeiso

#green "CLEAN BUILD" cleanbuild

