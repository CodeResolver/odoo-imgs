#!/bin/bash

# Script to fix common Odoo module icon display issues
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Fixing common icon display issues...${NC}"

# 1. Fix permissions on the image files
echo "Setting correct permissions on image files..."
chmod 644 static/description/icon.png
chmod 644 static/description/banner.png

# 2. Recreate icon with correct format using PIL with RGBA mode (support transparency)
echo "Recreating icon with proper format and transparency..."
poetry run python3 -c '
import sys
try:
    from PIL import Image, ImageDraw, ImageFont
    
    # Create a higher quality icon with RGBA mode (supports transparency)
    icon = Image.new("RGBA", (140, 140), color=(255, 255, 255, 0))  # Transparent background
    draw = ImageDraw.Draw(icon)
    
    # Draw a solid circle as background
    draw.ellipse([(10, 10), (130, 130)], fill=(41, 128, 185, 255))
    
    # Draw a lighter inner circle
    draw.ellipse([(25, 25), (115, 115)], fill=(52, 152, 219, 255))
    
    # Add text
    try:
        # Try to use a nice font if available
        font = ImageFont.truetype("Arial", 36)
        draw.text((45, 55), "PIE", fill=(255, 255, 255, 255), font=font)
    except Exception:
        # Fallback to default font
        draw.text((45, 55), "PIE", fill=(255, 255, 255, 255))
    
    # Save with correct format
    icon.save("static/description/icon.png", "PNG")
    print("✅ Successfully created icon with transparency!")
except Exception as e:
    print(f"❌ Error creating image: {e}")
'

# 3. Clear Odoo cache in container
echo "Clearing Odoo cache inside container..."
docker-compose exec odoo sh -c '
    rm -rf /var/lib/odoo/.local/share/Odoo/filestore/*/ir/attachment/data/*
    find /var/lib/odoo/.local/share/Odoo/sessions -type f -delete
    echo "Odoo cache cleared."
'

# 4. Ensure the module directory name is consistent
module_dir="product_image_export"
current_dir=$(basename $(pwd))

echo "Checking module directory name..."
if [ "$current_dir" != "$module_dir" ] && [ "$current_dir" = "odoo-imgs" ]; then
    echo -e "${YELLOW}Warning: Current directory name ($current_dir) doesn't match expected module name ($module_dir).${NC}"
    echo "This can cause module identification issues in Odoo."
    echo "Consider renaming the directory or updating docker-compose.yml volume paths."
else
    echo -e "${GREEN}✓ Module directory name is correct or handled in configuration.${NC}"
fi

# 5. Verify manifest icon path
manifest_path="__manifest__.py"
if grep -q "'icon': 'static/description/icon.png'" "$manifest_path"; then
    echo -e "${GREEN}✓ Icon path in __manifest__.py is correct.${NC}"
else
    echo -e "${YELLOW}Updating icon path in __manifest__.py...${NC}"
    sed -i.bak "s/'icon':\s*'[^']*'/'icon': 'static\/description\/icon.png'/g" "$manifest_path" || \
    sed -i "s/'icon':\s*'[^']*'/'icon': 'static\/description\/icon.png'/g" "$manifest_path"
    echo -e "${GREEN}✓ Updated icon path in __manifest__.py${NC}"
fi

# 6. Restart Odoo and update module
echo "Restarting Odoo and updating module..."
docker-compose restart odoo
sleep 5  # Give Odoo time to restart

echo "Updating module in Odoo..."
docker-compose exec -T odoo python3 /usr/bin/odoo -u product_image_export --stop-after-init || \
echo -e "${RED}Failed to update module. Please try manually with './docker_dev.sh update product_image_export'${NC}"

echo -e "\n${GREEN}Fixes applied!${NC}"
echo "Please try these additional steps if the icon still appears broken:"
echo "1. Clear your browser cache completely or try in an incognito/private window"
echo "2. Access the module page and refresh several times"
echo "3. Try a different browser"
echo "4. Verify the module is properly installed and appears in Apps"
echo ""
echo "Check that the icon is available at this URL once Odoo is running:"
echo "http://localhost:8069/web/image/ir.module.module/product_image_export/icon"