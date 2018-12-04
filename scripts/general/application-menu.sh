#!/bin/bash

APPLICATION_DESKTOP_PATH="/usr/share/application/"
APPLICATION_NAME=$1
APPLICATION_DESKTOP_FILE="$APPLICATION_NAME$APPLICATION_NAME.desktop"
PARAMS=""

while (( "$#" )); do
  case "$1" in
    -c|--comment)
      COMMENT=$2
      shift 2
      ;;
    -g|--generic-name)
      GENERIC_NAME=$2
      shift 2
      ;;
    -e|--exec)
      EXEC=$2
      shift 2
      ;;
    -i|--icon)
      ICON=$2
      shift 2
      ;;
    -t|--type)
      TYPE=$2
      shift 2
      ;;
    -h|--help)
      echo "-c --comment"
      echo "-g --generic-name"
      echo "-e --exec"
      echo "-i --icon"
      echo "-t --type"
      shift 1
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"

cat > "$APPLICATION_DESKTOP_FILE" << _EOF_
[Desktop Entry]
Name="$APPLICATION_NAME"
Comment="$COMMENT"
GenericName="$GENERCI_NAME"
Exec="$EXEC"
Icon="$ICON"
Type="$TYPE"
StartupNotify=true
_EOF_

