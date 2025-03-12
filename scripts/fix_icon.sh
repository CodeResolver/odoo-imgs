#!/bin/bash

echo "Fixing the module icon..."

# Create directory structure if needed
mkdir -p static/description

# Generate a proper icon using Python/PIL
python3 -c '
import sys
try:
    from PIL import Image, ImageDraw, ImageFont
    
    # Create icon with proper format (140x140)
    icon = Image.new("RGB", (140, 140), color=(41, 128, 185))  # Blue color
    draw = ImageDraw.Draw(icon)
    
    # Draw a circular background
    draw.ellipse([(20, 20), (120, 120)], fill=(255, 255, 255))
    
    # Add text for the icon - PIE (Product Image Export)
    text_position = (70, 70)
    draw.text((text_position[0]-20, text_position[1]-10), "PIE", fill=(41, 128, 185), align="center")
    
    # Save with correct format
    icon.save("static/description/icon.png", "PNG")
    print("✅ Successfully created icon!")
    
    # Create banner (560x280)
    banner = Image.new("RGB", (560, 280), color=(41, 128, 185))
    draw = ImageDraw.Draw(banner)
    
    # Add text
    draw.text((280, 140), "Product Image Export", fill="white")
    
    # Save banner
    banner.save("static/description/banner.png", "PNG")
    print("✅ Successfully created banner!")
    
except ImportError:
    print("❌ Error: PIL/Pillow is not installed! Please install it with:")
    print("   pip install Pillow")
    sys.exit(1)
except Exception as e:
    print(f"❌ Error creating images: {e}")
    sys.exit(1)
'

# Make the generated files accessible inside the container
echo "Restarting the Docker container to apply changes..."
docker-compose restart odoo

echo "✅ Done! The icon should now be fixed."
echo "Please update the module and refresh your Odoo instance:"
echo "  ./docker_dev.sh update product_image_export"
echo ""
echo "If the icon still appears broken, check the icon format with:"
echo "  file static/description/icon.png"
echo "It should be a PNG file with dimensions 140x140"
