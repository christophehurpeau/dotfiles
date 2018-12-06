function g() {
  if [ "$*" = "push -f" ]; then
    echo "push -f forbidden"
  else
    git $*
  fi
}

#function n() {
#  if [ -f yarn.lock ]; then
#    echo "Use y instead"
#  else
#    npm $*
#  fi
#}
alias n='npm'

function nr() {
  if [ -f yarn.lock ]; then
    echo "Use yr instead"
    return 1
  else
    npm -s run $*
  fi
}

function ni() {
  if [ -f yarn.lock ]; then
    echo "Use y instead"
    return 1
  else
    npm i $*
  fi
}

# alias nup='ncu -dua && ncu -up && npm i'

function y() {
  if [ -f package-lock.json ]; then
    echo "Use ni instead"
    return 1
  else
    yarn $*
  fi
}

alias yui='y && yarn upgrade-interactive --latest && npx yarn-deduplicate `npx find-up-cli yarn.lock` && yarn --prefer-offline'
alias yu='yui && yarn upgrade'
alias yr='yarn run'
alias s='yarn start'
alias ys='yarn start'
alias yt='yarn test'
alias yb='yarn build'
alias yw='yarn watch'
alias yl='yarn lint'
alias webstorm='open -a /Applications/WebStorm.app'

function dockerrm() {
    docker stop $1 ; docker rm $1
}

alias weather='curl wttr.in'
alias mypublicip='curl ipinfo.io/ip'

# function ssh () {/usr/bin/ssh -t $@ "tmux -CC new -As chris || tmux new -As chris || screen -D -R -S chris || zsh || bash ";}

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
