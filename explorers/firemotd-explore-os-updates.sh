#!/bin/bash
# Script name:  firemotd-explore-os-updates.sh
# Version:      v0.01.200615
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Updates Information
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_os_updates () {
  verify_sudo
  os_updates_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  if [[ -x "/usr/bin/dnf" ]] ; then
    os_updates_type_value="dnf"
    os_updates_path_value=$(command -v dnf 2>/dev/null)
    os_updates_count_value=$(($($os_updates_path_value -d 0 check-update 2>/dev/null | wc -l)-1))
    if [ $os_updates_count_value == -1 ]; then
       os_updates_count_value=0
    fi
  elif [[ -x "/usr/bin/yum" ]] ; then
    os_updates_type_value="yum"
    os_updates_path_value=$(command -v yum 2>/dev/null)
    os_updates_count_value=$(($($os_updates_path_value -d 0 check-update 2>/dev/null | wc -l)-1))
    if [ $os_updates_count_value == -1 ]; then
       os_updates_count=0
    fi
  elif [[ -x "/usr/bin/zypper" ]] ; then
    os_updates_type_value="zypper"
    os_updates_path_value=$(command -v zypper 2>/dev/null)
    os_updates_count_value=$(($(zypper list-updates | wc -l)-4))
    if ((os_updates_count_value<=0)) ; then
      os_updates_count_value=0
    fi
  elif [[ -x "/usr/bin/apt-get" ]] ; then
    os_updates_type_value="apt"
    os_updates_path_value=$(command -v apt-get 2>/dev/null)
    os_update_count_value=$(apt-get update > /dev/null; apt-get upgrade -u -s | grep -c -P "^Inst")
  fi
  write_log debug info "os_updates_type_value: $os_updates_type_value"
  write_log debug info "os_updates_path_value: $os_updates_path_value"
  write_log debug info "os_updates_count_value: $os_updates_count_value"
  os_updates_result=$(jq --arg os_updates_type_value "$os_updates_type_value" --arg os_updates_lastrun "$os_updates_lastrun" \
    --arg os_updates_path_value "$os_updates_path_value" --arg os_updates_count_value "$os_updates_count_value" \
    '.os.properties.updates.properties.type.properties.value = $os_updates_type_value | .os.properties.updates.properties.type.properties.lastrun = $os_updates_lastrun | .os.properties.updates.properties.path.properties.value = $os_updates_path_value | .os.properties.updates.properties.path.properties.lastrun = $os_updates_lastrun | .os.properties.updates.properties.count.properties.value = $os_updates_count_value | .os.properties.updates.properties.count.properties.lastrun = $os_updates_lastrun' \
    data/firemotd-data.json)
  echo "${os_updates_result}" > data/firemotd-data.json
}

write_log verbose info "Exploring os updates"
explore_os_updates
