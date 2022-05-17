#!/bin/sh
# Copyright  observIQ, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

# Collector Constants
FORMULA_NAME="observiq/observiq-otel-collector/observiq-otel-collector"
SERVICE_NAME="com.observiq.collector"

# Script Constants
PREREQS="printf brew sed uname"
SCRIPT_NAME="$0"
INDENT_WIDTH='  '
indent=""


# Colors
num_colors=$(tput colors 2>/dev/null)
if test -n "$num_colors" && test "$num_colors" -ge 8; then
  bold="$(tput bold)"
  underline="$(tput smul)"
  # standout can be bold or reversed colors dependent on terminal
  standout="$(tput smso)"
  reset="$(tput sgr0)"
  bg_black="$(tput setab 0)"
  bg_blue="$(tput setab 4)"
  bg_cyan="$(tput setab 6)"
  bg_green="$(tput setab 2)"
  bg_magenta="$(tput setab 5)"
  bg_red="$(tput setab 1)"
  bg_white="$(tput setab 7)"
  bg_yellow="$(tput setab 3)"
  fg_black="$(tput setaf 0)"
  fg_blue="$(tput setaf 4)"
  fg_cyan="$(tput setaf 6)"
  fg_green="$(tput setaf 2)"
  fg_magenta="$(tput setaf 5)"
  fg_red="$(tput setaf 1)"
  fg_white="$(tput setaf 7)"
  fg_yellow="$(tput setaf 3)"
fi

if [ -z "$reset" ]; then
  sed_ignore=''
else
  sed_ignore="/^[$reset]+$/!"
fi

# Helper Functions
printf() {
  if command -v sed >/dev/null; then
    command printf -- "$@" | sed -E "$sed_ignore s/^/$indent/g"  # Ignore sole reset characters if defined
  else
    # Ignore $* suggestion as this breaks the output
    # shellcheck disable=SC2145
    command printf -- "$indent$@"
  fi
}

increase_indent() { indent="$INDENT_WIDTH$indent" ; }
decrease_indent() { indent="${indent#*$INDENT_WIDTH}" ; }

# Color functions reset only when given an argument
bold() { command printf "$bold$*$(if [ -n "$1" ]; then command printf "$reset"; fi)" ; }
underline() { command printf "$underline$*$(if [ -n "$1" ]; then command printf "$reset"; fi)" ; }
standout() { command printf "$standout$*$(if [ -n "$1" ]; then command printf "$reset"; fi)" ; }
# Ignore "parameters are never passed"
# shellcheck disable=SC2120
reset() { command printf "$reset$*$(if [ -n "$1" ]; then command printf "$reset"; fi)" ; }
bg_black() { command printf "$bg_black$*$(if [ -n "$1" ]; then command printf "$reset"; fi)" ; }
bg_blue() { command printf "$bg_blue$*$(if [ -n "$1" ]; then command printf "$reset"; fi)" ; }
bg_cyan() { command printf "$bg_cyan$*$(if [ -n "$1" ]; then command printf "$reset"; fi)" ; }
bg_green() { command printf "$bg_green$*$(if [ -n "$1" ]; then command printf "$reset"; fi)" ; }
bg_magenta() { command printf "$bg_magenta$*$(if [ -n "$1" ]; then command printf "$reset"; fi)" ; }
bg_red() { command printf "$bg_red$*$(if [ -n "$1" ]; then command printf "$reset"; fi)" ; }
bg_white() { command printf "$bg_white$*$(if [ -n "$1" ]; then command printf "$reset"; fi)" ; }
bg_yellow() { command printf "$bg_yellow$*$(if [ -n "$1" ]; then command printf "$reset"; fi)" ; }
fg_black() { command printf "$fg_black$*$(if [ -n "$1" ]; then command printf "$reset"; fi)" ; }
fg_blue() { command printf "$fg_blue$*$(if [ -n "$1" ]; then command printf "$reset"; fi)" ; }
fg_cyan() { command printf "$fg_cyan$*$(if [ -n "$1" ]; then command printf "$reset"; fi)" ; }
fg_green() { command printf "$fg_green$*$(if [ -n "$1" ]; then command printf "$reset"; fi)" ; }
fg_magenta() { command printf "$fg_magenta$*$(if [ -n "$1" ]; then command printf "$reset"; fi)" ; }
fg_red() { command printf "$fg_red$*$(if [ -n "$1" ]; then command printf "$reset"; fi)" ; }
fg_white() { command printf "$fg_white$*$(if [ -n "$1" ]; then command printf "$reset"; fi)" ; }
fg_yellow() { command printf "$fg_yellow$*$(if [ -n "$1" ]; then command printf "$reset"; fi)" ; }

