#!/usr/bin/env python3
"""
Simple script to generate placeholder module icon and banner
"""
import os
try:
    from PIL import Image, ImageDraw, ImageFont
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False

def create_placeholder_images():
    """Create placeholder images for the module icon and banner"""
    # Create directories if they don't exist
    os.makedirs("static/description", exist_ok=True)
    
    icon_path = "static/description/icon.png"
    banner_path = "static/description/banner.png"
    
    # Skip if files already exist
    if os.path.exists(icon_path) and os.path.exists(banner_path):
        print(f"Images already exist at {icon_path} and {banner_path}")
        return
    
    if not PIL_AVAILABLE:
        print("PIL/Pillow not available. Creating empty image files.")
        # Create empty files as placeholders
        with open(icon_path, "wb") as f:
            f.write(b"PNG placeholder")
        with open(banner_path, "wb") as f:
            f.write(b"PNG placeholder")
        return
    
    # Create icon (140x140)
    icon = Image.new("RGB", (140, 140), color=(0, 0, 128))  # Navy blue
    draw = ImageDraw.Draw(icon)
    # Add text to icon (simpler version without font)
    draw.text((70, 70), "PIE", fill="white")
    icon.save(icon_path)
    print(f"Created icon at {icon_path}")
    
    # Create banner (560x280)
    banner = Image.new("RGB", (560, 280), color=(65, 105, 225))  # Royal blue
    draw = ImageDraw.Draw(banner)
    # Add text to banner
    draw.text((280, 140), "Product Image Export Module", fill="white")
    banner.save(banner_path)
    print(f"Created banner at {banner_path}")

if __name__ == "__main__":
    create_placeholder_images()
