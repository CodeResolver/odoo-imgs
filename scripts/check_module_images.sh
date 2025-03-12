#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Checking module icon and banner...${NC}"

# Check if the image files exist locally
ICON_PATH="static/description/icon.png"
BANNER_PATH="static/description/banner.png"

if [ -f "$ICON_PATH" ]; then
    echo -e "${GREEN}✓ Icon file exists locally at $ICON_PATH${NC}"
    echo -e "  Size: $(wc -c < "$ICON_PATH") bytes"
    echo -e "  Last modified: $(date -r "$ICON_PATH")"
else
    echo -e "${RED}✗ Icon file is missing! It should be at $ICON_PATH${NC}"
    echo -e "  Please create the icon file by running ./resize_images.py"
fi

if [ -f "$BANNER_PATH" ]; then
    echo -e "${GREEN}✓ Banner file exists locally at $BANNER_PATH${NC}"
    echo -e "  Size: $(wc -c < "$BANNER_PATH") bytes"
    echo -e "  Last modified: $(date -r "$BANNER_PATH")"
else
    echo -e "${RED}✗ Banner file is missing! It should be at $BANNER_PATH${NC}"
    echo -e "  Please create the banner file by running ./resize_images.py"
fi

# Create directories if they don't exist
mkdir -p static/description

# If images are missing, create sample ones
if [ ! -f "$ICON_PATH" ] || [ ! -f "$BANNER_PATH" ]; then
    echo -e "${YELLOW}Would you like to create sample placeholder images? (y/n)${NC}"
    read -r choice
    if [[ $choice == "y" ]]; then
        echo -e "${YELLOW}Creating sample images...${NC}"
        
        # Check if convert (ImageMagick) is installed
        if command -v convert &> /dev/null; then
            # Create a simple icon with text
            convert -size 140x140 xc:navy -fill white -gravity center \
                -font Arial -pointsize 20 -annotate 0 "Product\nImage\nExport" \
                "$ICON_PATH"
            
            # Create a simple banner with text
            convert -size 560x280 xc:royalblue -fill white -gravity center \
                -font Arial -pointsize 36 -annotate 0 "Product Image Export Module" \
                "$BANNER_PATH"
            
            echo -e "${GREEN}✓ Sample images created successfully!${NC}"
        else
            echo -e "${RED}ImageMagick not found. Using Python to create simple images...${NC}"
            python3 -c '
import sys
try:
    from PIL import Image, ImageDraw, ImageFont
    # Create icon
    img = Image.new("RGB", (140, 140), color="blue")
    draw = ImageDraw.Draw(img)
    draw.text((70, 70), "PIE", fill="white", anchor="mm")
    img.save("'$ICON_PATH'")
    # Create banner
    img = Image.new("RGB", (560, 280), color="royalblue")
    draw = ImageDraw.Draw(img)
    draw.text((280, 140), "Product Image Export Module", fill="white", anchor="mm")
    img.save("'$BANNER_PATH'")
    print("Images created with Python!")
except ImportError:
    print("PIL not available. Creating empty files.")
    open("'$ICON_PATH'", "wb").write(b"PNG placeholder")
    open("'$BANNER_PATH'", "wb").write(b"PNG placeholder")
'
        fi
    fi
fi

# Check if Docker is running
if ! docker ps &>/dev/null; then
    echo -e "${RED}Docker is not running. Cannot check container accessibility.${NC}"
    exit 1
fi

# Check if Odoo container is running
if ! docker-compose ps | grep -q "odoo.*Up"; then
    echo -e "${RED}Odoo container is not running. Cannot check container accessibility.${NC}"
    exit 1
fi

echo -e "\n${YELLOW}Checking image accessibility from Odoo container...${NC}"

# Check if the images are accessible in the container
docker-compose exec odoo sh -c "
if [ -f /mnt/extra-addons/product_image_export/$ICON_PATH ]; then
    echo -e \"\033[0;32m✓ Icon is accessible in the container\033[0m\"
    ls -la /mnt/extra-addons/product_image_export/$ICON_PATH
else
    echo -e \"\033[0;31m✗ Icon is NOT accessible in the container at /mnt/extra-addons/product_image_export/$ICON_PATH\033[0m\"
fi

if [ -f /mnt/extra-addons/product_image_export/$BANNER_PATH ]; then
    echo -e \"\033[0;32m✓ Banner is accessible in the container\033[0m\"
    ls -la /mnt/extra-addons/product_image_export/$BANNER_PATH
else
    echo -e \"\033[0;31m✗ Banner is NOT accessible in the container at /mnt/extra-addons/product_image_export/$BANNER_PATH\033[0m\"
fi
"

# Check manifest references
echo -e "\n${YELLOW}Checking manifest references to images...${NC}"
if grep -q "icon.*static/description/icon.png" __manifest__.py; then
    echo -e "${GREEN}✓ Icon is correctly referenced in __manifest__.py${NC}"
else
    echo -e "${RED}✗ Icon reference not found or incorrect in __manifest__.py${NC}"
fi

if grep -q "images.*static/description/banner.png" __manifest__.py; then
    echo -e "${GREEN}✓ Banner is correctly referenced in __manifest__.py${NC}"
else
    echo -e "${RED}✗ Banner reference not found or incorrect in __manifest__.py${NC}"
fi

echo -e "\n${YELLOW}Checking Odoo module registry...${NC}"
# Check if the module is properly registered in Odoo
docker-compose exec odoo python3 -c "
import sys
try:
    import odoo
    registry = odoo.registry('odoo')
    with registry.cursor() as cr:
        env = odoo.api.Environment(cr, 1, {})
        module = env['ir.module.module'].search([('name', '=', 'product_image_export')], limit=1)
        if module:
            print(f'\033[0;32m✓ Module found in Odoo registry: {module.name} (state: {module.state})\033[0m')
            if module.icon:
                print(f'\033[0;32m✓ Module has an icon set: {module.icon}\033[0m')
            else:
                print(f'\033[0;31m✗ Module does not have an icon set\033[0m')
        else:
            print('\033[0;31m✗ Module not found in Odoo registry\033[0m')
except Exception as e:
    print(f'\033[0;31mError checking module registry: {e}\033[0m')
    sys.exit(1)
"

echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. If images are missing, run: ./resize_images.py"
echo "2. Restart Odoo: ./docker_dev.sh restart"
echo "3. Update the module: ./docker_dev.sh update product_image_export"
echo "4. Clear browser cache and refresh the page"
