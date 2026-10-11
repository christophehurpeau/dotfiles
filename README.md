dotfiles
=============

My gitted configuration files

## tmux: shared defaults and local overrides

`tmux.conf` contains the shared settings. The setup creates a regular
`~/.tmux.conf` loader that reads, in order:

1. `~/.dotfiles/tmux.conf` — shared settings tracked in this repository.
2. `~/.config/tmux/machine-colors.conf` — optional machine colours (managed by infra on ida).
3. `~/.config/tmux/local.conf` — optional settings specific to this computer, loaded last.

Edit `~/.config/tmux/local.conf` to override any shared setting without changing
the repository. The shared theme uses a dark bar, a coloured hostname badge and
active window, spaced window labels, and a muted session name and clock. Its
default accent is blue. Set the machine's accent in `machine-colors.conf`:

```tmux
set -g @machine-color 'colour208'
```

This changes the hostname badge, active window text and active pane border together.
The hostname uses explicit RGB near-black text for contrast, independent of the
terminal's bold-black palette. For other local overrides, for example:

```tmux
set -g status-style 'fg=black,bg=colour75'
set -g status-left ' #h | #S '
set -g status-left-length 40
```

The general `install` calls this setup. To configure only tmux:

```sh
sh ~/.dotfiles/setup-tmux
```

The setup migrates the old symlink to the shared `tmux.conf` into a loader.
An existing regular `~/.tmux.conf` is preserved as `local.conf`; if both files
already exist, setup stops without overwriting either. Unrelated symlinks are
also left untouched. Re-running the setup keeps an existing loader and local
overrides unchanged. No tmux session is restarted.

Reload an existing session after edits:

```sh
tmux source-file ~/.tmux.conf
```

Without a running tmux server, the next session loads the config automatically.

## zsh and Pure

`zshrc` is the shared configuration for macOS and Linux: Pure prompt, autosuggestions,
syntax highlighting and common aliases. macOS uses Homebrew's dependencies;
Linux uses the distro's zsh plugin packages and Pure at `~/.zsh/pure` (v1.24.0).

`sh ~/.dotfiles/setup-zsh` creates `.zshrc`, `.zprofile` and `.zshenv` loaders.
Existing files are backed up as `*.before-dotfiles`; repeated runs are idempotent.
`.zprofile` retains `.profile`'s login PATH and interactive SSH tmux attachment.
`.zshenv` supplies the user bin paths for noninteractive SSH commands too.
Local interactive overrides can go in `~/.config/zsh/local.zsh`.

Install zsh and the plugins first. On managed Linux hosts, installation, setup
and login-shell selection are handled by infra's Ansible `zsh` role. The general
dotfiles installer also invokes `setup-zsh`.

## Installation

```
wget -O - https://raw.githubusercontent.com/christophehurpeau/dotfiles/master/remote-install.sh | zsh
```

```
curl -s https://raw.githubusercontent.com/christophehurpeau/dotfiles/master/remote-install.sh | zsh
```

With brew:

```
brew install zsh git-delta
```


Font: https://github.com/powerline/fonts/blob/master/Meslo%20Slashed/Meslo%20LG%20S%20Regular%20for%20Powerline.ttf
