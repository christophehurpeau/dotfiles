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

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  # TODO make sure in ~/.zshrc this file is not imported
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# https://github.com/sorin-ionescu/prezto/issues/1876
unsetopt PATH_DIRS

# TODO make sure in ~/.zshrc this file is not imported
source ~/.dotfiles/p10k.zsh

source ~/.dotfiles/bash_aliases
source ~/.bash_aliases

export "PATH=$HOME/bin:$HOME/.dotfiles/bin:$PATH"

# if [[ -f ~/.env ]]; then
#   eval $(cat ~/.env | sed 's/^/export /')
# fi

# https://docs.brew.sh/Shell-Completion
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi
