#!/bin/bash
# Script name:  firemotd-explore-host-architecture.sh
# Version:      v0.03.200623
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Host Information
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_host_architecture () {
  host_architecture_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  host_architecture_value="$(arch)"
  host_architecture_result=$(jq --arg host_architecture_value "$host_architecture_value" --arg host_architecture_lastrun "$host_architecture_lastrun" \
    '.firemotd.properties.data.properties.host.properties.architecture.properties.value = $host_architecture_value | .firemotd.properties.data.properties.host.properties.architecture.properties.lastrun = $host_architecture_lastrun' \
    data/firemotd-data.json)
  echo "${host_architecture_result}" > data/firemotd-data.json
}

explore_host_architecture
write_log debug info "Explored host-architecture: ${host_architecture_value}"
