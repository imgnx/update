#!/bin/bash
#shellcheck shell=bash

mkdir -p "$HOME/bin" || {
  echo "[error] Could not create $HOME/bin"
  exit 1
}

cp ./dist/update "$HOME/bin/update" || {
  echo "[error] Could not copy update script to $HOME/bin"
  exit 1
}

# Ensure that $HOME/bin is on your $PATH
if ! echo "$PATH" | grep -q "$HOME/bin"; then

  # If not, add $HOME/bin to PATH via Run Commands (.rc file)
  echo "export PATH=\"$HOME/bin:$PATH\"" >>"$HOME/.$(basename "$SHELL")rc"

  read -r -p "Added $HOME/bin to your PATH. Do you want to restart your shell now? [y/N] " response

  response=${response,,} # Convert to lowercase

  if [[ "$response" != "y" && "$response" != "yes" ]]; then
    echo "Please restart your shell to apply changes."
    exit 0
  fi

  echo "Restarting your shell to apply changes..."

  # Restart the shell to apply changes
  exec "$SHELL" --login

fi
