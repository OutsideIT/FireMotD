#!/bin/bash
# Script name:  firemotd-explore-host-ip.sh
# Version:      v0.05.200923
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Host Information
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_host_ip () {
  ip_path="$(command -v ip 2>/dev/null)"
  if [ -z "$ip_path" ] ; then
    if [ -f /usr/sbin/ip ] ; then
      ip_path="/usr/sbin/ip"
    elif [ -f /sbin/ip ] ; then
      ip_path="/sbin/ip"
    else
      WriteLog Verbose Warning "No ip tool found"
    fi
  fi
  if [[ -n $ip_path ]] ; then
    host_ip_value="$(${ip_path} route get 8.8.8.8 | head -1 | grep -Po '(?<=src )(\d{1,3}.){4}' | xargs)"
    if [[ ! $host_ip_value =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      host_ip_value="Unable to parse ip \"$host_ip_value\". Please debug."
    fi
  else
    host_ip_value="Unable to use ip route. Please debug."
  fi
  validate_host_ip
}

write_host_ip () {
  host_ip_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  host_ip_result=$(jq --arg host_ip_value "${host_ip_value}" --arg host_ip_lastrun "${host_ip_lastrun}" \
    '.firemotd.properties.data.properties.host.properties.ip.properties.value = $host_ip_value | .firemotd.properties.data.properties.host.properties.ip.properties.lastrun = $host_ip_lastrun' \
    "$firemotd_data_path")
  echo "${host_ip_result}" > "$firemotd_data_path"
}

read_host_ip () {
  host_ip_value="$(jq -r ".firemotd.properties.data.properties.host.properties.ip.properties.value" "$firemotd_data_path")"
  validate_host_ip
  host_ip_value="${firemotd_row_highlightcolor}${host_ip_value}${firemotd_row_charcolor}"
}

validate_host_ip () {
  if [[ "$host_ip_value" =~ ^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9](\.|\_|\-))*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$ ]]; then
    write_log debug info "${firemotd_log_row_prefix}firemotd explorer valid host_ip_value \"${host_ip_value}\" detected"
  else
    write_log output error "${firemotd_log_row_prefix}firemotd explorer invalid host_ip_value \"${host_ip_value}\" detected. Please debug."
    exit 2
  fi
}

write_log debug info "${firemotd_log_row_prefix}firemotd explorer firemotd-explore-host-ip.sh - ${firemotd_explore_type}"
if [ "${firemotd_explore_type}" = "write" ] ; then
  explore_host_ip
  write_host_ip
elif [ "${firemotd_explore_type}" = "read" ] ; then
  read_host_ip
fi
