#!/bin/bash

APPLICATION_DESKTOP_PATH="/usr/share/applications/"
APPLICATION_NAME=$1
APPLICATION_DESKTOP_FILE="$APPLICATION_DESKTOP_PATH$APPLICATION_NAME.desktop"
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
    -k|--keywords)
      KEYWORDS=$2
      shift 2
      ;;
    -h|--help)
      echo "-c --comment"
      echo "-g --generic-name"
      echo "-e --exec"
      echo "-i --icon"
      echo "-t --type : application categories (splitted by ';')"
      echo "-k --keywords : application keywords (splitted by ';')"
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

if [ -n "$APPLICATION_NAME" ]; then

echo "Creating file: $APPLICATION_DESKTOP_FILE"

cat > "$APPLICATION_DESKTOP_FILE" << _EOF_
[Desktop Entry]
Name=$GENERIC_NAME
Comment=$COMMENT
GenericName=$GENERIC_NAME
Exec=$EXEC
Icon=$ICON
Type=Application
Categories=$TYPE
Keywords=$KEYWORDS
StartupNotify=true
_EOF_
fi

