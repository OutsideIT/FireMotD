#!/bin/bash
# Script name:  firemotd-explore-cpu-threads.sh
# Version:      v0.06.201108
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Host Information
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_cpu_threads () {
  cpu_threads_value="$(lscpu | grep "Thread(s) per core" | head -1 | awk -F " " '{print $4}')"
  validate_cpu_threads
}

write_cpu_threads () {
  cpu_threads_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  cpu_threads_result=$(jq --arg cpu_threads_value "${cpu_threads_value}" --arg cpu_threads_lastrun "${cpu_threads_lastrun}" \
    '.firemotd.properties.data.properties.cpu.properties.threads.properties.value = $cpu_threads_value | .firemotd.properties.data.properties.cpu.properties.threads.properties.lastrun = $cpu_threads_lastrun' \
    "$firemotd_data_path")
  echo "${cpu_threads_result}" > "$firemotd_data_path"
}

read_cpu_threads () {
  cpu_threads_value="$(jq -r ".firemotd.properties.data.properties.cpu.properties.threads.properties.value" "$firemotd_data_path")"
  validate_cpu_threads
  cpu_threads_value="${firemotd_row_highlightcolor}${cpu_threads_value}${firemotd_row_charcolor}"
}

validate_cpu_threads () {
  if [[ "$cpu_threads_value" =~ ^[0-9]*\.?[0-9]+$ ]]; then
    write_log verbose info "${firemotd_log_row_prefix}firemotd explorer valid cpu_threads_value \"${cpu_threads_value}\" detected"
  else
    write_log output error "${firemotd_log_row_prefix}firemotd explorer invalid cpu_threads_value \"${cpu_threads_value}\" detected. Please debug."
    exit 2
  fi
}

write_log debug info "${firemotd_log_row_prefix}firemotd explorer firemotd-explore-cpu-threads.sh - ${firemotd_explore_type}"
if [ "${firemotd_explore_type}" = "write" ] ; then
  explore_cpu_threads
  write_cpu_threads
elif [ "${firemotd_explore_type}" = "read" ] ; then
  read_cpu_threads
fi
