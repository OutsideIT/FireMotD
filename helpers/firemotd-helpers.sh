#!/bin/bash

write_log () {
  if [ -n "$script_name" ] ; then
    script_name="$(basename "$(readlink -f "$0")")"
  fi
  if [ -z "$1" ] ; then
    echo "write_log: Log parameter #1 is zero length. Please debug..."
    exit 2
  else
    if [ -z "$2" ] ; then
      echo "write_log: Severity parameter #2 is zero length. Please debug..."
      exit 2
    else
      if [ -z "$3" ] ; then
        echo "write_log: Message parameter #3 is zero length. Please debug..."
        exit 2
      fi
    fi
  fi
  now=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  if [[ "$1" =~ (debug|verbose) ]] && [ "$log_level" = "debug" ] ; then
    echo "$now: $script_name: $2: $3 "
  elif [ "$1" = "verbose" ] && [ "$log_level" = "verbose" ] ; then
    echo "$now: $script_name: $2: $3"
  elif [ "$1" = "output" ] ; then
    echo "${now}: $script_name: $2: $3"
  elif [ -f "$1" ] ; then
    echo "${now}: $script_name: $2: $3" >> "$1"
  fi
  if [ -n "$log_file" ] ; then
    if [ "$1" = "debug" ] && [ "$log_level" = "debug" ] ; then
      echo "$Now: $script_name: $2: $3 " >> "$log_file"
    elif [ "$1" = "verbose" ] && [ "$log_level" = "verbose" ] ; then
      echo "$Now: $script_name: $2: $3" >> "$log_file"
    elif [ "$1" = "output" ] ; then
      echo "${now}: $script_name: $2: $3" >> "$log_file"
    fi
  fi
}

initialize_arguments () {
  while :; do
    case "$1" in
      -v|-V|--verbose|--Verbose)
        log_level="verbose" ; shift ;;
      -d|-D|--debug|--Debug)
        log_level="debug" ; shift ;;
      -h|-H|--help|--Help)
        firemotd_action="help" ; shift ;;
      -p|-P|--presentation|--Presentation)
        firemotd_action="present" ; shift ;;
#      -G|--GenerateCache)
#        shift ; Action="caches" ; Theme="$1" ; shift ;;
      -i|-I|--install|--Install)
        firemotd_action="install" ; shift ;;
      -e|-E|--explore|--Explore)
        shift ; firemotd_action="explore" ; firemotd_explore="$1" ; shift ;;
#      -HV|--hideversion|--HideVersion)
#        HideVersion=1 ; shift ;;
#      -sru|-SRU|--skiprepoupdate|--SkipRepoUpdate)
#        SkipRepoUpdate=1 ; shift ;;
      -t|-T|--theme|--Theme)
        shift ; firemotd_action="theme" ; firemotd_theme="$1" ; shift ;;
#      -D|--Data|--Template)
#        shift ; TemplateType="$1" ; shift ;;
      -c|-C|--colortest|--Colortest|--ColorTest|--colorTest)
        firemotd_action="colortest" ; shift ;;
      -m|-M|--colormap|--Colormap|--ColorMap|--colorMap)
        firemotd_action="colormap" ; shift ;;
#      -E|--ExportFile)
#        shift ; ExportFile="$1" ; shift ;;
#      -TF|--TemplateFile)
#        shift ; Action="template" ; Template="$1" ; shift ;;
       -r|-R|--restore|--Restore)
         shift ; firemotd_action="restore" ; firemotd_restore="$1" ; shift ;;
#      -MT|--MultiThreaded)
#        MultiThreaded=1 ; shift ;;
      -*) write_log output error "initialize_arguments: You specified a non-existant option: $1" ; exit 2 ;;
      *) break ;;
    esac
  done
}

print_help () {
  echo "
$script_name $script_version
usage:
  $script_name -e host
  $script_name -t <firemotd_theme>

options:
   -h | --help                          shows this help
   -v | --verbose                       log level verbose
   -d | --debug                         log level debug
   -t | --theme <firemotd_theme>        shows the chosen theme
   -c | --colortest                     shows color test
   -M | --colormap                      shows color map
   -e | --explore                       explores the chose explorer

legacy themes:
 - original
 - modern
 - invader
 - clean

theme templates:
 - blanco
 - blue
 - digipolis
 - elastic
 - eline
 - gray
 - orange
 - red
"
  exit 0
}

source_file () {
  if [ -f "$1" ] ; then
    source "$1"
  else
    write_log output error "Missing $1"
    exit 2
  fi
}

source_group () {
  group="*-explore-$1*.sh"
  findstring="$(find explorers/. -maxdepth 1 -name $group -print)"
  array=( $findstring )
  for f in "${array[@]}"; do
    write_log debug info "Sourcing $f"
    [[ -f $f ]] && . $f --source-only || echo "$f not found"
  done
}

verify_sudo () {
  if [ "$EUID" -ne 0 ]; then
    write_log output error "FireMotD action $firemotd_action requires root privileges"
    exit 2
  fi
}

verify_json () {
  jq_result=$( { cat "$1" | jq empty ; } 2>&1 )
  exitcode=$?
  if [ $exitcode -ne 0 ] ; then
    write_log output error "Invalid json file ${1}: ${jq_result}"
    exit $exitcode
  fi
}

explore_data () {
  write_log verbose info "Exploring explorers \"$firemotd_explore\""
  verify_json "$script_directory/data/firemotd-data.json"
  write_log verbose info "Found valid data json $script_directory/data/firemotd-data.json"
  for explorer in ${firemotd_explore//,/ } ; do
    write_log debug info "Exploring $explorer"
    source_group $explorer
  done
}

print_theme () {
  write_log verbose info "Printing theme $firemotd_theme"
  verify_json "${script_directory}/themes/firemotd-theme-${firemotd_theme}.json"
  firemotd_theme_name=$(jq -r '.firemotd.properties.theme.properties.name' "${script_directory}/themes/firemotd-theme-${firemotd_theme}.json")
  firemotd_theme_version=$(jq -r '.firemotd.properties.theme.properties.version' "${script_directory}/themes/firemotd-theme-${firemotd_theme}.json")
  write_log verbose info "Found valid theme $firemotd_theme_name $firemotd_theme_version"
}

restore_item () {
  write_log verbose info "Restoring $firemotd_restore"
  cp "$script_directory/templates/firemotd-template.json" "$script_directory/data/firemotd-data.json"
}

load_theme_defaults () {
  write_log verbose info "Loading theme $firemotd_theme defaults"
  firemotd_theme_path="${script_directory}/themes/firemotd-theme-${firemotd_theme}.json"
  firemotd_theme_default_character=$(jq -r '.firemotd.properties.theme.defaults.character' "$firemotd_theme_path")
  write_log verbose info "FireMotD default character: $firemotd_theme_default_character"
}
