#!/bin/zsh

chsh -s /bin/zsh

git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done


git clone git@github.com:christophehurpeau/config-gitted.git ~/config-gitted/ || git clone https://github.com/christophehurpeau/config-gitted.git ~/config-gitted/

ln -s ~/config-gitted/gitconfig ~/.gitconfig
rm ~/.zshrc
rm ~/.zpreztorc
ln -s ~/config-gitted/zpreztorc ~/.zpreztorc

if [ -f ~/.config/sublime-text-3/Packages/User/Preferences.sublime-settings ]; then
  rm ~/.config/sublime-text-3/Packages/User/Preferences.sublime-settings ; ln -s ~/config-gitted/Preferences.sublime-settings ~/.config/sublime-text-3/Packages/User/Preferences.sublime-settings
fi
echo 'source ~/config-gitted/bashrc' >> ~/.bashrc
echo 'source ~/config-gitted/zshrc' >> ~/.zshrc

source ~/.zshrc
