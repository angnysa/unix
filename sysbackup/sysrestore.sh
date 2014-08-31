#!/bin/bash


CONF_DIR=$(dirname $0)

RESTORE_FILES=false
RESTORE_PKG_LIST=false
RESTORE_PKG_ARCH=false
BACKUP_DEST=



ARGS=$(getopt -o fla -l "files,packages-from-list,packages-from-archive" -n "$0" -- "$@");

if [ $? -ne 0 ];
then
  exit 1
fi

eval set -- "$ARGS";

while true; do
  case "$1" in
    -f|--files)
      RESTORE_FILES=true
      shift
      ;;
    -l|--packages-from-list)
      RESTORE_PKG_LIST=true
      RESTORE_PKG_ARCH=false
      shift
      ;;
    -a|--packages-from-archive)
      RESTORE_PKG_LIST=false
      RESTORE_PKG_ARCH=true
      shift
      ;;
    --)
      shift
      break
      ;;
  esac
done

BACKUP_DEST="$1"

function usage {
  cat <<USAGE
Usage :
$0 [-f|--files] [-l|--packages-from-list] [-a|--packages-from-archive] backup destination
    -f    Restore files stored in the backup
    -l    Restore packages as listed in the backed up list from the central repository
    -a    Restore packages as listed in the backed up list from the stored archives
USAGE
}


if ! $RESTORE_FILES && ! $RESTORE_PKG_LIST && ! $RESTORE_PKG_ARCH
then
  echo ERROR : Enable something to retore
  usage
  exit 1
elif [ -z "$BACKUP_DEST" ]
then
  echo ERROR : Set a backup
  usage
  exit 1
fi


for manager in "$CONF_DIR"/managers/*.sh
do

  function manager_useable {
    return 1
  }

  function restore_packages {
    echo ERROR : restore_packages not implemented.
    exit 1
  }

  function restore_package_archives {
    echo ERROR : restore_package_archives not implemented.
    exit 1
  }
  
  . "$manager"

  if $RESTORE_PKG_LIST
  then
    cat $BACKUP_DEST/$(basename "$manager" .sh).packages | restore_packages
  else
    cat $BACKUP_DEST/$(basename "$manager" .sh).packages | restore_package_archives "$BACKUP_DEST/$(basename "$manager" .sh).archives"
  fi
  
done