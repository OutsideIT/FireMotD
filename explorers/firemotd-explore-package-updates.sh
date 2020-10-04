#!/bin/bash
# Script name:  firemotd-explore-package-updates.sh
# Version:      v0.05.200923
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Host Information
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_package_updates () {
  package_updates_value="$(hostname)"
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
  if [[ "$package_updates_value" =~ ^(\d{1,3}|null)$ ]]; then
    write_log debug info "${firemotd_log_row_prefix}valid package_updates_value \"${package_updates_value}\" detected"
  else
    write_log output error "${firemotd_log_row_prefix}invalid package_updates_value \"${package_updates_value}\" detected. Please debug."
    exit 2
  fi
}

write_log verbose info "${firemotd_log_row_prefix}firemotd-explore-package-updates.sh - ${firemotd_explore_type}"
if [ "${firemotd_explore_type}" = "write" ] ; then
  explore_package_updates
  write_package_updates
elif [ "${firemotd_explore_type}" = "read" ] ; then
  read_package_updates
fi
