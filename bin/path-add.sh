#!/bin/bash
set -e

function usage(){
    echo "usage: $0 [-s] script"
    echo ""
    echo "  -s stands for 'source'"
    echo "  adds to bash startup a script to be executed or a lib to be sourced"
    exit 0
}

FILES="$HOME/.bashrc $HOME/.profile"

# parameter check
[ -z "$1" ] && usage
[ "$1" == "-s" ] && [ -z "$2" ] && usage
[ "$1" != "-s" ] && [ ! -z "$2" ] && usage
[ ! -z "$3" ] && usage
 
# command to be added
[ ! -z "$2" ] && TO_ADD="source $2"
[ -z "$2" ] && TO_ADD="$1"
echo "adding => $TO_ADD"

for FILE in $FILES; do 
    [ ! -f $FILE ] && continue

    if ( grep "$TO_ADD" $FILE > /dev/null ); then
        echo "    already added to $FILE"
        exit 0
    else
        [[ -d /etc/coreos/ ]] && ( unlink $FILE && echo source /usr/share/skel/`basename $FILE` >> $FILE)
        echo $TO_ADD >> $FILE
        echo "    added to $FILE"
        break
    fi
    
done

echo "    re-run bash to take effect. Ex: 'bash -l'"
