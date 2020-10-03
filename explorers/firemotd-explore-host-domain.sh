#!/bin/bash
# Script name:  firemotd-explore-host-domain.sh
# Version:      v0.05.200923
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Host Domain
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_host_domain () {
  host_domain_value="$(hostname -d)"
  validate_host_domain
}

write_host_domain () {
  host_domain_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  host_domain_result=$(jq --arg host_domain_value "${host_domain_value}" --arg host_domain_lastrun "${host_domain_lastrun}" \
    '.firemotd.properties.data.properties.host.properties.domain.properties.value = $host_domain_value | .firemotd.properties.data.properties.host.properties.domain.properties.lastrun = $host_domain_lastrun' \
    data/firemotd-data.json)
  echo "${host_domain_result}" > "$firemotd_data_path"
}

read_host_domain () {
  host_domain_value="$(jq -r ".firemotd.properties.data.properties.host.properties.domain.properties.value" "$firemotd_data_path")"
  validate_host_domain
  host_domain_value="${firemotd_row_highlightcolor}${host_domain_value}${firemotd_row_charcolor}"
}

validate_host_domain () {
  if [[ "$host_domain_value" =~ ^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9](\.|\-))*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$ ]]; then
    write_log debug info "${row_string}valid host_domain_value \"${host_domain_value}\" detected"
  else
    write_log output error "${row_string}invalid host_domain_value \"${host_domain_value}\" detected. Please debug."
    exit 2
  fi
}

row_string=""
if [ ! -z $i ] ; then
  row_string="Row $i: "
fi
write_log verbose info "${row_string}firemotd-explore-host-domain.sh - ${firemotd_explore_type}"
if [ "${firemotd_explore_type}" = "write" ] ; then
  explore_host_domain
  write_host_domain
elif [ "${firemotd_explore_type}" = "read" ] ; then
  read_host_domain
fi
