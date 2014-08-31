#!/bin/bash

IMG_DB=/data/Picture/nasa
IMG_VWALL_BASE=$HOME/Pictures/wallpapers/multi-vdesktop/
DELAY=5


while true
do
  IMG_BASES=$(ls $IMG_DB/*_0.* | cut -d_ -f1)
  
  for img in $IMG_BASES
  do

    echo Setting $img

    ls ${img}_* | sed 's/[_\.]/ /g' | while read head idx ext
      do
	alias=${IMG_VWALL_BASE}/$idx/wallpaper_$idx.$ext
	rm -f $alias
	ln -s ${img}_$idx.$ext $alias
      done
    
    sleep $DELAY
  done
done
