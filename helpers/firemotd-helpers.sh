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

verify_firemotd_action () {
  if [ $firemotd_action = "undefined" ] ; then
    firemotd_action="$1"
  elif [[ $firemotd_action =~ (theme) ]] && [[ $1 =~ (explore) ]] ; then
    firemotd_action="theme"
  elif [[ $firemotd_action =~ (explore) ]] && [[ $1 =~ (theme) ]] ; then
    firemotd_action="theme"
  else
    write_log output error "You specified multiple arguments linked to an action. Action $firemotd_action and $1 are incompatible."
    exit 2
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
        verify_firemotd_action "help" ; shift ;;
      -p|-P|--presentation|--Presentation)
        verify_firemotd_action "present" ; shift ;;
      -i|-I|--install|--Install)
        verify_firemotd_action "install" ; shift ;;
      -e|-E|--explore|--Explore)
        shift ; firemotd_explore="$1" ; verify_firemotd_action "explore" ; shift ;;
      -t|-T|--theme|--Theme)
        shift ; verify_firemotd_action "theme" ; firemotd_theme="$1" ; shift ;;
      -c|-C|--colortest|--Colortest|--ColorTest|--colorTest)
        verify_firemotd_action "colortest" ; shift ;;
      -m|-M|--colormap|--Colormap|--ColorMap|--colorMap)
        verify_firemotd_action "colormap" ; shift ;;
      -r|-R|--restore|--Restore)
        shift ; verify_firemotd_action "restore" ; firemotd_restore="$1" ; shift ;;
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
  if [ -f "$1" ] ; then
    jq_result=$( { cat "$1" | jq empty ; } 2>&1 )
      exitcode=$?
      if [ $exitcode -ne 0 ] ; then
        write_log output error "Invalid json file ${1}: ${jq_result}"
        exit $exitcode
      fi
  else
    write_log output error "Unexisting json file ${1}"
    exit 2
  fi
}

