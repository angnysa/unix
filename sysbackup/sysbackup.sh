#!/bin/bash


CONF_DIR=$(dirname $0)

BACKUP_MANAGED=false
BACKUP_UNMANAGED=false
BACKUP_CONFIG=false
BACKUP_PKG_LIST=false
BACKUP_PKG_ARCH=false
BACKUP_DEST=
RSYNC_OPTS="-a --delete"



ARGS=$(getopt -o mucpa -l "managed,unmanaged,config,packages,archives" -n "$0" -- "$@");

if [ $? -ne 0 ];
then
  exit 1
fi

eval set -- "$ARGS";

while true; do
  case "$1" in
    -m|--managed)
      BACKUP_MANAGED=true
      shift
      ;;
    -u|--unmanaged)
      BACKUP_UNMANAGED=true
      shift
      ;;
    -c|--config)
      BACKUP_CONFIG=true
      shift
      ;;
    -p|--packages)
      BACKUP_PKG_LIST=true
      shift
      ;;
    -a|--archives)
      BACKUP_PKG_ARCH=true
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
$0 [-m|--managed] [-u|--managed] [-c|--config] [-p|--packages] [-a|--archives] target
    -m    Backup files managed by packages
    -u    Backup files that are not managed
    -c    Backup modified configuration files
    -p    Backup package list
    -a    Backup package archives
USAGE
}


if ! $BACKUP_MANAGED && ! $BACKUP_UNMANAGED && ! $BACKUP_CONFIG && ! $BACKUP_PKG_LIST && ! $BACKUP_PKG_ARCH
then
  echo ERROR : Enable something to backup
  usage
  exit 1
elif [ -z "$BACKUP_DEST" ]
then
  echo ERROR : Set a destination
  usage
  exit 1
fi


for manager in "$CONF_DIR"/managers/*.sh
do

  function manager_useable {
    return 1
  }

  function list_managed_files {
    echo ERROR : list_managed_files not implemented.
    exit 1
  }

  function list_unmanaged_files {
    comm -23 <(find /etc /opt /usr ! -name lost+found \( -type d -printf '%p/\n' -o -print \) | sort) <(list_managed_files | sort -u)
  }

  function list_modified_config_file {
    echo ERROR : list_modified_config_file not implemented.
    exit 1
  }

  function list_packages {
    echo ERROR : list_packages not implemented.
    exit 1
  }

  function list_packages_files {
    echo ERROR : list_packages_files not implemented.
    exit 1
  }
  
  . "$manager"

  function make_file_stream {

    $BACKUP_MANAGED   && list_managed_files
    $BACKUP_UNMANAGED && list_unmanaged_files
    $BACKUP_CONFIG    && list_modified_config_file
  }

  if manager_useable
  then
    make_file_stream | sort -u | rsync $RSYNC_OPTS --files-from=- / $BACKUP_DEST

    if $BACKUP_PKG_LIST
    then
      rm -rf "$BACKUP_DEST/$(basename "$manager" .sh).archives"
      mkdir "$BACKUP_DEST/$(basename "$manager" .sh).archives"
      list_packages_files | while read file
      do
	cp "$file" "$BACKUP_DEST/$(basename "$manager" .sh).archives"
      done
    fi
    
    $BACKUP_PKG_LIST && list_packages > $BACKUP_DEST/$(basename "$manager" .sh).packages
  fi
  
done
