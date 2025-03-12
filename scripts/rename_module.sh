#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Renaming module from odoo-imgs to product_image_export...${NC}"

# Stop Docker containers if running
if docker-compose ps | grep -q "odoo"; then
    echo "Stopping Docker containers..."
    docker-compose down
fi

# Create the new directory structure if it doesn't exist
mkdir -p /tmp/product_image_export

# Copy files to the new structure
echo "Copying files to the new module structure..."
cp -r . /tmp/product_image_export/

# Update any references in files
echo "Updating module references in files..."
find /tmp/product_image_export -type f -name "*.py" -o -name "*.xml" | xargs sed -i '' 's/odoo-imgs/product_image_export/g'
find /tmp/product_image_export -type f -name "*.py" -o -name "*.xml" | xargs sed -i '' 's/odoo_imgs/product_image_export/g'

# Move the module one directory up from the current directory
echo "Moving the new module directory..."
mv /tmp/product_image_export ..

echo -e "${GREEN}Module renamed! Please use the new directory at:${NC}"
echo -e "${GREEN}$(dirname $(pwd))/product_image_export${NC}"

echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. cd to the new directory"
echo "2. Run docker-compose up to start Odoo"
echo "3. Enable developer mode as described in developer_mode.md"
