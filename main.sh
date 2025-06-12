#!/bin/bash
#shellcheck shell=bash

DEBUG=false
# if Arguments contain -d, -debug, --debug, -verbose, --v, or --verbose, DEBUG is true.
if [[ "$*" == *-d* || "$*" == *-debug* || "$*" == *--debug* || "$*" == *-verbose* || "$*" == *--v* || "$*" == *--verbose* ]]; then
      DEBUG=true
fi

function 80271208_E8EB_427F_A35C_012FB6D3B5E7() {
      echo "Installing shc..."
      if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install shc
      elif [[ -f /etc/debian_version ]]; then
            sudo apt-get install shc
      elif [[ -f /etc/redhat-release ]]; then
            sudo yum install shc
      else
            echo "Unsupported OS. Please install shc manually."
            exit 1
      fi

}

function 5772B520_57F5_433E_927E_031A8329C317() {

      # If `shc` is not installed, install it
      if ! command -v shc >/dev/null 2>&1; then
            echo "shc is required (version 4.0.3 or higher). Would you like to install it? (y/n)"
            read -r answer

            if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
                  80271208_E8EB_427F_A35C_012FB6D3B5E7
            else
                  echo "shc is required to run this script. Exiting..."
                  exit 1
            fi
      else
            # Extract version from shc usage output (stderr)
            shc_version=$(shc 2>&1 | grep -i 'shc' | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
            required_version="4.0.3"
            if [[ -n "$shc_version" && "$(printf '%s\n' "$required_version" "$shc_version" | sort -V | head -n1)" != "$required_version" ]]; then
                  echo "shc version $required_version or higher is required. Would you like to update it? (y/n)"
                  read -r answer

                  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
                        80271208_E8EB_427F_A35C_012FB6D3B5E7
                  else
                        echo "shc is required to run this script. Exiting..."
                        exit 1
                  fi
            fi
      fi

      trap 'echo -e "\n[updater] Stopped."; exit 0' INT

      # If $1 is not provided, use current directory
      if [[ -z $1 ]]; then
            source="$(pwd)"
      else
            source="$1"
      fi

      function usage() {
            cat <<EOF
update - Watch and sync a script to ~/bin as a command
      Usage: update <folder-to-sync> [name-of-command]
      If run in a directory containing main.sh and no folder is specified, uses the current directory.
      Watches <folder-to-sync>/main.sh for changes and syncs it to:
            ~/src/<folder-to-sync>/src/<name-of-command>
            ~/src/<folder-to-sync>/dist/<name-of-command>
            ~/bin/<name-of-command>
      Arguments:
            <folder-to-sync>    The folder containing main.sh to watch and sync.
            [name-of-command]   (Optional) The name for the command. Defaults to the folder name.
      Features:
            - Automatically copies main.sh when changes are detected.
            - Installs the script to ~/bin for easy access.
            - Press Ctrl+C to stop watching.
      Example:
            update ~/my-scripts         # Watches ~/my-scripts/main.sh
            update . mycmd             # Watches ./main.sh and installs as 'mycmd'

EOF
      }

      if [[ -z $source ]]; then
            echo "Error: Please provide a valid directory."
            usage
            exit 1
      elif [[ $source == "-h" || $source == "--help" ]]; then
            usage
            exit 0
      elif [[ ! -d $source ]]; then
            echo "Error: $source is not a valid directory."
            usage
            exit 1
      fi

      filename="$source/main.sh"
      basename="$(basename "$source")"
      handle="${2:-$basename}"

      mkdir -p ~/src ~/bin

      while true; do
            if [[ ! -f "$filename" ]]; then
                  echo "File $filename does not exist. Exiting..."
                  exit 1
            fi

            [[ "$DEBUG" = true ]] && echo "[DEBUG]: filename=$filename" && echo "[DEBUG]: cmd=$handle"

            if [[ -d "$HOME/src/$basename/src" ]]; then
                  dst_src="$HOME/src/$basename/src/$handle"
            elif [[ -d "$HOME/src/$basename/cli" ]]; then
                  dst_src="$HOME/src/$basename/cli/$handle"
            else
                  mkdir -p "$HOME/src/$basename/src"
                  dst_src="$HOME/src/$basename/src/$handle"
            fi
            dst_bin="$HOME/src/$basename/dist/$handle"
            dst_final="$HOME/bin/$handle"

            mkdir -p "$(dirname "$dst_src")" "$(dirname "$dst_bin")"

            if cmp -s "$filename" "$dst_src"; then
                  [[ "$DEBUG" = true ]] && echo "[DEBUG]: No changes Detected. Skipping..."
                  # printf "\r[\033[38;5;10m%s\033[39m] No changes Detected. Watching \033[0;32m%s\033[0m..." "$(date '+%H:%M:%S')" "$filename"
                  printf "\r\033[K[\033[38;5;10m%s\033[39m] No changes Detected. Watching \033[0;32m%scd\033[0m..." "$(date '+%H:%M:%S')" "$(basename "$filename")"

                  sleep 1
                  continue
            else
                  [[ "$DEBUG" = true ]] && echo "[$(date '+%H:%M:%S')] Changes detected. Syncing..."
                  cp "$filename" "$dst_src"
                  cp "$filename" "$dst_bin"
                  cp "$filename" "$dst_final"
                  chmod +x "$dst_src" "$dst_bin" "$dst_final"
                  echo "[$(date '+%H:%M:%S')] Updated $dst_final"
            fi

            sleep 1
      done
}

5772B520_57F5_433E_927E_031A8329C317 "$@"
