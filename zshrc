export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='code --wait'
fi


export REACT_EDITOR='code'
export "PATH=$HOME/.local/bin:$HOME/bin:$HOME/.dotfiles/bin:$PATH"
if [[ -d /opt/homebrew/bin ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi

pretty-time-ms-to-var() {
  local human total_ms=$1 var=$2
	local days=$(( total_ms / 1000 / 60 / 60 / 24 ))
	local hours=$(( total_ms / 1000 / 60 / 60 % 24 ))
	local minutes=$(( total_ms / 1000 / 60 % 60 ))
	local seconds=$(( total_ms / 1000 % 60 ))
  local ms=$(( total_ms % 1000 ))
	(( days > 0 )) && human+="${days}d "
	(( hours > 0 )) && human+="${hours}h "
	(( minutes > 0 )) && human+="${minutes}m "
	human+="${seconds}s ${ms}ms"

	# Store human readable time in a variable as specified by the caller
	typeset -g "${var}"="${human}"
}

# `brew shellenv` exports FPATH, so child shells inherit it instead of their
# built-in defaults; after a zsh upgrade it points to a removed Cellar dir
# (compinit/bashcompinit not found). Stop exporting it and repair fpath.
typeset +x FPATH
typeset -g DOTFILES_BREW_PREFIX=''
if (( $+commands[brew] )); then
  DOTFILES_BREW_PREFIX=$(brew --prefix)
fi
() {
  fpath=(${^fpath}(N-/))
  local -a found=(${^fpath}/compinit(N))
  if (( ! $#found )) && [[ -n $DOTFILES_BREW_PREFIX ]]; then
    fpath+=("$DOTFILES_BREW_PREFIX/share/zsh/functions")
  fi
}

# make sure iterm uses brew site functions even if the wrong zsh is used.
if [[ -n $DOTFILES_BREW_PREFIX ]]; then
  fpath+=("$DOTFILES_BREW_PREFIX/share/zsh/site-functions")
fi
[[ -d $HOME/.zsh/pure ]] && fpath+=("$HOME/.zsh/pure")
fpath+=("$HOME/.dotfiles/completions")
autoload -U promptinit; promptinit
autoload -Uz compinit ; compinit


if [ "$CURSOR_AGENT" != "true" ] && [ "$AGENT" != "true" ] && [ "$AGENT" != "1" ] && [ "$NO_COLOR" != "1" ]; then
  # https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md
  if [[ -n $DOTFILES_BREW_PREFIX ]]; then
    source "$DOTFILES_BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  elif [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  fi


  # optionally define some options
  PURE_CMD_MAX_EXEC_TIME=1

  # change the path color
  zstyle :prompt:pure:path color white

  # change the color for both `prompt:success` and `prompt:error`
  zstyle ':prompt:pure:prompt:*' color cyan

  # turn on git stash status
  zstyle :prompt:pure:git:stash show yes
fi

prompt pure

# preserve the prompt that `prompt pure` set so we can reuse it in hooks
PURE_ORIG_PROMPT="$PROMPT"


# Change cursor to I-beam
printf '\033[5 q\r'

if [ "$CURSOR_AGENT" != "true" ] && [ "$AGENT" != "true" ] && [ "$AGENT" != "1" ] && [ "$NO_COLOR" != "1" ]; then
  # exit code
  # enable prompt substitution so variables are expanded each prompt
  setopt PROMPT_SUBST

  # dynamic error code segment (set by precmd)
  ERROR_CODE=''
  # dynamic command duration segment (set by precmd)
  CMD_INFO=''


  # Cmd duration (if any) + time + symbol colored by last exit status
  # '' = separator
  PROMPT='${CMD_INFO}''%F{yellow}%*'' %(?.%F{yellow}❯.%F{red}❯)%f '$PROMPT


  # Record command start time so we can compute elapsed time in precmd
  preexec_record_start() {
    typeset -g custom_cmd_timestamp=$(( EPOCHREALTIME * 1000 ))
  }

  precmd_promptcustom() {
    local last=$?
    if (( ${#pipestatus} > 1 )); then
      local any=0 s
      for s in "${pipestatus[@]}"; do
        if (( s != 0 )); then
          any=1
          break
        fi
      done
      if (( any )); then
        CMD_INFO="%F{red}${(j.|.)pipestatus}%f "
      else
        CMD_INFO=''
      fi
    else
      if (( last != 0 )); then
        CMD_INFO="%F{red}${last}%f "
      else
        CMD_INFO=''
      fi
    fi


    integer elapsedInMs
    (( elapsedInMs = (EPOCHREALTIME*1000) - ${custom_cmd_timestamp:-$(( EPOCHREALTIME * 1000 ))} ))
    typeset -g custom_cmd_exec_time=
    (( elapsedInMs > 500 )) && {
      pretty-time-ms-to-var $elapsedInMs "custom_cmd_exec_time"
    }

    # Compute elapsed time since last command (if any) and build a first line
    if [[ -n "$custom_cmd_exec_time" ]]; then
      CMD_INFO=$CMD_INFO"%F{blue}Took ${custom_cmd_exec_time}%f"
    fi

    if [[ -n "$CMD_INFO" ]]; then
      CMD_INFO="$CMD_INFO"$'\n'
    fi
    unset custom_cmd_timestamp
  }

  add-zsh-hook preexec preexec_record_start
  add-zsh-hook precmd precmd_promptcustom

  # https://github.com/romkatv/powerlevel10k/issues/563
  # Move prompt to the bottom
  printf '\n%.0s' {1..100}

  # shortcuts for moving by word
  bindkey "^[[1;3C" forward-word
  bindkey "^[[1;3D" backward-word

  # Others

  source ~/.dotfiles/bash_aliases
  [[ -f ~/.bash_aliases ]] && source ~/.bash_aliases

  # if [[ -f ~/.env ]]; then
  #   eval $(cat ~/.env | sed 's/^/export /')
  # fi


  if [[ -n $DOTFILES_BREW_PREFIX ]]; then
    HOMEBREW_COMMAND_NOT_FOUND_HANDLER="$(brew --repository)/Library/Homebrew/command-not-found/handler.sh"
    if [[ -f "$HOMEBREW_COMMAND_NOT_FOUND_HANDLER" ]]; then
      source "$HOMEBREW_COMMAND_NOT_FOUND_HANDLER"
    fi
  fi
fi


# https://superuser.com/questions/410965/command-history-in-zsh

setopt INC_APPEND_HISTORY
# don't record commands prefixed with a space
setopt HIST_IGNORE_SPACE
# unsetopt share_history

# Load syntax highlighting last, after widgets and key bindings.
if [[ $CURSOR_AGENT != true && $AGENT != true && $AGENT != 1 && $NO_COLOR != 1 ]]; then
  if [[ -n $DOTFILES_BREW_PREFIX ]]; then
    source "$DOTFILES_BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  elif [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  fi
fi
