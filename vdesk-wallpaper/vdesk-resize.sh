#!/bin/bash


if ! which getopt identify convert bc >/dev/null
then
  echo ERROR : imagemagick and GNU bc required.
  exit 1
fi

img=
resolution=
layout=
zoom=auto
align=%x%
usage=false


ARGS=$(getopt -o r:l:z:a: -l "resolution:,layout:,zoom:,align" -n "$0" -- "$@");

if [ $? -ne 0 ];
then
  usage=true
fi

while true
do
  case "$1" in
    -r|--resolution)
      shift
      resolution=$1
      shift
      ;;
    -l|--layout)
      shift
      layout=$1
      shift
      ;;
    -z|--zoom)
      shift
      zoom=$1
      shift
      ;;
    -a|--align)
      shift
      =$1
      shift
      ;;
    '')
      break
      ;;
    *)
      img=$1
      shift
      ;;
  esac
done


if [ -z "$resolution" ]
then
  echo ERROR : Resolution required >&2
  usage=true
fi

if [ -z "$layout" ]
then
  echo ERROR : Layout required >&2
  usage=true
fi

if [ -z "$img" ]
then
  echo ERROR : Image required >&2
  usage=true
fi

if [ ! -r "$img" ]
then
  echo ERROR : Image "'$img'" is not readable >&2
  usage=true
fi

if $usage
then
  cat <<USAGE
$0 Usage :
    -r|--resolution
            Monitor resolution, as <lines>x<columns>
    -l|--layout
            Virtual desktop layout, as <lines>x<columns>
    -z|--zoom
            Zoom factor, as a real number. Automatically calculated if left blank.
    -a|--align
            Alignment of the full wallpaper on the image, as <x-align>x<y-align>. (Centered by default)
            Both alignment can be :
            - A positive number (offset from left/top)
            - A negative number (offset from right/bottom)
            - '%' (center)
USAGE
  exit 1
fi

function debug {
  echo [DEBUG] $@
}


# resolution (lines/columns)
resolution_c=${resolution%x*}
resolution_l=${resolution#*x}
debug res = $resolution_c x $resolution_l

# layout (lines/columns)
layout_c=${layout%x*}
layout_l=${layout#*x}
debug layout = $layout_c x $layout_l

# alignment (horizontal/vertical)
align_v=${align%x*}
align_h=${align#*x}
debug align = +$align_h +$align_v

# path/to/image .ext
img_base=${img%.*}
img_ext=${img##*.}
debug image = $img_base $img_ext

# image size (width/height)
img_size=$(identify $img | cut -f3 -d' ' )
img_w=${img_size%x*}
img_h=${img_size#*x}
debug image = $img_w x $img_h

# full desktop size, before zoom (lines/columns)
desk_l=$(( $resolution_l * $layout_l ))
desk_c=$(( $resolution_c * $layout_c ))
debug desktop = $desk_c x $desk_l

# 

# Zoom required to cover as much of the image as possible
if [ $zoom = 'auto' ]
then
  zoom=$(bc -l <<< "h=$img_w / $desk_c; v=$img_h / $desk_l; if (v > h) h else v")
fi
debug zoom = $zoom

# Size of each desktop, zoomed (lines/columns)
zres_l=$(bc -l <<< "$resolution_l * $zoom" | cut -d'.' -f1)
zres_c=$(bc -l <<< "$resolution_c * $zoom" | cut -d'.' -f1)
debug zoomed resolution = $zres_c x $zres_l

# Size of the full desktop, zoomed (lines/columns)
zdesk_l=$(bc -l <<< "$zres_l * $layout_l")
zdesk_c=$(bc -l <<< "$zres_c * $layout_c")
debug zoomed desktop = $zdesk_c x $zdesk_l


# image offset
if [ "$align_h" = "%" ]
then
  align_h=$(bc -l <<< "$img_w / 2 - $zdesk_c / 2 + .5" | cut -d'.' -f1)
elif [ "$align_h" -lt 0 ]
then
  align_h=$(bc -l <<< "$img_w - $align_h - $zdesk_c")
fi
[ -z "$align_h" ] && align_h=0

if [ "$align_v" = "%" ]
then
  align_v=$(bc -l <<< "$img_h / 2 - $zdesk_l / 2 + .5" | cut -d'.' -f1)
elif [ "$align_v" -lt 0 ]
then
  align_v=$(bc -l <<< "$img_h - $align_v - $zdesk_l")
fi
[ -z "$align_v" ] && align_v=0

debug offset = +$align_h +$align_v




if [ $(( $align_h + $zdesk_c )) -gt $img_w -o $(( $align_v + $zdesk_l )) -gt $img_h ]
then
  echo ERROR : image is not large enough : Size is ${img_w}x${img_h}, ${zdesk_c}x${zdesk_l} or greater required
  exit 1
fi



#convert "$img" +repage -crop ${zdesk_c}x${zdesk_l}+$align_h+$align_v "$img_base"_cropped.$img_ext # -crop ${zres_c}x${zres_l} +repage "$img_base"_%d.$img_ext


