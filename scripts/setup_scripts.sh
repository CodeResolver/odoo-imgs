#!/bin/bash

# Script to move all utility scripts to the scripts directory
echo "Moving utility scripts for Product Image Export module to scripts directory..."

# Create scripts directory if it doesn't exist
mkdir -p scripts

# List of scripts to move
SCRIPTS=(
  "docker_dev.sh"
  "setup_dev.sh"
  "rename_module.sh"
  "debug_module.sh"
  "check_module_images.sh"
  "fix_icon.sh"
  "fix_icon_paths.sh"
  "find_name_inconsistencies.sh"
  "resize.sh"
  "force_update_module.py"
  "generate_images.py"
  "resize_images.py"
  "verify_icon.py"
  "make_executable.sh"
)

# Move each script to scripts directory if it exists in root
for script in "${SCRIPTS[@]}"; do
  if [ -f "$script" ]; then
    echo "Moving $script to scripts directory"
    mv "$script" scripts/
  else
    echo "$script not found in root directory"
  fi
done

# Make utility script executable
chmod +x odoo-tools

echo "Script setup complete!"
echo "Now you can use './odoo-tools help' to see available commands"
