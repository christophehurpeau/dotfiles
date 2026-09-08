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

# Jump to a git worktree. Resolution lives in bin/git-worktrees (`git wt` lists
# them); this shim only performs the cd. Empty output means selection cancelled.
# Autocomplete: completions/_wt -- `wt <TAB>` offers every worktree by name,
# described by its branch and the commits it has above main, and jumps straight
# there. Without an argument, git-worktrees draws a picker (type to filter,
# up/down, Enter).
wt() {
  local target
  target="$(git-worktrees "$@")" || return $?
  [ -n "$target" ] || return 0
  cd "$target"
}

# Deprecated yarn/bun shortcuts: point to the pm equivalent and fail, instead of
# running yarn/bun in projects that may use a different package manager.
_use_p() {
  echo "Use '$*' instead" >&2
  return 1
}

alias p='pm'
alias s='pm s'
alias pi='pm i'
alias pb='pm b'
alias pt='pm t'

alias b='_use_p p'
alias bi='_use_p p i'

alias y='_use_p p'
alias yui='_use_p p ui'
alias yu='_use_p p u'
alias ydd='_use_p p dedupe'
alias yr='_use_p p r'
alias yd='_use_p p d'
alias ys='_use_p p s'
alias yt='_use_p p t'
alias yb='_use_p p b'
alias ybd='_use_p p r build:definitions'
alias yw='_use_p p r watch'
alias yl='_use_p p r lint'
alias yn='_use_p p x node'

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
