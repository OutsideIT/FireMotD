#!/bin/bash
# Script name:  firemotd.sh
# Version:      v13.03.200921
# Created on:   10/02/2014
# Author:       Willem D'Haese
# Purpose:      Bash framework to dynamically MotD messages
# On GitHub:    https://github.com/OutsideIT/FireMotD
# On OutsideIT: https://outsideit.net/firemotd
# Copyright:
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version. This program is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
# Public License for more details. You should have received a copy of the
# GNU General Public License along with this program.  If not, see
# <http://www.gnu.org/licenses/>.

log_level="output"
firemotd_action="undefined"
firemotd_explore="host"
firemotd_restore="undefined"
firemotd_print="all"
script_path="$(readlink -f "$0")"
script_directory=$(dirname "${script_path}")
script_name="$(basename "${script_path}")"
script_version="$(< "${script_path}" grep "# Version: " | head -n1 | awk '{print $3}' | tr -cd '[:digit:.-]' | sed 's/.\{0\}$//') "
firemotd_template_directory="${script_directory}/templates"
firemotd_data_template="${firemotd_template_directory}/firemotd-data.template"
firemotd_data_directory="${script_directory}/data"
firemotd_data_path="${firemotd_data_directory}/firemotd-data.json"
firemotd_cache_directory="${script_directory}/cache"
firemotd_cache_path="${firemotd_cache_directory}/firemotd-cache.motd"
firemotd_explorers_directory="${script_directory}/explorers"
firemotd_valid_explorers=("host" "host-name" "host-domain" "host-ip" "host-architecture" "cpu-usage" "package")
LC_ALL="C"
LC_CTYPE="C"
LC_NUMERIC="C"
LANG="C"
if [ -f "$script_directory/helpers/firemotd-helpers.sh" ] ; then
  source "$script_directory/helpers/firemotd-helpers.sh"
else
  now=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  echo "$now: $script_name: error: Missing firemotd-helpers.sh"
  exit 2
fi

initialize_arguments "$@"
firemotd_theme_cache_path="${firemotd_cache_directory}/firemotd-cache-test.json"
write_log debug info "script_directory: $script_directory"
write_log debug info "script_name: $script_name"
write_log debug info "script_version: $script_version"
write_log debug info "log_level: $log_level"
write_log debug info "firemotd_action: $firemotd_action"
write_log debug info "firemotd_explore: $firemotd_explore"

case "$firemotd_action" in
  colormap)
    source_file "$script_directory/helpers/firemotd-colortest.sh"
    show_colortest 0 ;;
  colortest)
    source_file "$script_directory/helpers/firemotd-colortest.sh"
    show_colortest ;;
  help)
    print_help ;;
  install)
    verify_sudo
    install_firemotd ;;
  explore)
    validate_data_path
    explore_data write ;;
  restore_data_template)
    restore_data_template ;;
  create_explorer)
    create_explorer ;;
  theme)
    validate_cache_path
    validate_data_path
    explore_data write
    validate_theme
    load_theme_defaults
    print_theme ;;
  present)
    present_themes ;;
  undefined)
    write_log output error "Please provide a valid argument combination" ; exit 2 ;;
  *)
    write_log output error "Invalid action: \"${firemotd_action}\"" ; exit 2 ;;
esac

exit $?
