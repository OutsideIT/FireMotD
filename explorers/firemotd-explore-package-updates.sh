#!/bin/bash
# Script name:  firemotd-explore-package-updates.sh
# Version:      v0.05.200923
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Host Information
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_package_updates () {
  if [[ -x "/usr/bin/dnf" ]] ; then
    package_manager_value="dnf"
    package_manager_exec=$(command -v dnf 2>/dev/null)
    package_updates_value=$(($($package_manager_exec -d 0 check-update 2>/dev/null | wc -l)-1))
    if [ $package_updates_value == -1 ]; then
       package_updates_value=0
    fi
  elif [[ -x "/usr/bin/yum" ]] ; then
    package_manager_value="yum"
    package_manager_exec=$(command -v yum 2>/dev/null)
    package_updates_value=$(($($package_manager_exec -d 0 check-update 2>/dev/null | wc -l)-1))
    if [ $package_updates_value == -1 ]; then
       package_updates_value=0
    fi
  elif [[ -x "/usr/bin/apt-get" ]] ; then
    package_manager_value="apt"
    package_manager_exec=$(command -v apt-get 2>/dev/null)
    package_updates_value=$($package_manager_exec update > /dev/null; $package_manager_exec upgrade -u -s | grep -c -P "^Inst")
  elif [[ -x "/usr/bin/zypper" ]] ; then
    package_manager_value="zypper"
    package_manager_exec=$(command -v zypper 2>/dev/null)
    package_updates_value=$(($($package_manager_exec list-updates | wc -l)-4))
  fi
  validate_package_updates
}

write_package_updates () {
  package_updates_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  package_updates_result=$(jq --arg package_updates_value "${package_updates_value}" --arg package_updates_lastrun "${package_updates_lastrun}" \
    '.firemotd.properties.data.properties.package.properties.updates.properties.value = $package_updates_value | .firemotd.properties.data.properties.package.properties.updates.properties.lastrun = $package_updates_lastrun' \
    "$firemotd_data_path")
  echo "${package_updates_result}" > "$firemotd_data_path"
}

read_package_updates () {
  package_updates_value="$(jq -r ".firemotd.properties.data.properties.package.properties.updates.properties.value" "$firemotd_data_path")"
  validate_package_updates
  package_updates_value="${firemotd_row_highlightcolor}${package_updates_value}${firemotd_row_charcolor}"
}

validate_package_updates () {
  if [[ "$package_updates_value" =~ ^([0-9]{1,3}|null)$ ]]; then
    write_log debug info "${firemotd_log_row_prefix}firemotd explorer valid package_updates_value \"${package_updates_value}\" detected"
  else
    write_log output error "${firemotd_log_row_prefix}firemotd explorer invalid package_updates_value \"${package_updates_value}\" detected. Please debug."
    exit 2
  fi
}

write_log verbose info "${firemotd_log_row_prefix}firemotd explorer firemotd-explore-package-updates.sh - ${firemotd_explore_type}"
if [ "${firemotd_explore_type}" = "write" ] ; then
  explore_package_updates
  write_package_updates
elif [ "${firemotd_explore_type}" = "read" ] ; then
  read_package_updates
fi