# Intentionally using variables in format string
# shellcheck disable=SC2059
info() { printf "$*\\n" ; }
# Intentionally using variables in format string
# shellcheck disable=SC2059
warn() {
  increase_indent
  printf "$fg_yellow$*$reset\\n"
  decrease_indent
}
# Intentionally using variables in format string
# shellcheck disable=SC2059
error() {
  increase_indent
  printf "$fg_red$*$reset\\n"
  decrease_indent
}
# Intentionally using variables in format string
# shellcheck disable=SC2059
success() { printf "$fg_green$*$reset\\n" ; }
# Ignore 'arguments are never passed'
# shellcheck disable=SC2120
prompt() {
  if [ "$1" = 'n' ]; then
    command printf "y/$(fg_red '[n]'): "
  else
    command printf "$(fg_green '[y]')/n: "
  fi
}

observiq_banner()
{
  fg_cyan "           888                                        8888888 .d88888b.\\n"
  fg_cyan "           888                                          888  d88P\" \"Y88b\\n"
  fg_cyan "           888                                          888  888     888\\n"
  fg_cyan "   .d88b.  88888b.  .d8888b   .d88b.  888d888 888  888  888  888     888\\n"
  fg_cyan "  d88\"\"88b 888 \"88b 88K      d8P  Y8b 888P\"   888  888  888  888     888\\n"
  fg_cyan "  888  888 888  888 \"Y8888b. 88888888 888     Y88  88P  888  888 Y8b 888\\n"
  fg_cyan "  Y88..88P 888 d88P      X88 Y8b.     888      Y8bd8P   888  Y88b.Y8b88P\\n"
  fg_cyan "   \"Y88P\"  88888P\"   88888P'  \"Y8888  888       Y88P  8888888 \"Y888888\"\\n"
  fg_cyan "                                                                   Y8b  \\n"

  reset
}

separator() { printf "===================================================\\n" ; }

banner()
{
  printf "\\n"
  separator
  printf "| %s\\n" "$*" ;
  separator
}

usage()
{
  increase_indent
  USAGE=$(cat <<EOF
Usage:
  $(fg_yellow '-r, --uninstall')
      Stops the collector services and uninstalls the collector via brew.

  $(fg_yellow '-u, --upgrade')
      Stops the collector services and upgrades the collector via brew.

EOF
  )
  info "$USAGE"
  decrease_indent
  return 0
}

force_exit()
{
  # Exit regardless of subshell level with no "Terminated" message
  kill -PIPE $$
  # Call exit to handle special circumstances (like running script during docker container build)
  exit 1
}

error_exit()
{
  line_num=$(if [ -n "$1" ]; then command printf ":$1"; fi)
  error "ERROR ($SCRIPT_NAME$line_num): ${2:-Unknown Error}" >&2
  if [ -n "$0" ]; then
    increase_indent
    error "$*"
    decrease_indent
  fi
  force_exit
}

print_prereq_line()
{
  if [ -n "$2" ]; then
    command printf "\\n${indent}  - "
    command printf "[$1]: $2"
  fi
}

