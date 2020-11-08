#!/bin/bash
# Script name:  firemotd-explore-cpu-count.sh
# Version:      v0.06.201108
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Host Information
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_cpu_count () {
  cpu_count_value="$(< /proc/cpuinfo grep -c processor)"
  validate_cpu_count
}

write_cpu_count () {
  cpu_count_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  cpu_count_result=$(jq --arg cpu_count_value "${cpu_count_value}" --arg cpu_count_lastrun "${cpu_count_lastrun}" \
    '.firemotd.properties.data.properties.cpu.properties.count.properties.value = $cpu_count_value | .firemotd.properties.data.properties.cpu.properties.count.properties.lastrun = $cpu_count_lastrun' \
    "$firemotd_data_path")
  echo "${cpu_count_result}" > "$firemotd_data_path"
}

read_cpu_count () {
  cpu_count_value="$(jq -r ".firemotd.properties.data.properties.cpu.properties.count.properties.value" "$firemotd_data_path")"
  validate_cpu_count
  cpu_count_value="${firemotd_row_highlightcolor}${cpu_count_value}${firemotd_row_charcolor}"
}

validate_cpu_count () {
  if [[ "$cpu_count_value" =~ ^[0-9]*\.?[0-9]+$ ]]; then
    write_log verbose info "${firemotd_log_row_prefix}firemotd explorer valid cpu_count_value \"${cpu_count_value}\" detected"
  else
    write_log output error "${firemotd_log_row_prefix}firemotd explorer invalid cpu_count_value \"${cpu_count_value}\" detected. Please debug."
    exit 2
  fi
}

write_log debug info "${firemotd_log_row_prefix}firemotd explorer firemotd-explore-cpu-count.sh - ${firemotd_explore_type}"
if [ "${firemotd_explore_type}" = "write" ] ; then
  explore_cpu_count
  write_cpu_count
elif [ "${firemotd_explore_type}" = "read" ] ; then
  read_cpu_count
fi
