#!/bin/bash

function manager_useable {
  which pacman >/dev/null 2>/dev/null
  return $?
}

function list_managed_files {
  pacman -Qlq
}

function list_modified_config_file {
  pacman -Qii  | grep '^MODIFIED' | cut -f2
}

function list_packages {
  pacman -Qetq
}

function list_packages_files {
  find /var/cache/pacman/pkg/
}

function restore_packages {
  xargs pacman -S
}

function restore_package_archives {
  if [ -z "$1" ]
  then
    cat | xargs pacman -S 
  else
    cat | while read pkg
    do
      pacman 
    done
  fi
}