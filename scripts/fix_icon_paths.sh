#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Fixing icon paths and ensuring icon file is correctly formatted...${NC}"

# 1. Fix paths in manifest file
echo "Updating paths in __manifest__.py..."
sed -i.bak 's|"icon": "static/description/icon.png"|"icon": "/product_image_export/static/description/icon.png"|g' __manifest__.py
sed -i.bak 's|"images": \["static/description/banner.png"\]|"images": ["/product_image_export/static/description/banner.png"]|g' __manifest__.py
rm -f __manifest__.py.bak

# 2. Ensure icon has correct permissions
echo "Setting correct permissions for icon files..."
chmod 644 static/description/icon.png
chmod 644 static/description/banner.png

# 3. Create a high-quality icon with PIL
echo "Creating a high-quality icon with proper format..."
python3 -c '
import os
try:
    from PIL import Image, ImageDraw, ImageFont, ImageOps
    
    # Create directories if needed
    os.makedirs("static/description", exist_ok=True)
    
    # Create a new image with RGBA mode (supports transparency)
    icon = Image.new("RGBA", (140, 140), (255, 255, 255, 0))
    draw = ImageDraw.Draw(icon)
    
    # Draw a colored circle background
    draw.ellipse([(10, 10), (130, 130)], fill=(41, 128, 185, 255))
    
    # Add text - "PIE" centered
    try:
        # Try to get a standard font
        font_size = 48
        try:
            # First try Arial which is common on many systems
            font = ImageFont.truetype("Arial", font_size)
        except:
            # Fallback to DejaVuSans which is common on Linux
            font = ImageFont.truetype("DejaVuSans", font_size)
        
        # Calculate text size for centering
        text = "PIE"
        text_width = draw.textlength(text, font=font)  
        text_position = ((140 - text_width) / 2, 40)
        
        # Draw white text
        draw.text(text_position, text, font=font, fill=(255, 255, 255, 255))
    except Exception as e:
        # Fallback if font loading fails
        print(f"Font error: {e}, using simple text")
        draw.text((45, 50), "PIE", fill=(255, 255, 255, 255))
    
    # Ensure icon directory exists
    os.makedirs("static/description", exist_ok=True)
    
    # Save as PNG with transparency
    icon.save("static/description/icon.png", "PNG")
    print("Icon created successfully")
    
    # Create a matching banner
    banner = Image.new("RGBA", (560, 280), (255, 255, 255, 0))
    draw = ImageDraw.Draw(banner)
    
    # Draw a colored background
    draw.rectangle([(0, 0), (560, 280)], fill=(41, 128, 185, 255))
    
    # Add text
    try:
        font_size = 36
        try:
            font = ImageFont.truetype("Arial", font_size)
        except:
            font = ImageFont.truetype("DejaVuSans", font_size)
            
        text = "Product Image Export"
        text_width = draw.textlength(text, font=font)
        text_position = ((560 - text_width) / 2, 120)
        draw.text(text_position, text, font=font, fill=(255, 255, 255, 255))
    except:
        draw.text((180, 120), "Product Image Export", fill=(255, 255, 255, 255))
    
    banner.save("static/description/banner.png", "PNG")
    print("Banner created successfully")
    
except ImportError as e:
    print(f"Error: {e}. Please install PIL/Pillow with: pip install Pillow")
except Exception as e:
    print(f"Error creating icon: {e}")
'

# 4. Restart Odoo to apply changes
echo -e "${YELLOW}Restarting Odoo to apply changes...${NC}"
docker-compose restart odoo

# 5. Update the module
echo -e "${YELLOW}Updating module...${NC}"
docker-compose exec odoo python3 /usr/bin/odoo -u product_image_export --stop-after-init || echo -e "${RED}Failed to update module${NC}"

# 6. Verify icon is accessible
echo -e "${GREEN}Icon fix applied!${NC}"
echo "Please update the module in Odoo and refresh your browser."
echo ""
echo "If the icon still appears broken:"
echo "1. Clear your browser cache or use an incognito/private window"
echo "2. Run './verify_icon.py' to test icon accessibility"
echo "3. Check the Odoo logs for any errors: ./docker_dev.sh logs"
