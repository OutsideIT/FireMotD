#!/bin/bash
# Script name:  firemotd-explore-package-updates.sh
# Version:      v0.03.200623
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Updates Information
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_package_updates () {
  verify_sudo
  package_updates_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  if [[ -x "/usr/bin/dnf" ]] ; then
    package_updates_type_value="dnf"
    package_updates_path_value=$(command -v dnf 2>/dev/null)
    package_updates_count_value=$(($($package_updates_path_value -d 0 check-update 2>/dev/null | wc -l)-1))
    if [ $package_updates_count_value == -1 ]; then
       package_updates_count_value=0
    fi
  elif [[ -x "/usr/bin/yum" ]] ; then
    package_updates_type_value="yum"
    package_updates_path_value=$(command -v yum 2>/dev/null)
    package_updates_count_value=$(($($package_updates_path_value -d 0 check-update 2>/dev/null | wc -l)-1))
    if [ $os_updates_count_value == -1 ]; then
       package_updates_count=0
    fi
  elif [[ -x "/usr/bin/zypper" ]] ; then
    package_updates_type_value="zypper"
    package_updates_path_value=$(command -v zypper 2>/dev/null)
    package_updates_count_value=$(($($os_updates_path_value list-updates | wc -l)-4))
    if ((package_updates_count_value<=0)) ; then
      package_updates_count_value=0
    fi
  elif [[ -x "/usr/bin/apt-get" ]] ; then
    package_updates_type_value="apt"
    package_updates_path_value=$(command -v apt-get 2>/dev/null)
    package_updates_count_value=$($package_updates_path_value update > /dev/null; $package_updates_path_value upgrade -u -s | grep -c -P "^Inst")
  fi
  package_updates_result=$(jq --arg package_updates_type_value "$package_updates_type_value" --arg package_updates_lastrun "$package_updates_lastrun" --arg package_updates_count_value "$package_updates_count_value" \
    '.firemotd.properties.data.properties.package.properties.updates.properties.type.properties.value = $package_updates_type_value | .firemotd.properties.data.properties.package.properties.updates.properties.type.properties.lastrun = $package_updates_lastrun | .firemotd.properties.data.properties.package.properties.updates.properties.count.properties.value = $package_updates_count_value | .firemotd.properties.data.properties.package.properties.updates.properties.count.properties.lastrun = $package_updates_lastrun' \
    data/firemotd-data.json)
  echo "${package_updates_result}" > data/firemotd-data.json
}

read_package_updates () {
  package_updates_type_value="${firemotd_row_highlightcolor}$(jq -r ".firemotd.properties.data.properties.package.properties.updates.properties.type.properties.value" "$firemotd_data_path")${firemotd_row_charcolor}"
  package_updates_count_value="${firemotd_row_highlightcolor}$(jq -r ".firemotd.properties.data.properties.package.properties.updates.properties.count.properties.value" "$firemotd_data_path")${firemotd_row_charcolor}"
}

if [ "$firemotd_explore_realtime" = "true" ] ; then
  explore_package_updates
  write_log debug info "Explored package-updates: ${package_updates_type_value} ${package_updates_count_value}"
else
  read_package_updates
  write_log debug info "Row $i read package-updates ${package_updates_type_value} ${package_updates_count_value}"
fi
