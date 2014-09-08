#!/bin/bash

KDE_WALLPAPER_FILE=$HOME/.kde4/share/config/plasma-desktop-appletsrc
base=PIA17257
IMAGE_FILE="/data/Picture/nasa/work/${base}_%d.tif"



#!/bin/sh
js=$(mktemp)
cat > $js <<_EOF
var wallpaper = "$IMAGE_FILE";


var activities = activities();

for (var i=0; i<activities.length; i++) {
  if (activities[i].desktop >= 0) {
    activities[i].currentConfigGroup = new Array("Wallpaper", "image");
    activities[i].writeConfig("wallpaper", wallpaper.replace("%d", activities[i].desktop));
    activities[i].writeConfig("userswallpaper", wallpaper.replace("%d", activities[i].desktop));
    activities[i].reloadConfig();
  }
}
_EOF
qdbus-qt4 org.kde.plasma-desktop /App local.PlasmaApp.loadScriptInInteractiveConsole "$js" > /dev/null
which xdotool && xdotool search --name "Desktop Shell Scripting Console – Plasma Desktop Shell" windowactivate key ctrl+e key ctrl+w


rm -f "$js"