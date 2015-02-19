#!/bin/bash

IMAGE_FILE="$1"

if [ -z "$IMAGE_FILE" ]
then
cat <<USAGE
Set the wallpaper of each virtual deskto using KDE's API.
Expects it to be set to have different widgets for each desktop.

Usage : $0 image-template
    Where image-template contains the placeholder '%d', that will be replaced by the desktop number.
    The resulting file is expected to exist.
USAGE

  exit 0
  
fi

js=$(mktemp)
cat > $js <<SCRIPT
var wallpaper = "$IMAGE_FILE";


var activities = activities();

for (var i=0; i<activities.length; i++) {

  var act = activities[i];

  if (act.readConfig("activity") == "Desktop"
      && act.readConfig("desktop") >= 0) {
    
    // set wallpaper mode
//    act.wallpaperPlugin = "image";
//    act.wallpaperPluginMode = "SingleImage";
    
    act.currentConfigGroup = new Array("Wallpaper", "image");
//    var cfg = act.configKeys;
    // reset config group
//    for (var j=0; j<cfg.length; j++) {
//      act.writeConfig(cfg[j], null);
//    }
    
    // set new config
    act.writeConfig("wallpaper", wallpaper.replace("%d", act.desktop));
    act.writeConfig("userswallpaper", wallpaper.replace("%d", act.desktop));
    act.reloadConfig();
  }
}
SCRIPT


qdbus-qt4 org.kde.plasma-desktop /App local.PlasmaApp.loadScriptInInteractiveConsole "$js" > /dev/null
if which xdotool
then
  xdotool search --name "Desktop Shell Scripting Console – Plasma Desktop Shell" windowactivate key ctrl+e key ctrl+w
else
  echo Could not auto-run script. Please click on the "'Execute'" button
fi

rm -f "$js"