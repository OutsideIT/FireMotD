#!/bin/bash
# Script name:  firemotd-explore-package-manager.sh
# Version:      v0.05.200923
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Host Information
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_package_manager () {
  if [[ -x "/usr/bin/dnf" ]] ; then
    package_manager_value="dnf"
  elif [[ -x "/usr/bin/yum" ]] ; then
    package_manager_value="yum"
  elif [[ -x "/usr/bin/apt-get" ]] ; then
    package_manager_value="apt"
  elif [[ -x "/usr/bin/zypper" ]] ; then
    package_manager_value="zypper"
  fi
  validate_package_manager
}

write_package_manager () {
  package_manager_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  package_manager_result=$(jq --arg package_manager_value "${package_manager_value}" --arg package_manager_lastrun "${package_manager_lastrun}" \
    '.firemotd.properties.data.properties.package.properties.manager.properties.value = $package_manager_value | .firemotd.properties.data.properties.package.properties.manager.properties.lastrun = $package_manager_lastrun' \
    "$firemotd_data_path")
  echo "${package_manager_result}" > "$firemotd_data_path"
}

read_package_manager () {
  package_manager_value="$(jq -r ".firemotd.properties.data.properties.package.properties.manager.properties.value" "$firemotd_data_path")"
  validate_package_manager
  package_manager_value="${firemotd_row_highlightcolor}${package_manager_value}${firemotd_row_charcolor}"
}

validate_package_manager () {
  if [[ "${package_manager_value}" =~ ^[a-z]{3,7}$ ]]; then
    write_log debug info "${firemotd_log_row_prefix}firemotd explorer valid package_manager_value \"${package_manager_value}\" detected"
  else
    write_log output error "${firemotd_log_row_prefix}firemotd explorer invalid package_manager_value \"${package_manager_value}\" detected. Please debug."
    exit 2
  fi
}

write_log verbose info "${firemotd_log_row_prefix}firemotd explorer firemotd-explore-package-manager.sh - ${firemotd_explore_type}"
if [ "${firemotd_explore_type}" = "write" ] ; then
  explore_package_manager
  write_package_manager
elif [ "${firemotd_explore_type}" = "read" ] ; then
  read_package_manager
fi
