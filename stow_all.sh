#!/bin/bash

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
