#!/bin/bash
#shellcheck shell=bash

DEBUG=false

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

      # Parse arguments for debug and environment flags
      ENV=""
      # Parse debug flags more precisely to avoid conflicts with --dev
      for arg in "$@"; do
            if [[ $arg == "-d" || $arg == "-debug" || $arg == "--debug" || $arg == "-verbose" || $arg == "--v" || $arg == "--verbose" ]]; then
                  DEBUG=true
                  break
            fi
      done

      # Parse environment argument and filter out non-positional arguments
      filtered_args=()
      for arg in "$@"; do
            if [[ $arg == --env=* ]]; then
                  ENV="${arg#*=}"
            elif [[ $arg == -e=* ]]; then
                  ENV="${arg#*=}"
            elif [[ $arg == --dev ]]; then
                  ENV="dev"
            elif [[ $arg == --prod ]]; then
                  ENV="prod"
            elif [[ $arg == "-p" ]]; then
                  ENV="prod"
            elif [[ $arg == "-d" ]]; then
                  ENV="dev"
            elif [[ $arg != "-d" && $arg != "-debug" && $arg != "--debug" && $arg != "-verbose" && $arg != "--v" && $arg != "--verbose" ]]; then
                  filtered_args+=("$arg")
            fi
      done

      # Normalize and validate ENV
      if [[ -z "$ENV" ]]; then
            echo "[INFO]: No --env flag specified. Using 'prod' by default."
            ENV="prod"
      elif [[ "$ENV" != "dev" && "$ENV" != "staging" && "$ENV" != "prod" ]]; then
            echo "[INFO]: Unknown environment '$ENV'. Defaulting to 'staging'."
            ENV="staging"
      fi

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

      # If first filtered argument is not provided, use current directory
      if [[ ${#filtered_args[@]} -eq 0 ]]; then
            source="$(pwd)"
      else
            source="${filtered_args[0]}"
      fi

      function usage() {
            cat <<EOF
update - Watch and sync a script to ~/bin as a command
      Usage: update [--env=<dev|staging|prod>|--dev|--prod|-d|-p] <folder-to-sync> [name-of-command]
      If run in a directory containing main.sh and no folder is specified, uses the current directory.
      Watches <folder-to-sync>/main.sh for changes and syncs it to:
            ~/src/<folder-to-sync>/src/<name-of-command>
            ~/src/<folder-to-sync>/dist/<env>.<name-of-command>
            ~/bin/<name-of-command>
      Arguments:
            --env=<env>          Environment to use: dev, staging, or prod (optional, defaults to prod)
            --dev, -d           Shortcut for --env=dev
            --prod, -p          Shortcut for --env=prod
            <folder-to-sync>     The folder containing main.sh to watch and sync.
            [name-of-command]    (Optional) The name for the command. Defaults to the folder name.
      Features:
            - Automatically copies main.sh when changes are detected.
            - Installs the script to ~/bin for easy access.
            - Press Ctrl+C to stop watching.
      Example:
            update --env=dev ~/my-scripts
            update --dev ~/my-scripts
            update -e=prod . mycmd
            update --prod . mycmd
            update ~/my-scripts
            update . mycmd
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
      # Get the actual directory name, handling current directory properly
      if [[ "$source" == "." ]]; then
            basename="$(basename "$(pwd)")"
      else
            basename="$(basename "$source")"
      fi
      handle="${filtered_args[1]:-$basename}"

      mkdir -p ~/src ~/bin

      if [[ "$ENV" == "prod" ]]; then
            if [[ ! -f "$filename" ]]; then
                  echo "File $filename does not exist. Exiting..."
                  exit 1
            fi

            [[ "$DEBUG" = true ]] && echo "[DEBUG]: filename=$filename" && echo "[DEBUG]: cmd=$handle"

            dst_bin="$HOME/src/$basename/dist/${ENV}.$handle"
            dst_final="$HOME/bin/$handle"

            mkdir -p "$(dirname "$dst_bin")"

            shc -f "$filename" -o "$dst_bin"
            cp "$dst_bin" "$dst_final"
            chmod +x "$dst_bin" "$dst_final"

            printf "\r\033[K[\033[38;5;10m%s\033[39m] Updated \033[0;32m%s\033[0m\n" "$(date '+%H:%M:%S')" "$dst_final"
            printf "\n[INFO]: Output file created at: \033[0;32m%s\033[0m\n" "$dst_final"
            exit 0
      fi

      while true; do
            if [[ ! -f "$filename" ]]; then
                  echo "File $filename does not exist. Exiting..."
                  exit 1
            fi

            [[ "$DEBUG" = true ]] && echo "[DEBUG]: filename=$filename" && echo "[DEBUG]: cmd=$handle"

            # Only use dist and bin directories for outputs
            dst_bin="$HOME/src/$basename/dist/${ENV}.$handle"
            dst_final="$HOME/bin/$handle"

            mkdir -p "$(dirname "$dst_bin")"

            # Check if source file changed OR if bin file doesn't match what it should be
            source_changed=false
            bin_needs_update=false

            if ! cmp -s "$filename" "$dst_bin"; then
                  source_changed=true
            fi

            # Check if bin file matches the expected dist file
            if ! cmp -s "$dst_bin" "$dst_final" 2>/dev/null; then
                  bin_needs_update=true
            fi

            if [[ "$source_changed" == false && "$bin_needs_update" == false ]]; then
                  [[ "$DEBUG" = true ]] && echo "[DEBUG]: No changes detected. Skipping..."
                  printf "\r\033[K[\033[38;5;10m%s\033[39m] No changes detected. Watching \033[0;32m%s\033[0m..." "$(date '+%H:%M:%S')" "$(basename "$filename")"
                  sleep 1
                  continue
            else
                  if [[ "$source_changed" == true && "$bin_needs_update" == true ]]; then
                        [[ "$DEBUG" = true ]] && echo "[$(date '+%H:%M:%S')] Source and bin files need updating. Syncing..."
                  elif [[ "$source_changed" == true ]]; then
                        [[ "$DEBUG" = true ]] && echo "[$(date '+%H:%M:%S')] Source file changed. Syncing..."
                  elif [[ "$bin_needs_update" == true ]]; then
                        [[ "$DEBUG" = true ]] && echo "[$(date '+%H:%M:%S')] Environment/bin mismatch detected. Syncing..."
                  fi

                  if [[ -f "$source/Cargo.toml" ]]; then
                        # Rust project detected
                        install_rust_cli "$source" "$handle" "$dst_bin" "$dst_final"
                  else
                        if [[ "$ENV" == "prod" ]]; then
                              shc -f "$filename" -o "$dst_bin"
                              cp "$dst_bin" "$dst_final"
                        else
                              cp "$filename" "$dst_bin"
                              cp "$filename" "$dst_final"
                        fi

                        chmod +x "$dst_bin" "$dst_final"
                  fi

                  printf "\r\033[K[\033[38;5;10m%s\033[39m] Updated \033[0;32m%s\033[0m\n" "$(date '+%H:%M:%S')" "$dst_final"
                  printf "\n[INFO]: Output file created at: \033[0;32m%s\033[0m\n" "$dst_final"
            fi

            sleep 1
      done
}

# Improved Rust CLI installer: detects binary name from Cargo.toml and manages output directories
function install_rust_cli() {
      local project_dir="$1"
      local handle="$2"
      local dst_bin="$3"
      local dst_final="$4"
      local bin_name="$handle"

      [[ "$DEBUG" = true ]] && echo "[DEBUG] Installing Rust CLI from $project_dir"

      # Create a custom output directory structure
      local custom_target_dir
      custom_target_dir="$HOME/src/$(basename "$project_dir")/dist/target"
      mkdir -p "$custom_target_dir"

      # Try to detect binary name from Cargo.toml if it exists
      if [[ -f "$project_dir/Cargo.toml" ]]; then
            # Look for [[bin]] sections first
            local bin_entries
            bin_entries=$(grep -A 5 '^\[\[bin\]\]' "$project_dir/Cargo.toml" 2>/dev/null | grep 'name *=' | head -n 1 | awk -F' *= *' '{gsub(/"/, "", $2); print $2}')

            # If no [[bin]] sections found, use the package name
            if [[ -z "$bin_entries" ]]; then
                  bin_name=$(awk -F' *= *' '/^name *=/ {gsub(/"/, "", $2); print $2; exit}' "$project_dir/Cargo.toml")
            else
                  bin_name="$bin_entries"
            fi

            [[ -z "$bin_name" ]] && bin_name="$handle"
            [[ "$DEBUG" = true ]] && echo "[DEBUG] Detected binary name: $bin_name"
      fi

      # Run cargo build with custom target directory
      (
            cd "$project_dir" || {
                  echo "[Rust] Could not cd to $project_dir"
                  exit 1
            }

            # Build with custom target directory
            CARGO_TARGET_DIR="$custom_target_dir" cargo build --release || {
                  echo "[Rust] cargo build failed"
                  exit 1
            }
      )

      # Try to find the binary in the custom target directory
      local bin_path="$custom_target_dir/release/$bin_name"

      # If binary not found in expected location, try to find it
      if [[ ! -f "$bin_path" ]]; then
            [[ "$DEBUG" = true ]] && echo "[DEBUG] Binary not found at expected path: $bin_path"
            # Search for executable files in the release directory
            local found_bins=()
            mapfile -t found_bins < <(find "$custom_target_dir/release" -type f -executable -not -path "*/deps/*" -not -path "*/examples/*" 2>/dev/null)

            if [[ ${#found_bins[@]} -eq 1 ]]; then
                  bin_path="${found_bins[0]}"
                  bin_name="$(basename "$bin_path")"
                  [[ "$DEBUG" = true ]] && echo "[DEBUG] Found single binary: $bin_path"
            elif [[ ${#found_bins[@]} -gt 1 ]]; then
                  echo "[Rust] Multiple binaries found, using $handle as the target"
                  for bin in "${found_bins[@]}"; do
                        if [[ "$(basename "$bin")" == "$handle" ]]; then
                              bin_path="$bin"
                              bin_name="$handle"
                              break
                        fi
                  done
                  # If specific binary not found, use the first one
                  if [[ ! -f "$bin_path" || "$bin_path" != *"$bin_name"* ]]; then
                        bin_path="${found_bins[0]}"
                        bin_name="$(basename "$bin_path")"
                  fi
                  [[ "$DEBUG" = true ]] && echo "[DEBUG] Selected binary: $bin_path"
            fi
      fi

      if [[ -f "$bin_path" ]]; then
            cp "$bin_path" "$dst_bin"
            cp "$bin_path" "$dst_final"
            chmod +x "$dst_bin" "$dst_final"
            echo "[Rust] Installed $bin_name to $dst_bin and $dst_final"
      else
            echo "[Rust] Build succeeded but binary not found"
            echo "[Rust] Searched in: $custom_target_dir/release"
            echo "[Rust] Expected binary name: $bin_name"
            echo "[Rust] Please check your Cargo.toml and project structure."
            exit 1
      fi
}

5772B520_57F5_433E_927E_031A8329C317 "$@"

# Checked 6/30/25
