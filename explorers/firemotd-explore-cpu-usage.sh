#!/bin/bash
# Script name:  firemotd-explore-cpu-usage.sh
# Version:      v0.05.200923
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Host Information
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_cpu_usage () {
  cpu_usage_value="$(LANG=en_GB.UTF-8 mpstat -P all | awk '$2 ~ /CPU/ { for(i=1;i<=NF;i++) { if ($i ~ /%idle/) field=i } } $2 ~ /all/ { print 100 - $field}' | tail -1)"
  validate_cpu_usage
}

write_cpu_usage () {
  cpu_usage_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  cpu_usage_result=$(jq --arg cpu_usage_value "${cpu_usage_value}" --arg cpu_usage_lastrun "${cpu_usage_lastrun}" \
    '.firemotd.properties.data.properties.cpu.properties.usage.properties.value = $cpu_usage_value | .firemotd.properties.data.properties.cpu.properties.usage.properties.lastrun = $cpu_usage_lastrun' \
    "$firemotd_data_path")
  echo "${cpu_usage_result}" > "$firemotd_data_path"
}

read_cpu_usage () {
  cpu_usage_value="$(jq -r ".firemotd.properties.data.properties.cpu.properties.usage.properties.value" "$firemotd_data_path")"
  validate_cpu_usage
  cpu_usage_value="${firemotd_row_highlightcolor}${cpu_usage_value}${firemotd_row_charcolor}"
}

validate_cpu_usage () {
  if [[ "$cpu_usage_value" =~ ^[0-9]*\.?[0-9]+$ ]]; then
    write_log verbose info "${firemotd_log_row_prefix}firemotd explorer valid cpu_usage_value \"${cpu_usage_value}\" detected"
  else
    write_log output error "${firemotd_log_row_prefix}firemotd explorer invalid cpu_usage_value \"${cpu_usage_value}\" detected. Please debug."
    exit 2
  fi
}

write_log debug info "${firemotd_log_row_prefix}firemotd explorer firemotd-explore-cpu-usage.sh - ${firemotd_explore_type}"
if [ "${firemotd_explore_type}" = "write" ] ; then
  explore_cpu_usage
  write_cpu_usage
elif [ "${firemotd_explore_type}" = "read" ] ; then
  read_cpu_usage
fi
