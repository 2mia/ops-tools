#!/bin/bash

function show_help(){
    echo run as:
    echo "   $0 cookbooks/content-migration/"
    echo "   $0 cookbooks/content-migration/ --autoincrement"
    echo 
    echo or in a cookbook dir:
    echo "   $0 "
    echo "   $0 --autoincrement"
    exit 0
}

AUTOINCREMENT=false
echo "$*" | grep -- "--autoincrement" > /dev/null && AUTOINCREMENT=true
echo "$*" | grep -- "--help" > /dev/null && show_help

increment_version() {
     local v=$1
     if [ -z $2 ]; then 
        local rgx='^((?:[0-9]+\.)*)([0-9]+)($)'
     else 
        local rgx='^((?:[0-9]+\.){'$(($2-1))'})([0-9]+)(\.|$)'
        for (( p=`grep -o "\."<<<".$v"|wc -l`; p<$2; p++)); do 
           v+=.0; done; fi
     val=`echo -e "$v" | perl -pe 's/^.*'$rgx'.*$/$2/'`
     echo "$v" | perl -pe s/$rgx.*$'/${1}'`printf %0${#val}s $(($val+1))`/
}

function cookbook_release(){
    COOKBOOK_PATH=$1
    echo processing cookbook in $COOKBOOK_PATH
    cd $COOKBOOK_PATH

    [ ! -f metadata.rb ] && echo this does not look like a cookbook. Try adding "--help" && exit -1

    VERSION=`grep version metadata.rb | expand | tr -s ' ' | cut -d ' ' -f2`
    #strip quotes
    eval "VERSION=$VERSION"
    echo current version: $VERSION

    EXISTS=`git tag | grep $VERSION`
    [ ! -z "$EXISTS" ] && ! $AUTOINCREMENT &&
        echo "version already exists [$EXISTS]" &&
        echo "   run it as '$0 $@ --autoincrement' to autoincrement !" &&
        exit -2

    #default, trying to tag with existin ver in metadata.rb
    NEW_VERSION=$VERSION

    $AUTOINCREMENT && 
            NEW_VERSION=`increment_version $VERSION` &&
            echo bumping the version to $NEW_VERSION &&
            echo this will create a new commit &&
            sed -i '' "s/$VERSION/$NEW_VERSION/g" metadata.rb
    git diff
    git add . -A
    git commit -m "version $NEW_VERSION; changes: "
    #allow editing the message
    git commit --amend
    LAST_COMMIT=`git log --oneline  | head -1 | cut -d' ' -f1`
    git tag "v$NEW_VERSION" $LAST_COMMIT
    git push 
    git push --tags
        
}

# look in current working path
[ -z "$1" ]  && cookbook_release `pwd` && exit 0
# look in the specified folder
cookbook_release $1 
