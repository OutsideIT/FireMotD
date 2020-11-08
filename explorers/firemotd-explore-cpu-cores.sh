#!/bin/bash
# Script name:  firemotd-explore-cpu-cores.sh
# Version:      v0.06.201108
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Host Information
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_cpu_cores () {
  cpu_cores_value="$(< /proc/cpuinfo grep "processor" | sort -u | wc -l)"
  validate_cpu_cores
}

write_cpu_cores () {
  cpu_cores_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  cpu_cores_result=$(jq --arg cpu_cores_value "${cpu_cores_value}" --arg cpu_cores_lastrun "${cpu_cores_lastrun}" \
    '.firemotd.properties.data.properties.cpu.properties.cores.properties.value = $cpu_cores_value | .firemotd.properties.data.properties.cpu.properties.cores.properties.lastrun = $cpu_cores_lastrun' \
    "$firemotd_data_path")
  echo "${cpu_cores_result}" > "$firemotd_data_path"
}

read_cpu_cores () {
  cpu_cores_value="$(jq -r ".firemotd.properties.data.properties.cpu.properties.cores.properties.value" "$firemotd_data_path")"
  validate_cpu_cores
  cpu_cores_value="${firemotd_row_highlightcolor}${cpu_cores_value}${firemotd_row_charcolor}"
}

validate_cpu_cores () {
  if [[ "$cpu_cores_value" =~ ^[0-9]*\.?[0-9]+$ ]]; then
    write_log verbose info "${firemotd_log_row_prefix}firemotd explorer valid cpu_cores_value \"${cpu_cores_value}\" detected"
  else
    write_log output error "${firemotd_log_row_prefix}firemotd explorer invalid cpu_cores_value \"${cpu_cores_value}\" detected. Please debug."
    exit 2
  fi
}

write_log debug info "${firemotd_log_row_prefix}firemotd explorer firemotd-explore-cpu-cores.sh - ${firemotd_explore_type}"
if [ "${firemotd_explore_type}" = "write" ] ; then
  explore_cpu_cores
  write_cpu_cores
elif [ "${firemotd_explore_type}" = "read" ] ; then
  read_cpu_cores
fi
