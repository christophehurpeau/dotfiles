#!/bin/sh

git clone git@github.com:christophehurpeau/config-gitted.git ~/config-gitted/
ln -s ~/config-gitted/gitconfig ~/.gitconfig
rm ~/.config/sublime-text-3/Packages/User/Preferences.sublime-settings ; ln -s ~/config-gitted/Preferences.sublime-settings ~/.config/sublime-text-3/Packages/User/Preferences.sublime-settings
echo 'source ~/config-gitted/bashrc' >> ~/.bashrc
echo 'source ~/config-gitted/zshrc' >> ~/.zshrc
echo 'source ~/config-gitted/bash_aliases' >> ~/.aliases
# sed -i "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"candy\"/g" ~/.zshrc
sed -i "s/plugins=(git)/plugins=(bower composer docker fabric git github npm sudo)/g" ~/.zshrc
