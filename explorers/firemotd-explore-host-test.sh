#!/bin/bash
# Script name:  firemotd-explore.template
# Version:      v0.05.200923
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Template
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_host_test () {
  host_test_value=""
  validate_host_test
}

write_host_test () {
  firemotd_explorer_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  firemotd_explorer_value="$(echo ${host_test_value})"
  host_test_result=$(jq --arg firemotd_explorer_value "${firemotd_explorer_value}" --arg firemotd_explorer_lastrun "${firemotd_explorer_lastrun}" \
    'firemotd.properties.data.properties.host.properties.test.properties.value = ${firemotd_explorer_value} | .firemotd.properties.data.properties.${firemotd_object}.properties.${firemotd_subject}.properties.lastrun = ${firemotd_explorer_lastrun}' \
    "$firemotd_data_path")
  echo "${host_test_result}" > "{$firemotd_data_path}"
}

read_host_test () {
  host_test_value="$(jq -r ".firemotd.properties.data.properties.${firemotd_object}.properties.${firemotd_subject}.properties.value" "$firemotd_data_path")"
  validate_host_test
  host_test_value="${firemotd_row_highlightcolor}${${firemotd_object}_${firemotd_subject}_value}${firemotd_row_charcolor}"
}

validate_host_test () {
  if [[ "${host_test_value}" =~ ^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9](\.|\-))*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$ ]]; then
    write_log debug info "${row_string}valid host_test_value \"${${firemotd_object}_${firemotd_subject}_value}\" detected"
  else
    write_log output error "${row_string}invalid host_test_value \"${${firemotd_object}_${firemotd_subject}_value}\" detected. Please debug."
    exit 2
  fi
}

row_string=""
if [ ! -z $i ] ; then
  row_string="Row $i: "
fi
write_log verbose info "${row_string}firemotd-explore-host-test.sh - ${firemotd_explore_type}"
if [ "${firemotd_explore_type}" = "write" ] ; then
  explore_host_test
  write_host_test
elif [ "${firemotd_explore_type}" = "read" ] ; then
  read_host_test
fi
