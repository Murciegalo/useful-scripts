#!/bin/bash
shopt -s expand_aliases

#
# Lo script consente di creare in una sola volta più alias 
# definiti all'interno di un file passato come parametro o 
# presente all'interno della cartella corrente.
# Gli alias vengono creati per l'utente corrente.
#
# Srtuttura del comando:
#
# alias-util -(t) (aliases_file)
#
# Options:
# -t : Crea alias temporanei
# 
# Parameters:
#
# aliases_file : path del file contenente gli alias da creare
#				 se non viene passato il parametro lo script
#				 cerca all'interno della cartella corretente 
#				 un file con nome: '.aliases_profile'
#

PARAMS=""
TEMPORARY=0
FILE=""
BASH_PROFILE_FILE=${HOME}/.bashrc

while (( "$#" )); do
  case "$1" in
    -t|--tempoary)
      TEMPORARY=1
      shift 1
      ;;
    -f|--file)
      FILE=$2
      shift 2
      ;;
    --)
      shift
      break
      ;;
    -*|--*=)
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *)
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

# set positional arguments in their proper place
eval set -- "$PARAMS"

if [ -z "$FILE" ]; then
	FILE="${PWD}/.aliases_profile"
fi

MODE_LABEL="permanent"

if [ "$TEMPORARY" -eq 1 ]; then
	MODE_LABEL="tempoary"
fi

echo "Create ${MODE_LABEL} aliases from: $FILE"

if [ -e "$FILE" ]; then

	if [ "$TEMPORARY" -eq 0 ]; then
		echo "Set following aliases to file: ${BASH_PROFILE_FILE}"
		echo "" >> $BASH_PROFILE_FILE
	fi

	while IFS='' read -r LINE || [[ -n "$LINE" ]]; do

		if [ "$TEMPORARY" -eq 0 ]; then
			
			if grep -q "$LINE" "$BASH_PROFILE_FILE"; then
			 	echo "alias ${LINE} already exist!"
			else				
				echo "alias ${LINE}" >> $BASH_PROFILE_FILE
				echo "alias ${LINE} setted"
			fi
		else
			LINE="$opt" | tr -d "'"
			echo "alias $LINE"
			alias "${LINE}" || echo "Error to set alias"
		fi
	    
	done < "$FILE"

else
	if [ "$TEMPORARY" -eq 0 ]; then
		echo "${file} file not found"
	else
		echo ".aliases_profile file not found in current directory"
	fi
	exit 1
fi

