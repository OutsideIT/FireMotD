#!/bin/bash
# Script name:  firemotd-explore-host-name.sh
# Version:      v0.05.200923
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Host Information
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_host_name () {
  host_name_value="$(hostname)"
  validate_host_name
}

write_host_name () {
  host_name_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  host_name_result=$(jq --arg host_name_value "${host_name_value}" --arg host_name_lastrun "${host_name_lastrun}" \
    '.firemotd.properties.data.properties.host.properties.name.properties.value = $host_name_value | .firemotd.properties.data.properties.host.properties.name.properties.lastrun = $host_name_lastrun' \
    "$firemotd_data_path")
  echo "${host_name_result}" > "$firemotd_data_path"
}

read_host_name () {
  host_name_value="$(jq -r ".firemotd.properties.data.properties.host.properties.name.properties.value" "$firemotd_data_path")"
  validate_host_name
  host_name_value="${firemotd_row_highlightcolor}${host_name_value}${firemotd_row_charcolor}"
}

validate_host_name () {
  if [[ "$host_name_value" =~ ^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9](\.|\_|\-))*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$ ]]; then
    write_log verbose info "${firemotd_log_row_prefix}firemotd explorer valid host_name_value \"${host_name_value}\" detected"
  else
    write_log output error "${firemotd_log_row_prefix}firemotd explorer invalid host_name_value \"${host_name_value}\" detected. Please debug."
    exit 2
  fi
}

write_log debug info "${firemotd_log_row_prefix}firemotd explorer firemotd-explore-host-name.sh - ${firemotd_explore_type}"
if [ "${firemotd_explore_type}" = "write" ] ; then
  explore_host_name
  write_host_name
elif [ "${firemotd_explore_type}" = "read" ] ; then
  read_host_name
fi
