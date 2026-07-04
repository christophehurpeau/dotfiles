#function g() {
#  if [ "$*" = "push -f" ]; then
#    echo "push -f forbidden"
#  else
#    git $*
#  fi
#}
alias g='git'

alias '..'='cd ..'
alias '...'='cd ../..'
alias '....'='cd ../../..'

# Fast cd to configured project directories. Path resolution lives in bin/c-path;
# this shim only performs the cd (a bin cannot change the parent shell's dir).
# Config (per-machine, gitignored): ~/.dotfiles/config/cd-paths  -- format: key=path
# `c` with no argument uses the `default` key. Autocomplete: completions/_c
c() {
  local target
  target="$(c-path "${1:-default}")" || return $?
  cd "$target"
}


function y() {
  if [ -f bun.lock ]; then
    echo "Use b instead"
    return 1
  elif [ -f pnpm-lock.yaml ]; then
    echo "Use pnpm instead"
    return 1
  elif [ -f package-lock.json ]; then
    echo "Use ni instead"
    return 1
  else
    yarn $*
  fi
}

# Deprecated yarn/bun shortcuts: point to the pm equivalent and fail, instead of
# running yarn/bun in projects that may use a different package manager.
_use_pm() {
  echo "Use '$*' instead" >&2
  return 1
}

alias yui='_use_pm pm ui'
alias yu='_use_pm pm u'
alias ydd='_use_pm pm dedupe'
alias yr='_use_pm pm r'
alias yd='_use_pm pm d'
alias ys='_use_pm pm s'
alias yt='_use_pm pm t'
alias yb='_use_pm pm b'
alias ybd='_use_pm pm r build:definitions'
alias yw='_use_pm pm r watch'
alias yl='_use_pm pm r lint'
alias yn='_use_pm pm x node'

alias bi='_use_pm pm i'

function b() {
  if [ -f package-lock.json ]; then
    echo "Use ni instead"
    return 1
  elif [ -f pnpm-lock.yaml ]; then
    echo "Use pnpm instead"
    return 1
  elif [ -f yarn.lock ]; then
    echo "Use y instead"
    return 1
  else
    bun $*
  fi
}


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
  if [ -f pnpm-lock.yaml ]; then
    pnpm run "$startCommand" $*
  elif [ -f package-lock.json ]; then
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


alias sleepnow="killall Simulator Slack node java Telegram Safari Preview Home Notes Messages Transporter Photos Discord Notion; networksetup -setairportpower en0 off ; watchman watch-del-all ; pmset sleepnow"

# 4-pane Claude workspace in the current working directory
#   pane 0,1: default effort
#   pane 2:   CLAUDE_CODE_EFFORT_LEVEL=medium
#   pane 3:   CLAUDE_CODE_EFFORT_LEVEL=low
cwork() {
  local dir="$PWD"
  local session="cwork-$(basename "$dir")"

  # restore existing session if it exists
  if tmux has-session -t "$session" 2>/dev/null; then
    tmux switch-client -t "$session"
    return
  fi

  # Launch claude as each pane's argv (not via send-keys) so we don't race
  # against .zshrc sourcing / instant-prompt plugins. `exec zsh` keeps the
  # pane alive with a shell prompt after claude exits.
  # After `select-layout tiled`, panes land as:
  #   index 0 = top-left  (high)
  #   index 1 = top-right (high)
  #   index 2 = bottom-left  (medium)
  #   index 3 = bottom-right (low)
  local p0 p1 p2 p3
  p0=$(tmux new-session  -d  -s "$session" -c "$dir" -n claude -P -F '#{pane_id}' \
       'claude; exec zsh')
  p1=$(tmux split-window -h -t "$p0" -c "$dir" -e CLAUDE_CODE_EFFORT_LEVEL=medium -P -F '#{pane_id}' \
       'claude; exec zsh')
  p2=$(tmux split-window -v -t "$p0" -c "$dir"                                    -P -F '#{pane_id}' \
       'claude; exec zsh')
  p3=$(tmux split-window -v -t "$p1" -c "$dir" -e CLAUDE_CODE_EFFORT_LEVEL=low    -P -F '#{pane_id}' \
       'claude; exec zsh')
  tmux select-layout -t "$session:0" tiled
  tmux select-pane -t "$p0"

  if [ -n "$TMUX" ]; then
    tmux switch-client -t "$session"
  else
    tmux attach -t "$session"
  fi
}
