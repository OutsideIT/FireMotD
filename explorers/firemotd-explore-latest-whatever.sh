#!/bin/bash
# Script name:  firemotd-explore-latest-whatever.sh
# Version:      v0.05.200923
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Host Information
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_latest_whatever () {
  latest_whatever_value="$(hostname)"
  validate_latest_whatever
}

write_latest_whatever () {
  latest_whatever_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  latest_whatever_result=$(jq --arg latest_whatever_value "${latest_whatever_value}" --arg latest_whatever_lastrun "${latest_whatever_lastrun}" \
    '.firemotd.properties.data.properties.latest.properties.whatever.properties.value = ${latest_whatever_value} | .firemotd.properties.data.properties.latest.properties.whatever.properties.lastrun = ${latest_whatever_lastrun}' \
    "$firemotd_data_path")
  echo "${latest_whatever_result}" > "$firemotd_data_path"
}

read_latest_whatever () {
  latest_whatever_value="$(jq -r ".firemotd.properties.data.properties.latest.properties.whatever.properties.value" "$firemotd_data_path")"
  validate_latest_whatever
  latest_whatever_value="${firemotd_row_highlightcolor}${latest_whatever_value}${firemotd_row_charcolor}"
}

validate_latest_whatever () {
  if [[ "$latest_whatever_value" =~ ^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9](\.|\_|\-))*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$ ]]; then
    write_log debug info "${row_string}valid latest_whatever_value \"${latest_whatever_value}\" detected"
  else
    write_log output error "${row_string}invalid latest_whatever_value \"${latest_whatever_value}\" detected. Please debug."
    exit 2
  fi
}

row_string=""
if [ ! -z $i ] ; then
  row_string="Row $i: "
fi
write_log verbose info "${row_string}firemotd-explore-latest-whatever.sh - ${firemotd_explore_type}"
if [ "${firemotd_explore_type}" = "write" ] ; then
  explore_latest_whatever
  write_latest_whatever
elif [ "${firemotd_explore_type}" = "read" ] ; then
  read_latest_whatever
fi
