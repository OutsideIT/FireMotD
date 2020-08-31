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
    [[ -f $f ]] && . $f --source-only || echo "$f not found"
  done
}

verify_sudo () {
  if [ "$EUID" -ne 0 ]; then
    write_log output error "FireMotD action $firemotd_action requires root privileges!."
    exit 2
  fi
}

verify_nosudo () {
  if [ "$EUID" -eq 0 ]; then
    write_log output error "FireMotD $firemotd_action should not be run as root."
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
    firemotd_explore_realtime="true"
    source_group $explorer
    firemotd_explore_realtime="false"
  done
}

validate_data () {
  write_log verbose info "Exploring explorers \"$firemotd_explore\""
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

load_theme_defaults () {
  write_log verbose info "Loading theme $firemotd_theme defaults"
  firemotd_theme_path="${script_directory}/themes/firemotd-theme-${firemotd_theme}.json"
  firemotd_theme_default_length=$(jq -r '.firemotd.properties.theme.defaults.length' "$firemotd_theme_path")
  write_log debug info "FireMotD default length: $firemotd_theme_default_length"
  firemotd_theme_default_character=$(jq -r '.firemotd.properties.theme.defaults.character' "$firemotd_theme_path")
  write_log debug info "FireMotD default character: $firemotd_theme_default_character"
  firemotd_theme_default_charcolor=$(jq -r '.firemotd.properties.theme.defaults.charcolor' "$firemotd_theme_path")
  write_log debug info "FireMotD default charcolor: $firemotd_theme_default_charcolor"
  firemotd_theme_default_charstart=$(jq -r '.firemotd.properties.theme.defaults.charstart' "$firemotd_theme_path")
  write_log debug info "FireMotD default charstart: $firemotd_theme_default_charstart"
  firemotd_theme_default_charinit=$(jq -r '.firemotd.properties.theme.defaults.charinit' "$firemotd_theme_path")
  write_log debug info "FireMotD default charinit: $firemotd_theme_default_charinit"
  firemotd_theme_default_charfill=$(jq -r '.firemotd.properties.theme.defaults.charfill' "$firemotd_theme_path")
  write_log debug info "FireMotD default charfill: $firemotd_theme_default_charfill"
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

load_row_properties () {
  firemotd_row_type=$(jq -r ".firemotd.properties.data[$1 | tonumber].row.properties.type" "$firemotd_theme_path")
  write_log debug info "Row $1 firemotd_row_type $firemotd_row_type"
  firemotd_row_length=$(jq -r ".firemotd.properties.data[$1 | tonumber].row.properties.length" "$firemotd_theme_path")
  firemotd_row_length=$(compare_row_with_defaults firemotd_row_length firemotd_theme_default_length)
  write_log debug info "Row $1 firemotd_row_length $firemotd_row_length"
  firemotd_row_varcount=$(jq -r ".firemotd.properties.data[$1 | tonumber].row.properties.variables | length" "$firemotd_theme_path")
  write_log debug info "Row $1 firemotd_row_varcount $firemotd_row_varcount"
  firemotd_row_character=$(jq -r ".firemotd.properties.data[$1 | tonumber].row.properties.character" "$firemotd_theme_path")
  firemotd_row_character=$(compare_row_with_defaults firemotd_row_character firemotd_theme_default_character)
  write_log debug info "Row $1 firemotd_row_character $firemotd_row_character"
  firemotd_row_charcolor=$(jq -r ".firemotd.properties.data[$1 | tonumber].row.properties.charcolor" "$firemotd_theme_path")
  firemotd_row_charcolor=$(compare_row_with_defaults firemotd_row_charcolor firemotd_theme_default_charcolor)
  write_log debug info "Row $1 firemotd_row_charcolor $firemotd_row_charcolor"
  firemotd_row_charstart=$(jq -r ".firemotd.properties.data[$1 | tonumber].row.properties.charstart" "$firemotd_theme_path")
  firemotd_row_charstart=$(compare_row_with_defaults firemotd_row_charstart firemotd_theme_default_charstart)
  write_log debug info "Row $1 firemotd_row_charstart $firemotd_row_charstart"
  firemotd_row_charinit=$(jq -r ".firemotd.properties.data[$1 | tonumber].row.properties.charinit" "$firemotd_theme_path")
  firemotd_row_charinit=$(compare_row_with_defaults firemotd_row_charinit firemotd_theme_default_charinit)
  write_log debug info "Row $1 firemotd_row_charinit $firemotd_row_charinit"
  firemotd_row_charfill=$(jq -r ".firemotd.properties.data[$1 | tonumber].row.properties.charfill" "$firemotd_theme_path")
  firemotd_row_charfill=$(compare_row_with_defaults firemotd_row_charfill firemotd_theme_default_charfill)
  write_log debug info "Row $1 firemotd_row_charfill $firemotd_row_charfill"
  firemotd_row_data=$(jq -r ".firemotd.properties.data[$1 | tonumber].row.properties.data" "$firemotd_theme_path")
  firemotd_row_key=$(jq -r ".firemotd.properties.data[$1 | tonumber].row.properties.key" "$firemotd_theme_path")
  write_log debug info "Row $1 firemotd_row_key $firemotd_row_key"
  firemotd_row_keycolor=$(jq -r ".firemotd.properties.data[$1 | tonumber].row.properties.keycolor" "$firemotd_theme_path")
  firemotd_row_keycolor=$(compare_row_with_defaults firemotd_row_keycolor firemotd_theme_default_keycolor)
  write_log debug info "Row $1 firemotd_row_keycolor $firemotd_row_keycolor"
  firemotd_row_keystart=$(jq -r ".firemotd.properties.data[$1 | tonumber].row.properties.keystart" "$firemotd_theme_path")
  firemotd_row_keystart=$(compare_row_with_defaults firemotd_row_keystart firemotd_theme_default_keystart)
  write_log debug info "Row $1 firemotd_row_keystart $firemotd_row_keystart"
  firemotd_row_separator=$(jq -r ".firemotd.properties.data[$1 | tonumber].row.properties.separator" "$firemotd_theme_path")
  firemotd_row_separator=$(compare_row_with_defaults firemotd_row_separator firemotd_theme_default_separator)
  write_log debug info "Row $1 firemotd_row_separator $firemotd_row_separator"
  firemotd_row_separatorcolor=$(jq -r ".firemotd.properties.data[$1 | tonumber].row.properties.separatorcolor" "$firemotd_theme_path")
  firemotd_row_separatorcolor=$(compare_row_with_defaults firemotd_row_separatorcolor firemotd_theme_default_separatorcolor)
  write_log debug info "Row $1 firemotd_row_separatorcolor $firemotd_row_separatorcolor"
  firemotd_row_highlightcolor=$(jq -r ".firemotd.properties.data[$1 | tonumber].row.properties.highlightcolor" "$firemotd_theme_path")
  firemotd_row_highlightcolor=$(compare_row_with_defaults firemotd_row_highlightcolor firemotd_theme_default_highlightcolor)
  write_log debug info "Row $1 firemotd_row_highlightcolor $firemotd_row_highlightcolor"
}

reset_row_properties () {
  firemotd_row_length="${firemotd_theme_default_length}"
  firemotd_row_character="${firemotd_theme_default_character}"
  firemotd_row_charcolor="${firemotd_theme_default_charcolor}"
  firemotd_row_charstart="${firemotd_theme_default_charstart}"
  firemotd_row_charinit="${firemotd_theme_default_charinit}"
  firemotd_row_charfill="${firemotd_theme_default_charfill}"
  firemotd_row_data=""
  firemotd_row_keycolor="${firemotd_theme_default_keycolor}"
  firemotd_row_keystart="${firemotd_theme_default_keystart}"
  firemotd_row_separator="${firemotd_theme_default_separator}"
  firemotd_row_separatorcolor="${firemotd_theme_default_separatorcolor}"
  firemotd_row_separator_length=0
  firemotd_row_highlightcolor="${firemotd_theme_default_highlightcolor}"
  firemotd_row_leftover_string=""
}

compare_row_with_defaults () {
  if [[ "${!1}" == "null" ]] ; then
    if [[ "${!2}" != "null" ]] ; then
      echo "${!2}"
    else
      write_log output error "FireMotD theme $Firemotd_theme row $i is missing $1 ${!1} property."
      exit 2
    fi
  else
    echo "${!1}"
  fi
}

print_theme () {
  write_log verbose info "Printing theme $firemotd_theme"
  write_log verbose info "Looping through firemotd data rows in $firemotd_theme_path"
  firemotd_row_count=$(jq -r '.firemotd.properties.data | length' "$firemotd_theme_path")
  write_log debug Info "Looping through $firemotd_row_count rows"
  for (( i = 0 ; i < $firemotd_row_count ; i++ )) ; do
    write_log debug info "Row $i processing started"
    load_row_properties $i
    if [ "$firemotd_row_data" = "null" ] ; then
      print_dynamic_row
    else
      print_dynamic_data
    fi
    reset_row_properties
  done
}

print_colored_characters () {
  str=$1
  num=$2
  col=$3
  for (( i = 1; i <= num; i++ )) ; do
    echo -en "$col$str\e[0m"
  done
}

print_raw_characters () {
  str=$1
  num=$2
  for (( i = 1; i <= num; i++ )) ; do
    echo -en "$str"
  done
}

load_row_data () {
  write_log debug info "Row $i loading data ${firemotd_row_data}"
  row_data_variable="${firemotd_row_data//\$}"
  row_data_variable="${row_data_variable//\{}"
  row_data_variable="${row_data_variable//\}}"
  write_log debug info "Row $i data variable ${row_data_variable}"
  row_data_jsonstring="${row_data_variable//\_/.properties.}"
  write_log debug info "Row $i data jsonstring $row_data_jsonstring"
  row_data_value=$(jq --arg jsonstring "${row_data_jsonstring}" -r ".firemotd.properties.data.properties.${row_data_jsonstring}" ${firemotd_data_path})
  write_log debug info "Row $i data value: $row_data_value"
}

load_row_variables () {
  firemotd_row_type=$(jq -r ".firemotd.properties.data[$1 | tonumber].row.properties.type" "$firemotd_theme_path")
  write_log debug info "Row $1 firemotd_row_type $firemotd_row_type"
}

print_dynamic_row () {
  write_log debug info "Row $i printing $firemotd_row_charcolor $firemotd_row_character $firemotd_row_length"
  firemotd_row_raw_string=$(print_raw_characters "$firemotd_row_character" "$firemotd_row_length")
  write_log debug info "Row $i firemotd_row_raw_string ${firemotd_row_raw_string}"
  firemotd_row_empty_char_string=$(print_raw_characters " " "$firemotd_row_charstart")
  write_log debug info "Row $i firemotd_row_empty_char_string \"$firemotd_row_empty_char_string\""
  firemotd_row_leftover_string_length=$(( firemotd_row_length - ${#firemotd_row_empty_char_string} ))
#  firemotd_row_exact_string=$(echo ${firemotd_row_raw_string:$firemotd_row_charstart:$firemotd_row_length})
  firemotd_row_exact_string=$(echo ${firemotd_row_raw_string:$firemotd_row_charstart:$firemotd_row_leftover_string_length})
  if [[ "$firemotd_row_character" =~ (\\|\\\\) ]] ; then
    write_log debug info "Row $i backslash detected"
    firemotd_row_exact_string="${firemotd_row_exact_string}${firemotd_row_exact_string}"
  fi
  full_row_string="${firemotd_row_empty_char_string}${firemotd_row_exact_string}"
  colored_row_string="${firemotd_row_charcolor}${full_row_string}"
  write_log verbose info "Row $i length: ${#firemotd_row_exact_string}, full row length: ${#full_row_string}, colored row length: ${#colored_row_string}"
  echo -en "$colored_row_string"
  echo -en "\n\033[0m"
}

print_dynamic_data () {
  write_log debug info "Row $i printing $firemotd_row_charcolor $firemotd_row_character ${firemotd_row_charinit}"
  row_char_string=$(print_raw_characters "$firemotd_row_character" "${firemotd_row_charinit}")
  firemotd_row_empty_char_string=$(print_raw_characters " " "$firemotd_row_charstart")
  write_log debug info "Row $i loading variables from $firemotd_theme_path"
  firemotd_row_vars_count=$(jq -r ".firemotd.properties.data[$i].row.properties.variables | length" "$firemotd_theme_path")
  write_log debug Info "Row $i looping through $firemotd_row_vars_count variables"
  for (( j = 0 ; j < $firemotd_row_vars_count ; j++ )) ; do
    firemotd_row_var="$(jq -r ".firemotd.properties.data[$i].row.properties.variables[$j].key" "$firemotd_theme_path")"
    write_log debug info "Row $i variable $firemotd_row_var processing started"
    source_group $firemotd_row_var
  done
  firemotd_row_data_string="$(eval echo "$firemotd_row_data") "
  write_log verbose info "Row $i firemotd_row_data_string: $firemotd_row_data_string"
  if [ "${firemotd_row_charfill}" = "true" ] ; then
    firemotd_row_charcolor_length=$(( ${firemotd_row_varcount} * ${#firemotd_row_charcolor} ))
    write_log debug info "Row $i firemotd_row_charcolor_length $firemotd_row_charcolor_length"
    firemotd_row_highlightcolor_length=$(( ${firemotd_row_varcount} * ${#firemotd_row_highlightcolor} ))
    write_log debug info "Row $i firemotd_row_highlightcolor_length $firemotd_row_highlightcolor_length"
    firemotd_row_data_string_length="${#firemotd_row_data_string}"
    write_log debug info "Row $i firemotd_row_data_string_length $firemotd_row_data_string_length"
    firemotd_row_data_string_length=$((${#firemotd_row_data_string} - firemotd_row_charcolor_length - firemotd_row_highlightcolor_length ))
    write_log debug info "Row $i firemotd_row_data_string_length $firemotd_row_data_string_length"
    if [ "$firemotd_row_key" = "null" ] ; then
      firemotd_row_key_length=0
      firemotd_row_separator_length=0
    else
      firemotd_row_key_length=${#firemotd_row_key}
      firemotd_row_separator_length=$(( ${#firemotd_row_separator} + 2 ))
    fi
    firemotd_row_known_string_lentgh=$(( firemotd_row_data_string_length + ${#row_char_string} + ${#firemotd_row_empty_char_string} + ${firemotd_row_key_length} + ${firemotd_row_separator_length} ))
    write_log verbose info "Row $i firemotd_row_known_string_lentgh $firemotd_row_known_string_lentgh ($firemotd_row_data_string_length + ${#row_char_string} + ${#firemotd_row_empty_char_string} + ${firemotd_row_key_length} (${firemotd_row_key}) + ${firemotd_row_separator_length} (${firemotd_row_separator})"
    firemotd_row_leftover_string_length=$(( firemotd_row_length - firemotd_row_known_string_lentgh - 1 ))
    write_log debug info "Row $i firemotd_row_leftover_string_length $firemotd_row_leftover_string_length"
    firemotd_row_leftover_string=$(print_raw_characters "$firemotd_row_character" "${firemotd_row_leftover_string_length}")
    firemotd_row_leftover_string=$(echo ${firemotd_row_leftover_string:0:$firemotd_row_leftover_string_length})
    write_log debug info "Row $i firemotd_row_leftover_string $firemotd_row_leftover_string"
  fi
  [[ "$firemotd_row_key" != "null" ]] && firemotd_row_key=" ${firemotd_row_keycolor}${firemotd_row_key} " || firemotd_row_key=""
  [[ "$firemotd_row_separator" != "null" ]] && firemotd_row_separator="${firemotd_row_separatorcolor}${firemotd_row_separator} " || firemotd_row_separator=""
  colored_row_string="${firemotd_row_empty_char_string}${firemotd_row_charcolor}${row_char_string}${firemotd_row_key}${firemotd_row_separator}${firemotd_row_charcolor}${firemotd_row_data_string}${firemotd_row_leftover_string}"
  echo -en "$colored_row_string"
  echo -en "\n\033[0m"
}

restore_item () {
  write_log verbose info "Restoring $firemotd_restore"
  cp "$script_directory/templates/firemotd-template.json" "$script_directory/data/firemotd-data.json"
}
