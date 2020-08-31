#!/bin/bash
# Script name:  firemotd-explore-host-domain.sh
# Version:      v0.04.200829
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Host Information
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_host_domain () {
  host_domain_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  host_domain_value="$(hostname -d)"
  host_domain_result=$(jq --arg host_domain_value "${host_domain_value}" --arg host_domain_lastrun "${host_domain_lastrun}" \
    '.firemotd.properties.data.properties.host.properties.domain.properties.value = $host_domain_value | .firemotd.properties.data.properties.host.properties.domain.properties.lastrun = $host_domain_lastrun' \
    data/firemotd-data.json)
  echo "${host_domain_result}" > "$firemotd_data_path"
}

read_host_domain () {
  host_domain_value="${firemotd_row_highlightcolor}$(jq -r ".firemotd.properties.data.properties.host.properties.domain.properties.value" "$firemotd_data_path")${firemotd_row_charcolor}"
}

if [ "$firemotd_explore_realtime" = "true" ] ; then
  explore_host_domain
  write_log debug info "Explored host-domain: ${host_domain_value}"
else
  read_host_domain
  write_log debug info "Row $i read host_domain_value $host_domain_value"
fi
