#!/bin/bash

# Input should be a single line from lsusb output:
DATA=$1

# Read the bus number:
BUS=`echo $DATA | grep -Po 'Bus 0*\K[1-9]+'`

# Read the device number:
DEV=`echo $DATA | grep -Po 'Device 0*\K[1-9]+'`

FOUND=false
USB_Serial=""

# Search for the serial number of the PenDrive:
while read line
do
  if [ $FOUND == true ]; then
    USB_Serial=`echo "$line" | grep -Po 'SerialNumber=\K.*'`
    if [ "$USB_Serial" != "" ]; then
      break;
    fi
  fi

  if [ "`echo "$line" | grep -e "Bus=0*$BUS.*Dev#= *$DEV"`" != "" ]; then
    FOUND=true
  fi
done <<< "$(usb-devices)"

# Get the base name of the block device, e.g.: "sdx"
BASENAME=`file /dev/disk/by-id/* | grep -v 'part' | grep -Po "$USB_Serial.*/\K[^/]+$"`

# Build the full address, e.g.: "/dev/sdx"
NAME="/dev/$BASENAME"

# Output the address:
echo $NAME

