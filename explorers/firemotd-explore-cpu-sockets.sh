#!/bin/bash
# Script name:  firemotd-explore-cpu-sockets.sh
# Version:      v0.06.201108
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Host Information
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_cpu_sockets () {
  cpu_sockets_value="$(< /proc/cpuinfo grep "physical id" | sort -u | wc -l)"
  validate_cpu_sockets
}

write_cpu_sockets () {
  cpu_sockets_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  cpu_sockets_result=$(jq --arg cpu_sockets_value "${cpu_sockets_value}" --arg cpu_sockets_lastrun "${cpu_sockets_lastrun}" \
    '.firemotd.properties.data.properties.cpu.properties.sockets.properties.value = $cpu_sockets_value | .firemotd.properties.data.properties.cpu.properties.sockets.properties.lastrun = $cpu_sockets_lastrun' \
    "$firemotd_data_path")
  echo "${cpu_sockets_result}" > "$firemotd_data_path"
}

read_cpu_sockets () {
  cpu_sockets_value="$(jq -r ".firemotd.properties.data.properties.cpu.properties.sockets.properties.value" "$firemotd_data_path")"
  validate_cpu_sockets
  cpu_sockets_value="${firemotd_row_highlightcolor}${cpu_sockets_value}${firemotd_row_charcolor}"
}

validate_cpu_sockets () {
if [[ "$cpu_sockets_value" =~ ^[0-9]*\.?[0-9]+$ ]]; then
    write_log verbose info "${firemotd_log_row_prefix}firemotd explorer valid cpu_sockets_value \"${cpu_sockets_value}\" detected"
  else
    write_log output error "${firemotd_log_row_prefix}firemotd explorer invalid cpu_sockets_value \"${cpu_sockets_value}\" detected. Please debug."
    exit 2
  fi
}

write_log debug info "${firemotd_log_row_prefix}firemotd explorer firemotd-explore-cpu-sockets.sh - ${firemotd_explore_type}"
if [ "${firemotd_explore_type}" = "write" ] ; then
  explore_cpu_sockets
  write_cpu_sockets
elif [ "${firemotd_explore_type}" = "read" ] ; then
  read_cpu_sockets
fi
