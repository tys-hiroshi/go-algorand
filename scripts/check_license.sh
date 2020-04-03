#!/bin/bash

PROJECT_ROOT=$(git rev-parse --show-toplevel)
LICENSE_LOCATION="$PROJECT_ROOT"/scripts/LICENSE_HEADER
NUMLINES=$(< "$LICENSE_LOCATION" wc -l | tr -d ' ')
LICENSE=$(sed "s/{DATE_Y}/$(date +"%Y")/" "$LICENSE_LOCATION")
VERSIONED_GO_FILES=$(git ls-tree --full-tree --name-only -r HEAD | grep "\.go$")
EXCLUDE=(
    "Code generated by"
    "David Lazar"
    "Go Authors"
    "Google Inc"
    "Prometheus Authors"
)
FILTER=$(IFS="|" ; echo "${EXCLUDE[*]}")
INPLACE=false
VERBOSE=false
MOD_COUNT=0
RETURN_VALUE=0

usage() {
    echo "check_license"
    echo
    echo "Usage: $0 [args]"
    echo
    echo "Args:"
    echo "-i    Edit in-place."
    echo "-v    Verbose, same as doing \`head -n ${NUMLINES:-16}\` on each file."
    echo
}

GREEN_FG=$(tput setaf 2 2>/dev/null)
RED_FG=$(tput setaf 1 2>/dev/null)
TEAL_FG=$(tput setaf 6 2>/dev/null)
YELLOW_FG=$(tput setaf 3 2>/dev/null)
END_FG_COLOR=$(tput sgr0 2>/dev/null)

while [ "$1" != "" ]; do
    case "$1" in
        -i)
            INPLACE=true
            ;;
        -v) VERBOSE=true
            ;;
        -h)
            usage
            exit 0
            ;;
        *)
            echo "${RED_FG}[ERROR]${END_FG_COLOR} Unknown option $1"
            usage
            exit 1
            ;;
    esac
    shift
done

for FILE in $VERSIONED_GO_FILES
do
    # https://en.wikipedia.org/wiki/Cat_(Unix)#Useless_use_of_cat
    if [[ $LICENSE != $(<"$PROJECT_ROOT/$FILE" head -n "$NUMLINES") ]]
    then
        if <"$PROJECT_ROOT/$FILE" head -n "$NUMLINES" | tr "\n" " " | grep -qvE "$FILTER"
        then
            RETURN_VALUE=1

            if ! $VERBOSE
            then
                if $INPLACE
                then
                    cat <(echo "$LICENSE") "$PROJECT_ROOT/$FILE" > "$PROJECT_ROOT/$FILE".1 &&
                        mv "$PROJECT_ROOT/$FILE"{.1,}
                    ((MOD_COUNT++))
                fi
                echo "$FILE"
            else
                echo -e "\n${RED_FG}$FILE${END_FG_COLOR}"
                <"$PROJECT_ROOT/$FILE" head -n "$NUMLINES"
                echo
            fi
        fi
    fi
done

# check the README.md file.
READMECOPYRIGHT="Copyright (C) 2019-$(date +"%Y"), Algorand Inc."
if [ "$(<README.md grep "${READMECOPYRIGHT}" | wc -l | tr -d ' ')" = "0" ]; then
    RETURN_VALUE=1
    echo "README.md file need to have it's license date range updated."
fi

if [ $RETURN_VALUE -ne 0 ] ; then
    echo -e "\n${RED_FG}FAILED LICENSE CHECK.${END_FG_COLOR}"
    if [ $INPLACE == "false" ]; then
      echo -e "Use 'check_license.sh -i' to fix."
    else
      echo "Modified $MOD_COUNT file(s)."
    fi
    echo ""
fi

exit $RETURN_VALUE