check_failure()
{
  if [ "$indent" != '' ]; then increase_indent; fi
  command printf "${indent}${fg_red}ERROR: %s check failed!${reset}" "$1"

  print_prereq_line "Issue" "$2"
  print_prereq_line "Resolution" "$3"
  print_prereq_line "Help Link" "$4"
  print_prereq_line "Rerun" "$5"

  command printf "\\n"
  if [ "$indent" != '' ]; then decrease_indent; fi
  force_exit
}

succeeded()
{
  increase_indent
  success "Succeeded!"
  decrease_indent
}

failed()
{
  error "Failed!"
}

# This will check all prerequisites before running an installation.
check_prereqs()
{
  banner "Checking Prerequisites"
  increase_indent
  os_check
  dependencies_check
  success "Prerequisite check complete!"
  decrease_indent
}

# Checks to see if there is an existing install of the collector
check_existing_install()
{
  banner "Checking for existing install"
  increase_indent
  brew list observiq/observiq-otel-collector/observiq-otel-collector > /dev/null 2>&1 && error_exit "Installation already exists. If you wish to upgrade please rerun the script with the -u flag."
  success "No current install"
  decrease_indent
}

# This will check if the operating system is supported.
os_check()
{
  info "Checking that the operating system is supported..."
  os_type=$(uname -s)
  case "$os_type" in
    Darwin)
      succeeded
      ;;
    *)
      failed
      error_exit "$LINENO" "The operating system $(fg_yellow "$os_type") is not supported by this script."
      ;;
  esac
}

# This will check if the current environment has
# all required shell dependencies to run the installation.
dependencies_check()
{
  info "Checking for script dependencies..."
  FAILED_PREREQS=''
  for prerequisite in $PREREQS; do
    if command -v "$prerequisite" >/dev/null; then
      continue
    else
      if [ -z "$FAILED_PREREQS" ]; then
        FAILED_PREREQS="${fg_red}$prerequisite${reset}"
      else
        FAILED_PREREQS="$FAILED_PREREQS, ${fg_red}$prerequisite${reset}"
      fi
    fi
  done

  if [ -n "$FAILED_PREREQS" ]; then
    failed
    error_exit "$LINENO" "The following dependencies are required by this script: [$FAILED_PREREQS]"
  fi
  succeeded
}

# This will install the package by running brew to install then copying files to appropriate locations.
install_package()
{
  banner "Installing observIQ OpenTelemetry Collector"
  increase_indent

  info "Tapping formula..."
  brew tap observiq/homebrew-observiq-otel-collector > /dev/null 2>&1 || error_exit "$LINENO" "Failed to tap formula"
  succeeded

  info "Installing collector..."
  brew update > /dev/null 2>&1 || error_exit "$LINENO" "Failed to run brew update"
  brew install $FORMULA_NAME > /dev/null 2>&1 || error_exit "$LINENO" "Failed to install formula"

  increase_indent
  info ""
  info "In order to install the jmx metrics jar to the correct location, root permissions are needed."
  info "Please enter your password if prompted to complete installation."
  info ""
  decrease_indent
  sudo cp "$(brew --prefix $FORMULA_NAME)/lib/opentelemetry-java-contrib-jmx-metrics.jar" /opt 2>&1 || error_exit "$LINENO" "Failed to move jmx jar to /opt"
  succeeded

  info "Enabling service..."
  brew services start $FORMULA_NAME > /dev/null 2>&1 || error_exit "$LINENO" "Failed to enable service"
  succeeded

  success "observIQ OpenTelemetry Collector installation complete!"
  decrease_indent
}


