# docker aliases

export DKR_HOME=$HOME/.dkr

function dkr-shell(){
    docker run -i -t "$1" /bin/bash
}

function dkr-images(){
    docker images
}

function dkr-ps(){
    docker ps -a
}

function dkr-cleanc(){
    docker rm `docker ps -a -q`
}

function dkr-cleani(){
    docker rmi $(docker images | grep "^<none>"  | expand | tr -s ' '  | cut -d ' ' -f3)
}

function dkr-self-update(){
    cd $DKR_HOME 
    git pull upstream master
}
