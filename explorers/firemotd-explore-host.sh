#!/bin/bash
# Script name:  firemotd-explore-host.sh
# Version:      v0.01.200609
# Created on:   09/06/2020
# Author:       Willem D'Haese
# Purpose:      Explore Host Information
# On GitHub:    https://github.com/OutsideIT/FireMotD

explore_host_name () {
  host_name_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  host_name_value="$(hostname)"
  host_name_result=$(jq --arg host_name_value "$host_name_value" --arg host_name_lastrun "$host_name_lastrun" \
    '.host.properties.name.properties.value = $host_name_value | .host.properties.name.properties.lastrun = $host_name_lastrun' \
    data/firemotd-data.json)
  echo "${host_name_result}" > data/firemotd-data.json
}

explore_host_ip () {
  host_ip_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
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
  host_ip_result=$(jq --arg host_ip_value "$host_ip_value" --arg host_ip_lastrun "$host_ip_lastrun" \
    '.host.properties.ip.properties.value = $host_ip_value | .host.properties.ip.properties.lastrun = $host_ip_lastrun' \
    data/firemotd-data.json)
  echo "${host_ip_result}" > data/firemotd-data.json
}

explore_host_architecture () {
  host_architecture_lastrun=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  host_architecture_value="$(arch)"
  host_architecture_result=$(jq --arg host_architecture_value "$host_architecture_value" --arg host_architecture_lastrun "$host_architecture_lastrun" \
    '.host.properties.architecture.properties.value = $host_architecture_value | .host.properties.architecture.properties.lastrun = $host_architecture_lastrun' \
    data/firemotd-data.json)
  echo "${host_architecture_result}" > data/firemotd-data.json
}

write_log verbose info "Exploring host name"
explore_host_name
write_log verbose info "Exploring host ip"
explore_host_ip
write_log verbose info "Exploring host architecture"
explore_host_architecture
