#!/usr/bin/env zsh
# Symlink dotfiles from this repo into $HOME. Safe to re-run.
DOTFILE_DIR=${0:A:h}   # absolute dir of this script, independent of cwd
mkdir -p ~/.config

# directories (-n so an existing dir symlink is replaced, not followed into)
ln -sfn $DOTFILE_DIR/kitty        ~/.config/kitty
ln -sfn $DOTFILE_DIR/.config/doom ~/.config/doom

# files
ln -sf $DOTFILE_DIR/.zshenv  ~/.zshenv
ln -sf $DOTFILE_DIR/.zshrc   ~/.zshrc
ln -sf $DOTFILE_DIR/.skhdrc  ~/.skhdrc
ln -sf $DOTFILE_DIR/.yabairc ~/.yabairc
