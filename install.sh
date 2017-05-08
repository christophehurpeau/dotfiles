#!/bin/sh

git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done


git clone git@github.com:christophehurpeau/config-gitted.git ~/config-gitted/

ln -s ~/config-gitted/gitconfig ~/.gitconfig
rm ~/.zshrc
rm ~/.zpreztorc
ln -s ~/config-gitted/zpreztorc ~/.zpreztorc

rm ~/.config/sublime-text-3/Packages/User/Preferences.sublime-settings ; ln -s ~/config-gitted/Preferences.sublime-settings ~/.config/sublime-text-3/Packages/User/Preferences.sublime-settings
echo 'source ~/config-gitted/bashrc' >> ~/.bashrc
echo 'source ~/config-gitted/zshrc' >> ~/.zshrc
~/.zshrc
