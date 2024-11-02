#!/bin/bash

# Check if 'stow' is installed, and if not, install it using Homebrew
if ! command -v stow &>/dev/null; then
  echo "'stow' is not installed. Installing via Homebrew..."
  # Check if brew is installed, and if not, install Homebrew first
  if ! command -v brew &>/dev/null; then
    echo "'brew' is not installed. Installing Homebrew first..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  brew install stow
else
  echo "'stow' is already installed."
fi

# Iterate through each subdirectory in the current directory and run the stow command
for folder in */; do
  # Remove trailing slash to get folder name
  folder_name="${folder%/}"

  # Skip the 'inspodots' folder
  if [ "$folder_name" == "inspodots" ]; then
    echo "Skipping: $folder_name"
    continue
  fi

  echo "Running: stow $folder_name -t ~"
  stow "$folder_name" -t ~
done