# This will display the results of an installation
display_results()
{
    collector_home="$(brew --prefix $FORMULA_NAME)"
    banner 'Information'
    increase_indent
    info "Collector Home:     $(fg_cyan "$collector_home")$(reset)"
    info "Collector Config:   $(fg_cyan "$collector_home/config.yaml")$(reset)"
    info "Start Command:      $(fg_cyan "launchctl start $SERVICE_NAME")$(reset)"
    info "Stop Command:       $(fg_cyan "launchctl stop $SERVICE_NAME")$(reset)"
    info "Logs Command:       $(fg_cyan "tail -f /tmp/observiq-otel-collector.log")$(reset)"
    decrease_indent

    banner 'Support'
    increase_indent
    info "For more information on configuring the collector, see the docs:"
    increase_indent
    info "$(fg_cyan "https://github.com/observiq/observiq-otel-collector/tree/main#observiq-opentelemetry-collector")$(reset)"
    decrease_indent
    info "If you have any other questions please contact us at $(fg_cyan support@observiq.com)$(reset)"
    increase_indent
    decrease_indent
    decrease_indent

    banner "$(fg_green Installation Complete!)"
    return 0
}

uninstall()
{
  observiq_banner

  banner "Uninstalling observIQ OpenTelemetry Collector"
  increase_indent

  info "Stopping service..."
  launchctl stop $SERVICE_NAME > /dev/null 2>&1 || error_exit "$LINENO" "Failed to stop service"
  succeeded

  info "Removing service..."
  launchctl remove $SERVICE_NAME > /dev/null 2>&1 || error_exit "$LINENO" "Failed to remove service"
  succeeded

  info "Uninstalling collector..."
  brew uninstall $FORMULA_NAME > /dev/null 2>&1 || error_exit "$LINENO" "Failed to uninstall formula"
  
  increase_indent
  info ""
  info "In order to remove the jmx metrics jar, root permissions are needed."
  info "Please enter your password if prompted to complete installation."
  info ""
  decrease_indent

  sudo rm -f /opt/opentelemetry-java-contrib-jmx-metrics.jar > /dev/null 2>&1 || error_exit "$LINENO" "Failed to remove jmx jar from /opt"
  succeeded

  info "Untapping formula..."
  brew untap observiq/homebrew-observiq-otel-collector > /dev/null 2>&1 || error_exit "$LINENO" "Failed to untap formula"
  succeeded
  decrease_indent

  banner "$(fg_green Uninstallation Complete!)"
}

upgrade()
{
  observiq_banner

  banner "Upgrading observIQ OpenTelemetry Collector"
  increase_indent

  info "Checking if install exists ..."
  brew list observiq/observiq-otel-collector/observiq-otel-collector > /dev/null 2>&1 || error_exit "No installation currently exists"
  succeeded

  info "Stopping service..."
  launchctl stop $SERVICE_NAME > /dev/null 2>&1 || error_exit "$LINENO" "Failed to stop service"
  succeeded

  info "Upgrading collector..."
  brew update > /dev/null 2>&1 || error_exit "$LINENO" "Failed to run brew update"
  brew upgrade $FORMULA_NAME > /dev/null 2>&1 || error_exit "$LINENO" "Failed to upgrade formula"

  increase_indent
  info ""
  info "In order to install the jmx metrics jar to the correct location, root permissions are needed."
  info "Please enter your password if prompted to complete installation."
  info ""
  decrease_indent
  
  sudo cp "$(brew --prefix $FORMULA_NAME)/lib/opentelemetry-java-contrib-jmx-metrics.jar" /opt 2>&1 || error_exit "$LINENO" "Failed to move jmx jar to /opt"
  succeeded

  info "Starting service..."
  launchctl start $SERVICE_NAME > /dev/null 2>&1 || error_exit "$LINENO" "Failed to start service"
  succeeded
  decrease_indent

  banner "$(fg_green Upgrade Complete!)"
}

main()
{
  if [ $# -ge 1 ]; then
    while [ -n "$1" ]; do
      case "$1" in
        -r|--uninstall)
          uninstall
          force_exit
          ;;
        -u|--upgrade)
          upgrade
          force_exit
          ;;
        -h|--help)
          usage
          force_exit
          ;;
      --)
        shift; break ;;
      *)
        error "Invalid argument: $1"
        usage
        force_exit
        ;;
      esac
    done
  fi

  observiq_banner
  check_prereqs
  check_existing_install
  install_package
  display_results
}

main "$@"