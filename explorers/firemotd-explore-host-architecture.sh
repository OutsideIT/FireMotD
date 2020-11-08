#!/bin/bash
# Script name:  firemotd-explore-host-architecture.sh
# Version:      v0.05.200923
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Host Information
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_host_architecture () {
  host_architecture_value="$(arch)"
  validate_host_architecture
}

write_host_architecture () {
  host_architecture_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  host_architecture_result=$(jq --arg host_architecture_value "${host_architecture_value}" --arg host_architecture_lastrun "${host_architecture_lastrun}" \
    '.firemotd.properties.data.properties.host.properties.architecture.properties.value = $host_architecture_value | .firemotd.properties.data.properties.host.properties.architecture.properties.lastrun = $host_architecture_lastrun' \
    "$firemotd_data_path")
  echo "${host_architecture_result}" > "$firemotd_data_path"
}

read_host_architecture () {
  host_architecture_value="$(jq -r ".firemotd.properties.data.properties.host.properties.architecture.properties.value" "$firemotd_data_path")"
  validate_host_architecture
  host_architecture_value="${firemotd_row_highlightcolor}${host_architecture_value}${firemotd_row_charcolor}"
}

validate_host_architecture () {
  if [[ "$host_architecture_value" =~ ^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9](\.|\_|\-))*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$ ]]; then
    write_log verbose info "${firemotd_log_row_prefix}firemotd explorer valid host_architecture_value \"${host_architecture_value}\" detected"
  else
    write_log output error "${firemotd_log_row_prefix}firemotd explorer invalid host_architecture_value \"${host_architecture_value}\" detected. Please debug."
    exit 2
  fi
}

write_log debug info "${firemotd_log_row_prefix}firemotd explorer firemotd-explore-host-architecture.sh - ${firemotd_explore_type}"
if [ "${firemotd_explore_type}" = "write" ] ; then
  explore_host_architecture
  write_host_architecture
elif [ "${firemotd_explore_type}" = "read" ] ; then
  read_host_architecture
fi
