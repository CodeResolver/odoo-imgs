#!/bin/bash

# Make all shell scripts executable
echo "Making all shell scripts executable..."

# List of shell scripts to make executable
SCRIPTS=(
  "docker_dev.sh"
  "setup_dev.sh"
  "rename_module.sh"
  "debug_module.sh"
  "check_module_images.sh"
  "fix_icon.sh"
  "find_name_inconsistencies.sh"
  "resize.sh"
  "force_update_module.py"
  "generate_images.py"
  "resize_images.py"
)

# Make each script executable
for script in "${SCRIPTS[@]}"; do
  if [ -f "$script" ]; then
    chmod +x "$script"
    echo "✅ Made $script executable"
  else
    echo "❌ $script not found"
  fi
done

echo "Done making scripts executable!"
echo "You can now run any of these scripts directly, e.g.:"
echo "./fix_icon.sh"
echo "./docker_dev.sh update product_image_export"
