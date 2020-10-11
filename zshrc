unsetopt share_history

export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='code'
else
  export EDITOR='nano'
fi

export REACT_EDITOR='code'

# https://github.com/romkatv/powerlevel10k/issues/563
# Change cursor to I-beam
printf '\033[5 q\r'

# Move prompt to the bottom
printf '\n%.0s' {1..100}

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

source ~/config-gitted/p10k.zsh

source ~/config-gitted/bash_aliases
source ~/.bash_aliases

if [[ -f ~/.env ]]; then
  eval $(cat ~/.env | sed 's/^/export /')
fi

# gpg agent
# [ -f ~/.gpg-agent-info ] && source ~/.gpg-agent-info
# if [ -S "${GPG_AGENT_INFO%%:*}" ]; then
#   export GPG_AGENT_INFO
# else
#   eval $(gpg-agent --daemon --write-env-file ~/.gpg-agent-info --allow-preset-passphrase)
# fi

# https://docs.brew.sh/Shell-Completion
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi
