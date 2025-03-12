#!/usr/bin/env python3
import os
import sys
import subprocess
import importlib.util

def is_in_poetry_env():
    """Check if we're running inside a Poetry environment"""
    return os.environ.get('POETRY_ACTIVE') == '1' or 'poetry' in sys.executable

def check_pillow_installed():
    """Check if Pillow is installed in the current Python environment"""
    return importlib.util.find_spec("PIL") is not None

def try_activate_poetry():
    """Attempt to run the script in the Poetry environment"""
    try:
        # Check if Poetry is available
        result = subprocess.run(["poetry", "--version"], 
                               stdout=subprocess.PIPE, 
                               stderr=subprocess.PIPE, 
                               text=True)
        
        # If we can run poetry command, try to execute this script inside Poetry environment
        if result.returncode == 0:
            print("\nAttempting to run this script inside Poetry environment...")
            
            # Get the script's path
            script_path = os.path.abspath(__file__)
            
            # Run the script with Poetry
            cmd = ["poetry", "run", "python", script_path]
            os.execvp("poetry", cmd)  # Replace current process
            
        return False
    except (subprocess.SubprocessError, FileNotFoundError):
        return False

def install_pillow():
    """Install Pillow in the current environment"""
    try:
        print("Installing Pillow directly in the current environment...")
        subprocess.run([sys.executable, "-m", "pip", "install", "Pillow"], check=True)
        return True
    except subprocess.SubprocessError as e:
        print(f"Failed to install Pillow: {e}")
        return False

def show_installation_instructions():
    """Display detailed installation instructions."""
    print("\n========== INSTALLATION INSTRUCTIONS ==========")
    print("\nPillow is needed but couldn't be imported. Try these steps:")
    print("\n1. Use Poetry (recommended):")
    print("   poetry shell")
    print("   python resize_images.py")
    print("\n2. Or install Pillow directly:")
    print(f"   {sys.executable} -m pip install Pillow")
    print("\n3. If you're having issues with Poetry:")
    print("   poetry install")
    print("   poetry update pillow")
    print("\n4. Alternatively, open a new terminal window and run:")
    print("   cd", os.getcwd())
    print("   poetry shell")
    print("   python resize_images.py")
    print("\n==============================================")

def resize_image(input_path, output_path, size):
    """Resize an image to the specified size."""
    try:
        from PIL import Image
        with Image.open(input_path) as img:
            # Convert to RGB mode if it's not already (e.g., for PNGs with transparency)
            if img.mode != 'RGB':
                img = img.convert('RGB')
            
            # Resize the image
            resized_img = img.resize(size, Image.LANCZOS)
            
            # Save the resized image
            resized_img.save(output_path, quality=95)
            print(f"Successfully resized {input_path} to {size[0]}x{size[1]} pixels at {output_path}")
            return True
    except Exception as e:
        print(f"Error resizing {input_path}: {e}")
        return False

def main():
    # Try to import PIL
    try:
        from PIL import Image
        print("Pillow is already installed and working. Continuing...")
    except ImportError:
        print("ERROR: Cannot import PIL/Pillow module.")
        
        # If we're not in a Poetry environment, try to activate it
        if not is_in_poetry_env():
            if try_activate_poetry():
                # If successful, this script will restart in the Poetry environment
                return
            
        # Try to install Pillow directly
        if install_pillow():
            try:
                from PIL import Image
                print("Pillow installed and imported successfully!")
            except ImportError:
                show_installation_instructions()
                return
        else:
            show_installation_instructions()
            return
    
    # Create the directory if it doesn't exist
    description_dir = os.path.join('static', 'description')
    if not os.path.exists(description_dir):
        print(f"Creating directory {description_dir}")
        os.makedirs(description_dir, exist_ok=True)
    
    # Define the required sizes
    icon_size = (140, 140)
    banner_size = (560, 280)
    
    # List all files in the directory
    files = os.listdir(description_dir)
    
    # Check for existing icon.png and banner.png
    icon_exists = 'icon.png' in files
    banner_exists = 'banner.png' in files
    
    if icon_exists and banner_exists:
        print("\nNotice: Both icon.png and banner.png already exist in the static/description directory.")
        choice = input("Do you want to use them as is (y) or create new ones (n)? [y/n]: ").strip().lower()
        if choice == 'y':
            print("\nKeeping existing icon.png and banner.png files.")
            print("Module icons are ready to use!")
            return
    elif icon_exists:
        print("\nNotice: icon.png already exists in the static/description directory.")
    elif banner_exists:
        print("\nNotice: banner.png already exists in the static/description directory.")
    
    # Find all potential source images, including existing icon.png and banner.png
    source_images = [f for f in files if f.lower().endswith(('.png', '.jpg', '.jpeg'))]
    
    if not source_images:
        print("No source images found in the static/description directory.")
        print("Please add image files to resize.")
        return
        
    print("Found these images that could be used as source:")
    for i, img in enumerate(source_images):
        suffix = ""
        if img == "icon.png":
            suffix = " (current icon)"
        elif img == "banner.png":
            suffix = " (current banner)"
        print(f"{i+1}. {img}{suffix}")
    
    # Ask which image to use for icon and banner
    try:
        icon_choice = int(input("\nSelect image number to use for icon (140x140): ")) - 1
        banner_choice = int(input("Select image number to use for banner (560x280): ")) - 1
        
        if 0 <= icon_choice < len(source_images) and 0 <= banner_choice < len(source_images):
            icon_source = os.path.join(description_dir, source_images[icon_choice])
            banner_source = os.path.join(description_dir, source_images[banner_choice])
            
            icon_output = os.path.join(description_dir, 'icon.png')
            banner_output = os.path.join(description_dir, 'banner.png')
            
            # When source is the same as output, make a copy first
            if source_images[icon_choice] == 'icon.png':
                print("Using existing icon.png as source. Backing up first...")
                from shutil import copy2
                copy2(icon_source, os.path.join(description_dir, 'icon.png.bak'))
            
            if source_images[banner_choice] == 'banner.png':
                print("Using existing banner.png as source. Backing up first...")
                from shutil import copy2
                copy2(banner_source, os.path.join(description_dir, 'banner.png.bak'))
            
            # Resize images
            resize_image(icon_source, icon_output, icon_size)
            resize_image(banner_source, banner_output, banner_size)
            
            print("\nResizing complete!")
            print("The icon and banner are now ready for your Odoo module.")
        else:
            print("Invalid selection.")
    except (ValueError, IndexError):
        print("Invalid input. Please run the script again and enter valid numbers.")
        
if __name__ == "__main__":
    main()
