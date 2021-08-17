#!/bin/zsh

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo chsh -s /bin/zsh $USER

git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

ln -s "$BASEDIR/gitconfig" ~/.gitconfig
touch ~/.bash_aliases
rm ~/.zshrc
rm ~/.zpreztorc
ln -s "$BASEDIR/zpreztorc" ~/.zpreztorc

echo 'source "$BASEDIR/bashrc"' >> ~/.bashrc
echo 'source "$BASEDIR/zshrc"' >> ~/.zshrc

source ~/.zshrc
