#!/bin/bash
# Script name:  firemotd-explore-cpu-usage.sh
# Version:      v0.05.200923
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Host Information
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_cpu_usage () {
  cpu_usage_value="$(time LANG=en_GB.UTF-8 mpstat -P all | awk '$2 ~ /CPU/ { for(i=1;i<=NF;i++) { if ($i ~ /%idle/) field=i } } $2 ~ /all/ { print 100 - $field}' | tail -1)"
}

write_cpu_usage () {
  cpu_usage_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  cpu_usage_result=$(jq --arg host_name_value "${host_name_value}" --arg host_name_lastrun "${host_name_lastrun}" \
    '.firemotd.properties.data.properties.host.properties.name.properties.value = $host_name_value | .firemotd.properties.data.properties.host.properties.name.properties.lastrun = $host_name_lastrun' \
    data/firemotd-data.json)
  echo "${cpu_usage_result}" > "${firemotd_data_path}"
}

read_cpu_usage () {
  cpu_usage_value="${firemotd_row_highlightcolor}$(jq -r ".firemotd.properties.data.properties.host.properties.name.properties.value" "$firemotd_data_path")${firemotd_row_charcolor}"
}

validate_cpu_usage () {
  if [[ "${cpu_usage_value}" =~ ^\d{1,3}$ ]]; then
    write_log debug error "Row $i: Valid cpu_usage_value ${host_name_value} detected"
  else
    write_log output error "Row $i: Invalid cpu_usage_value detected. Please debug."
    exit 2
  fi
}

write_log verbose info "Row $i: firemotd-explore-cpu_usage.sh - ${firemotd_explore_type}"
if [ "${firemotd_explore_type}" = "write" ] ; then
  explore_cpu_usage
  write_cpu_usage
  validate_cpu_usage
elif [ "${firemotd_explore_type}" = "read" ] ; then
  read_cpu_usage
  validate_cpu_usage
fi
