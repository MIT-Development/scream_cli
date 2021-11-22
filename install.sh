#!/bin/bash
#
# Install the SCX CLI on Unix Systems

# Constants
readonly CHARS_LINE="============================"
readonly CLI_PATH="${HOME}/.scream_cli"
readonly CLI_NAME="Scream CLI"
readonly CLI_COMMAND="scream_cli"
readonly CLI_VERSION="0.0.1"
readonly BIN_DIR="/usr/local/bin"
readonly SSH_CLONE_URL="https://github.com/MIT-Development/scream_cli"

err() { # Display an error message
  printf "$0: $1\n" >&2
}

check_os() { # Validate that the current OS
  case "$(uname -s)" in
      Linux*)     SYS_OS="Linux";;
      Darwin*)    SYS_OS="Mac";;
      *)          SYS_OS="UNKNOWN"
  esac
  if [ "$SYS_OS" = "UNKNOWN" ]; then
    printf "Error: Unknown operating system.\n"
    printf "Please run this command on one of the following:\n"
    printf "- MacOS\n- Linux\n"
    exit 1
  fi
}

check_git() { # Validate git is installed
  if [ "$(git --version)" = "" ]; then
    err "'git' is not installed. Please install git. \nFor more information see: 'https://git-scm.com'"
    exit 1
  fi
}

check_python3() { # Validate git is installed
  if [ "$(python3 --version)" = "" ]; then
    err "'python3' is not installed. Please install python3. \nFor more information see: 'https://www.python.org/downloads/'"
    exit 1
  fi
  if [ "$(pip3 --version)" = "" ]; then
    err "'pip3' is not installed. Please install pip3 for your current python3 installation."
    exit 1
  fi
  if [ "$(virtualenv --version)" = "" ]; then
    printf "${CHARS_LINE}\n"
    printf "Python virtualenv missing. Adding virtualenv..."
    pip3 install virtualenv
    printf "done\n"
  fi
}

check_previous_installation() {
  # Check to make sure previous installations are removed before continuing
  if [ -d "${CLI_PATH}" ]; then
    LOCAL_CLI_VERSION=$(<${CLI_PATH}/VERSION)
    printf "${CHARS_LINE}\n"
    printf "An existing installation of ${CLI_SHORT_NAME} ($LOCAL_CLI_VERSION) was found \nLocation: ${CLI_PATH}\n"
    printf "You are installing ${CLI_SHORT_NAME} ($CLI_VERSION)\n"
    if [ "$LOCAL_CLI_VERSION" = "$CLI_VERSION" ] ; then
      read -r -p "Would you like to reinstall ${CLI_SHORT_NAME} ($CLI_VERSION)? [y/N] " input
      case ${input} in
        [yY][eE][sS] | [yY])
          printf "Backing up existing keys and settings... "
          rm -rf "${CLI_PATH}_bkp" 2> /dev/null
          mkdir "${CLI_PATH}_bkp/" 2> /dev/null
          sudo mv "${CLI_PATH}/settings.json"  "${CLI_PATH}_bkp/settings.json" 2> /dev/null
          printf "done\n"
          ;;
        *)
          ;;
      esac
    else
      read -r -p "Would you like to update to ${CLI_SHORT_NAME} ($CLI_VERSION)? [y/N] " input
    fi
    case ${input} in
      [yY][eE][sS] | [yY])
        printf "Removing old installation... "
        rm -rf "${CLI_PATH}"
        printf "done\n"
        ;;
      [nN][oO] | [nN] | "")
        err "Installation canceled"
        exit 1
        ;;
      *)
        err "Invalid input: Installation canceled."
        exit 1
        ;;
    esac
  fi
}

install_new() { # Copy the needed files locally
  printf "${CHARS_LINE}\n"
  printf "Creating application folder at '${CLI_PATH}'..."
  mkdir -p "${CLI_PATH}"
  printf "done\n"
  CLONE_URL=$SSH_CLONE_URL
  printf "Cloning from '${CLONE_URL}':\n"
  git clone ${CLONE_URL} \
    ${CLONE_OPTS} \
    "${CLI_PATH}"
  if [ ! -d "${CLI_PATH}" ]; then
    err "Git Clone Failed. Installation Canceled"
    exit 1
  fi
  printf "done\n"
  printf "${CLI_VERSION}" > "${CLI_PATH}/VERSION"
}

check_for_bkps() { # Check to see if any backups exist on the system and prompt user to use them if they exist
  if [[ -d "${CLI_PATH}_bkp/" ]] ; then
    printf "${CHARS_LINE}\n"
    printf "Backup Settings were found from the previous installation of ${CLI_NAME}:\n"
    read -r -p "Would you like to restore these backups into your new installation? [y/N] " input
    case ${input} in
      [yY][eE][sS] | [yY])
        printf "Restoring existing settings... "
        mv "${CLI_PATH}_bkp/settings.json"  "${CLI_PATH}/settings.json" 2> /dev/null
        rm -rf "${CLI_PATH}_bkp" 2> /dev/null
        printf "done\n"
        ;;
      [nN][oO] | [nN] | "")
        printf "Backups not used! /n"
        ;;
      *)
        printf "Invalid input: Backups not used! /n"
        ;;
    esac
    pass
  fi
}

setup_python() { # Setup and install the needed python environment in the local cli
  printf "${CHARS_LINE}\n"
  printf "Python Envrionment Setup:\n"
  printf "Setting up python environment at '${CLI_PATH}/python/venv/'..."
  deactivate 2> /dev/null
  rm -r "${CLI_PATH}/python/venv" 2> /dev/null
  python3 -m virtualenv "${CLI_PATH}/python/venv" > /dev/null
  printf "done\n"
  source "${CLI_PATH}/python/venv/bin/activate"
  printf "Installing python requirements in local virtualenv (this may take a while)..."
  pip3 install -r "${CLI_PATH}/python/requirements.txt" > /dev/null
  printf "done\n"
  deactivate
}

add_to_path() { # Add the cli to a globally accessable path
  printf "${CHARS_LINE}\n"
  printf "Making '${CLI_COMMAND}' globally accessable: \nCreating link from '${CLI_PATH}/${CLI_COMMAND}.sh' as '${BIN_DIR}/${CLI_COMMAND}':\n"
  if [ ! $(ln -sf "${CLI_PATH}/${CLI_COMMAND}.sh" "${BIN_DIR}/${CLI_COMMAND}") ]; then
    printf "WARNING!: Super User priviledges required to complete link! Using 'sudo'.\n"
    sudo ln -sf "${CLI_PATH}/${CLI_COMMAND}.sh" "${BIN_DIR}/${CLI_COMMAND}"
    printf "'sudo' usage successful! /n"
  fi
  printf "done\n"
}

success_message() { # Send a success message to the user on successful installation
  printf "${CHARS_LINE}\n"
  printf "${CLI_NAME} (${CLI_COMMAND}) has been successfully installed \n"
  printf "You can verify the installation with '${CLI_COMMAND} version'\n"
  printf "To get started use '${CLI_COMMAND} help'\n"
}

main() {
  check_os
  check_git
  check_python3
  check_previous_installation
  install_new "$@"
  check_for_bkps
  setup_python
  add_to_path
  success_message
  printf "${CHARS_LINE}\n"
}

main "$@"
exit 1
