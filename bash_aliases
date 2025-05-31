#function g() {
#  if [ "$*" = "push -f" ]; then
#    echo "push -f forbidden"
#  else
#    git $*
#  fi
#}
alias g='git'

function y() {
  if [ -f bun.lock ]; then
    echo "Use b instead"
    return 1
  elif [ -f package-lock.json ]; then
    echo "Use ni instead"
    return 1
  else
    yarn $*
  fi
}

alias yui='y && yarn upgrade-interactive --latest'
alias yu='yui && yarn upgrade'
alias ydd='npx yarn-deduplicate `npx find-up-cli yarn.lock` && yarn --prefer-offline'
alias yr='yarn run'
alias yd='yarn dev'
alias ys='yarn start'
alias yt='yarn test'
alias yb='yarn build'
alias ybd='yarn build:definitions'
alias yw='yarn watch'
alias yl='yarn lint'
alias yn='yarn node'

alias b='bun'
alias bi='bun install --save-text-lockfile'

function s() {
  if [ ! -f package.json ]; then
    echo "No package.json found"
    return 1
  fi

  local startCommand='start'
  if [ "$(jq '.scripts.dev' package.json)" != "null" ]; then
    startCommand='dev'
  fi

  # todo: findup
  if [ -f package-lock.json ]; then
    npm run "$startCommand" $*
  elif [ -f yarn.lock ]; then
    yarn run "$startCommand" $*
  elif [ -f bun.lock ]; then
    bun run "$startCommand" $*
    return 1
  elif [ -f bun.lockb ]; then
    echo "Invalid bun.lockb found, run 'bun install --save-text-lockfile' to fix"
    return 1
  else
    yarn run "$startCommand" $*
    # echo "No package-lock.json or yarn.lock found"
    return 1
  fi
}

alias weather='curl wttr.in'
alias mypublicip='curl ipinfo.io/ip'

# function ssh () {/usr/bin/ssh -t $@ "tmux -CC new -As chris || tmux new -As chris || screen -D -R -S chris || zsh || bash ";}

alias ssh-pwd='ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no'

function nano () {
    if [ $USER != 'root' ]; then
        if [ -f $1 ]; then
            if [ ! -w $1 ]; then
                echo "This file is not writable !"
            fi
        fi
    fi
    /usr/bin/nano $* # --mouse --tabstospaces --tabsize=4 --autoindent $*
}


alias wifisetupdns='networksetup -setdnsservers Wi-Fi 1.1.1.1 1.0.0.1 2606:4700:4700::1111 2606:4700:4700::1001'
alias wifiremovesetupdns='networksetup -setdnsservers Wi-Fi "Empty"'


alias sleepnow="killall Simulator Slack node java Telegram ; networksetup -setairportpower en0 off ; watchman watch-del-all ; pmset sleepnow"
