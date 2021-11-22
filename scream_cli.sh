#!/bin/bash
# A CLI for the SCX Program

# Constants
readonly CHARS_LINE="============================"
readonly CLI_PATH="${HOME}/.scream_cli"
readonly CLI_NAME="Scream CLI"
readonly CLI_COMMAND="scream_cli"
readonly CLI_VERSION=$(<${CLI_PATH}/VERSION)

err() {
  printf "$(basename $0): $1\n" >&2
}

get_sys_info() {
  case "$(uname -s)" in
      Linux*)     SYS_OS="Linux";;
      Darwin*)    SYS_OS="Mac";;
      *)          SYS_OS="UNKNOWN"
  esac

  if [ $SYS_OS = "Linux" ]; then
    SYS_USERNAME=$(getent passwd "$USER" | cut -d ':' -f 5 | sed -E "s/,,,//")
  elif [ $SYS_OS = "Mac" ]; then
    SYS_USERNAME=$(finger $(whoami) | egrep -o 'Name: [a-zA-Z0-9 ]{1,}' | cut -d ':' -f 2 | xargs echo)
  else
    echo "Unknown OS. Please run on mac or linux."
    exit 1
  fi
}

configure_settings() {
  while [[ true ]]; do
    printf "\n\Configure Settings\n\n"
    if [[ -f "$CLI_PATH/settings.json" ]]; then
        printf "It looks like you already have settings configured for this project.\n"
        read -r -p "Would you like to overwrite them? [y/n]:" input
        case ${input} in
          [yY][eE][sS] | [yY])
            printf "Continuing to overwrite: \n"
            ;;
          [nN][oO] | [nN] | "")
            break
            ;;
          *)
            printf "Oops! Something failed. Lets try again.\n"
            gen_settings
            break
            ;;
        esac
    fi
    read -r -p "What is the url for the scream game? " url
    read -r -p "What is the username you use for data access? " username
    read -r -p "What is the password you use for data access? " password
    read -r -p "Are all of the above correct? [y/n]: " input
    case ${input} in
      [yY][eE][sS] | [yY])
        printf "{\"username\":\"$username\",\"password\":\"$password\",\"url\":\"$url\"}" > $CLI_PATH/settings.json
        break
        ;;
      [nN][oO] | [nN] | "")
        gen_settings
        break
        ;;
      *)
        printf "Oops! Something failed.\n"
        ;;
    esac
  done
}

get_data() {
  cwd="$PWD"
  cd $CLI_PATH/python
  source venv/bin/activate
  python3 run.py
  deactivate
  cd ..
  mv output.csv $cwd/scream_output.csv
  printf "Completed!\n\nYou can find your clean Scream output in your current directory at: \n\n$cwd/scream_output.csv\n\n"
}

main() {
  if [[ $# -lt 1 ]]; then
    err "missing command operand"
    exit 1
  fi

  # Select the command
  case $1 in

    get-data | gd) # Get the data
      if [[ $# -gt 1 ]]; then
        err "Too many arguments"
        exit 1
      fi
      get_data
    ;;

    configure-settings | cs) # configure all settings for the cli
      if [[ $# -gt 1 ]]; then
        err "Too many arguments"
        exit 1
      fi
      configure_settings
    ;;

    uninstall) # Uninstall the cli
      if [[ $# -gt 1 ]]; then
        err "Too many arguments"
        exit 1
      fi
      printf "${CHARS_LINE}\n"
      # Prompt confirmation to delete
      printf "WARNING! uninstall: This will remove: \n- ${CLI_NAME} (${CLI_VERSION}) \n"
      read -r -p "Are you sure you want to continue? [y/N] " input
      case ${input} in
        [yY][eE][sS] | [yY])
          printf "Uninstalling ${CLI_NAME} (${CLI_VERSION})\n"
          rm -rf "${CLI_PATH}"
          printf "Uninstall Complete!\n"
          ;;
        [nN][oO] | [nN] | "")
          printf "$1 was canceled by the user\n"
          ;;
        *)
          err "Invalid Input: The $1 was canceled"
          exit 1
          ;;
      esac
      ;;

    update) # Update the CLI
      printf "${CHARS_LINE}\n"
      printf "Updating Installation\n"
      git -C ${CLI_PATH} pull > /dev/null
      printf "Finished!\n"
      ;;

    help | --help) # Display the help items in the cli
      cat 1>&2 <<EOF
${CLI_NAME}
(${CLI_VERSION})

Commands:
  Usage: ${CLI_COMMAND} COMMAND

  configure-settings (cs)   Configure all settings for the project
  get-data (gd)             Pull the relevent data down
  help                      Get help for using the ${CLI_NAME}
  uninstall                 Uninstall the ${CLI_NAME}
  update                    Update to the most recent version of ${CLI_NAME}
  version                   Display the current version


Usage Examples:
  configure-settings
      ${CLI_COMMAND} configure-settings

  get-data
      ${CLI_COMMAND} get-data

  uninstall
      ${CLI_COMMAND} uninstall

  update
      ${CLI_COMMAND} update

  version
      ${CLI_COMMAND} version

EOF
      ;;

    version | --version | -v) # Display the current version of the CLI
      printf "${CLI_NAME} ${CLI_VERSION}\n"
      ;;

    *)
      err "$1: command not found"
      exit 1
      ;;
  esac
}

get_sys_info
main "$@"
