export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='code'
else
  export EDITOR='nano'
fi

export REACT_EDITOR='code'
export "PATH=$HOME/bin:$HOME/.dotfiles/bin:$PATH:/opt/homebrew/bin"


autoload -U promptinit; promptinit
autoload -Uz compinit ; compinit


if [ "$CURSOR_AGENT" != "true" ] && [ "$AGENT" != "true" ] && [ "$AGENT" != "1" ] && [ "$NO_COLOR" != "1" ]; then
  # https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md
  source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi


# optionally define some options
PURE_CMD_MAX_EXEC_TIME=1


# change the path color
zstyle :prompt:pure:path color white

# change the color for both `prompt:success` and `prompt:error`
zstyle ':prompt:pure:prompt:*' color cyan

# turn on git stash status
zstyle :prompt:pure:git:stash show yes

prompt pure


# Change cursor to I-beam
printf '\033[5 q\r'

if [ "$CURSOR_AGENT" != "true" ] && [ "$AGENT" != "true" ] && [ "$AGENT" != "1" ] && [ "$NO_COLOR" != "1" ]; then
  # exit code
  # enable prompt substitution so variables are expanded each prompt
  setopt PROMPT_SUBST

  # dynamic error code segment (set by precmd)
  ERROR_CODE=''

  # base prompt: error code (if any) + symbol colored by last exit status
  PROMPT='${ERROR_CODE}%(?.%F{yellow}❯.%F{red}❯)%f '
  # time
  PROMPT='%F{yellow}%* '$PROMPT


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
        ERROR_CODE="%F{red}${(j.|.)pipestatus}%f "
      else
        ERROR_CODE=''
      fi
    else
      if (( last != 0 )); then
        ERROR_CODE="%F{red}${last}%f "
      else
        ERROR_CODE=''
      fi
    fi
  }
  add-zsh-hook precmd precmd_promptcustom

  # https://github.com/romkatv/powerlevel10k/issues/563
  # Move prompt to the bottom
  printf '\n%.0s' {1..100}

  # https://superuser.com/questions/410965/command-history-in-zsh

  setopt INC_APPEND_HISTORY
  # unsetopt share_history

  # Others

  source ~/.dotfiles/bash_aliases
  source ~/.bash_aliases

  # if [[ -f ~/.env ]]; then
  #   eval $(cat ~/.env | sed 's/^/export /')
  # fi


  HOMEBREW_COMMAND_NOT_FOUND_HANDLER="$(brew --repository)/Library/Homebrew/command-not-found/handler.sh"
  if [ -f "$HOMEBREW_COMMAND_NOT_FOUND_HANDLER" ]; then
    source "$HOMEBREW_COMMAND_NOT_FOUND_HANDLER";
  fi

fi
