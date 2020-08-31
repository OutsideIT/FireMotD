#!/bin/bash
# Script name:  firemotd-explore-host-name.sh
# Version:      v0.03.200623
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Host Information
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_host_name () {
  host_name_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  host_name_value="$(hostname)"
  host_name_result=$(jq --arg host_name_value "${host_name_value}" --arg host_name_lastrun "${host_name_lastrun}" \
    '.firemotd.properties.data.properties.host.properties.name.properties.value = $host_name_value | .firemotd.properties.data.properties.host.properties.name.properties.lastrun = $host_name_lastrun' \
    data/firemotd-data.json)
  echo "${host_name_result}" > "$firemotd_data_path"
}

read_host_name () {
  host_name_value="${firemotd_row_highlightcolor}$(jq -r ".firemotd.properties.data.properties.host.properties.name.properties.value" "$firemotd_data_path")${firemotd_row_charcolor}"
}

if [ "$firemotd_explore_realtime" = "true" ] ; then
  explore_host_name
  write_log debug info "Explored host-name: ${host_name_value}"
else
  read_host_name
  write_log debug info "Row $i read host_name_value $host_name_value"
fi
