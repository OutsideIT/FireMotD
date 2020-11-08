#!/bin/bash
# Script name:  firemotd-explore-cpu-load1.sh
# Version:      v0.06.201108
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Host Information
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_cpu_load1 () {
  cpu_load1_value="$(uptime | sed 's/.*load average: //' | awk -F\, '{print $1}' | awk '{$1=$1};1')"
  validate_cpu_load1
}

write_cpu_load1 () {
  cpu_load1_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  cpu_load1_result=$(jq --arg cpu_load1_value "${cpu_load1_value}" --arg cpu_load1_lastrun "${cpu_load1_lastrun}" \
    '.firemotd.properties.data.properties.cpu.properties.load1.properties.value = $cpu_load1_value | .firemotd.properties.data.properties.cpu.properties.load1.properties.lastrun = $cpu_load1_lastrun' \
    "$firemotd_data_path")
  echo "${cpu_load1_result}" > "$firemotd_data_path"
}

read_cpu_load1 () {
  cpu_load1_value="$(jq -r ".firemotd.properties.data.properties.cpu.properties.load1.properties.value" "$firemotd_data_path")"
  validate_cpu_load1
  cpu_load1_value="${firemotd_row_highlightcolor}${cpu_load1_value}${firemotd_row_charcolor}"
}

validate_cpu_load1 () {
  if [[ "$cpu_load1_value" =~ ^[0-9]*\.?[0-9]+$ ]]; then
    write_log verbose info "${firemotd_log_row_prefix}firemotd explorer valid cpu_load1_value \"${cpu_load1_value}\" detected"
  else
    write_log output error "${firemotd_log_row_prefix}firemotd explorer invalid cpu_load1_value \"${cpu_load1_value}\" detected. Please debug."
    exit 2
  fi
}

write_log debug info "${firemotd_log_row_prefix}firemotd explorer firemotd-explore-cpu-load1.sh - ${firemotd_explore_type}"
if [ "${firemotd_explore_type}" = "write" ] ; then
  explore_cpu_load1
  write_cpu_load1
elif [ "${firemotd_explore_type}" = "read" ] ; then
  read_cpu_load1
fi