explore_data () {
  write_log verbose info "Exploring explorers \"$firemotd_explore\""
  for explorer in ${firemotd_explore//,/ } ; do
    write_log debug info "Exploring $explorer"
    source_group $explorer
  done
}

validate_data () {
  write_log verbose info "Exploring explorers \"$firemotd_explore\""
  firemotd_data_path="${script_directory}/data/firemotd-data.json"
  verify_json "${firemotd_data_path}"
  write_log verbose info "Found valid data json ${firemotd_data_path}"
}

validate_theme () {
  write_log verbose info "Validating theme $firemotd_theme"
  firemotd_theme_path="${script_directory}/themes/firemotd-theme-${firemotd_theme}.json"
  verify_json "${firemotd_theme_path}"
  write_log verbose info "Found valid theme json ${firemotd_theme_path}"
  firemotd_theme_name=$(jq -r '.firemotd.properties.theme.properties.name' "${firemotd_theme_path}")
  firemotd_theme_version=$(jq -r '.firemotd.properties.theme.properties.version' "${firemotd_theme_path}")
  firemotd_theme_creator=$(jq -r '.firemotd.properties.theme.properties.creator' "${firemotd_theme_path}")
  write_log verbose info "Found valid theme ${firemotd_theme_name} ${firemotd_theme_version} by ${firemotd_theme_creator}"
}

load_row_properties () {
  firemotd_row_type=$(jq -r ".firemotd.properties.data[$1 | tonumber].row.properties.type" "$firemotd_theme_path")
  write_log debug info "FireMotD Row $1 Type $firemotd_row_type"
  firemotd_row_character=$(jq -r ".firemotd.properties.data[$1 | tonumber].row.properties.character" "$firemotd_theme_path")
  write_log debug info "FireMotD Row $1 Character $firemotd_row_character"
  firemotd_row_charcolor=$(jq -r ".firemotd.properties.data[$1 | tonumber].row.properties.charcolor" "$firemotd_theme_path")
  write_log debug info "FireMotD Row $1 Character Color $firemotd_row_charcolor"
  firemotd_row_length=$(jq -r ".firemotd.properties.data[$1 | tonumber].row.properties.length" "$firemotd_theme_path")
  write_log debug info "FireMotD Row $1 Length $firemotd_row_length"
  firemotd_row_charstart=$(jq -r ".firemotd.properties.data[$1 | tonumber].row.properties.data" "$firemotd_theme_path")
  write_log debug info "FireMotD Row $1 Data $firemotd_row_charcolor"
}

print_theme () {
  write_log verbose info "Printing theme $firemotd_theme"
  write_log verbose info "Looping through firemotd data rows in $firemotd_theme_path"
  firemotd_row_count=$(jq -r '.firemotd.properties.data | length' "$firemotd_theme_path")
  write_log debug Info "Looping through $firemotd_row_count rows"
  for (( i = 0 ; i < $firemotd_row_count ; i++ )) ; do
    write_log debug info "FireMotD Row $i"
    load_row_properties $i
    print_dynamic_row
  done
}

print_dynamic_row () {
  echo -en "Test: $firemotd_row_charcolor $firemotd_row_character"
  echo -en "\n\033[0m"
}

restore_item () {
  write_log verbose info "Restoring $firemotd_restore"
  cp "$script_directory/templates/firemotd-template.json" "$script_directory/data/firemotd-data.json"
}

load_theme_defaults () {
  write_log verbose info "Loading theme $firemotd_theme defaults"
  firemotd_theme_path="${script_directory}/themes/firemotd-theme-${firemotd_theme}.json"
  firemotd_theme_default_character=$(jq -r '.firemotd.properties.theme.defaults.character' "$firemotd_theme_path")
  write_log debug info "FireMotD default character: $firemotd_theme_default_character"
  firemotd_theme_default_charcolor=$(jq -r '.firemotd.properties.theme.defaults.charcolor' "$firemotd_theme_path")
  write_log debug info "FireMotD default charcolor: $firemotd_theme_default_charcolor"
  firemotd_theme_default_charstart=$(jq -r '.firemotd.properties.theme.defaults.charstart' "$firemotd_theme_path")
  write_log debug info "FireMotD default charstart: $firemotd_theme_default_charstart"
  firemotd_theme_default_length=$(jq -r '.firemotd.properties.theme.defaults.length' "$firemotd_theme_path")
  write_log debug info "FireMotD default length: $firemotd_theme_default_length"
  firemotd_theme_default_keycolor=$(jq -r '.firemotd.properties.theme.defaults.keycolor' "$firemotd_theme_path")
  write_log debug info "FireMotD default keycolor: $firemotd_theme_default_keycolor"
  firemotd_theme_default_keystart=$(jq -r '.firemotd.properties.theme.defaults.keystart' "$firemotd_theme_path")
  write_log debug info "FireMotD default keystart: $firemotd_theme_default_keystart"
  firemotd_theme_default_separator=$(jq -r '.firemotd.properties.theme.defaults.separator' "$firemotd_theme_path")
  write_log debug info "FireMotD default separator: $firemotd_theme_default_separator"
  firemotd_theme_default_separatorcolor=$(jq -r '.firemotd.properties.theme.defaults.separatorcolor' "$firemotd_theme_path")
  write_log debug info "FireMotD default separatorcolor: $firemotd_theme_default_separatorcolor"
  firemotd_theme_default_valuecolor=$(jq -r '.firemotd.properties.theme.defaults.valuecolor' "$firemotd_theme_path")
  write_log debug info "FireMotD default valuecolor: $firemotd_theme_default_valuecolor"
  firemotd_theme_default_highlightcolor=$(jq -r '.firemotd.properties.theme.defaults.highlightcolor' "$firemotd_theme_path")
  write_log debug info "FireMotD default heighlightcolor: $firemotd_theme_default_highlightcolor"
  firemotd_theme_default_unexisting=$(jq -r '.firemotd.properties.theme.defaults.unexisting' "$firemotd_theme_path")
  write_log debug info "FireMotD default unexisting: $firemotd_theme_default_unexisting"
# Optimize with https://unix.stackexchange.com/questions/413878/json-array-to-bash-variables-using-jq
}
