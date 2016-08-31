alias n='npm'
alias g='git'
alias nr='npm -s run'
alias ni='npm i'
alias nup='ncu -dua && ncu -up && npm i'

function dockerrm() {
    docker stop $1 ; docker rm $1
}

alias meteo='curl wttr.in'

function ssh () {/usr/bin/ssh -t $@ "tmux -CC new -As chris || tmux new -As chris || screen -D -R -S chris || zsh || bash ";}

function nano () {
    if [ $USER != 'root' ]; then
        if [ -f $1 ]; then
            if [ ! -w $1 ]; then
                echo "This file is not writable !"
            fi
        fi
    fi
    /usr/bin/nano --mouse --tabstospaces --tabsize=4 --autoindent $*
}

