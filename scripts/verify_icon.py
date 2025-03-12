#!/usr/bin/env python3
"""
Script to verify that the module icon is accessible via HTTP
"""
import sys
import os
import subprocess
import urllib.request

def get_base_url():
    """Get the Odoo base URL from running container"""
    try:
        # Try to get the configuration from Odoo
        result = subprocess.run(
            ["docker-compose", "exec", "-T", "odoo", "python3", "-c", 
             "from odoo.tools import config; print(config.get('http_interface', '127.0.0.1')); print(config.get('http_port', 8069))"],
            capture_output=True, text=True, check=True
        )
        
        # Parse the output - expecting two lines now
        lines = result.stdout.strip().split('\n')
        if len(lines) >= 2:
            interface, port = lines[0], lines[1]
        else:
            # Fallback if the format isn't as expected
            print("Warning: Couldn't parse Odoo configuration properly")
            interface, port = '127.0.0.1', '8069'
            
        if interface == '0.0.0.0':
            interface = '127.0.0.1'
            
        return f"http://{interface}:{port}"
    except subprocess.CalledProcessError:
        print("Warning: Couldn't get Odoo configuration, using default")
        return "http://localhost:8069"

def check_url(url):
    """Check if a URL is accessible using standard library (no requests)"""
    try:
        print(f"Checking URL: {url}")
        response = urllib.request.urlopen(url, timeout=5)
        if response.status == 200:
            headers = response.info()
            content_length = headers.get('Content-Length', 'unknown')
            content_type = headers.get('Content-Type', 'unknown')
            print(f"✅ Success! Icon accessible at: {url}")
            print(f"   Content-Type: {content_type}")
            print(f"   Content-Length: {content_length} bytes")
            return True
        else:
            print(f"❌ Failed with status code: {response.status}")
            return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    base_url = get_base_url()
    
    print(f"Checking icon accessibility at {base_url}...")
    
    # Check different possible icon URLs
    urls_to_check = [
        f"{base_url}/product_image_export/static/description/icon.png",
        f"{base_url}/web/image/ir.module.module/product_image_export/icon",
        f"{base_url}/web/image?model=ir.module.module&field=icon&id=product_image_export",
        f"{base_url}/web/static/description/icon.png",
    ]
    
    success = False
    for url in urls_to_check:
        if check_url(url):
            success = True
            break
    
    if not success:
        print("\nNone of the URLs were accessible. Trying direct file check...")
        
        # Check if the file exists and has content
        icon_path = "static/description/icon.png"
        if os.path.exists(icon_path):
            size = os.path.getsize(icon_path)
            print(f"✅ Icon file exists locally: {icon_path}")
            print(f"   Size: {size} bytes")
            
            # Check permissions
            import stat
            mode = os.stat(icon_path).st_mode
            if mode & (stat.S_IRGRP | stat.S_IROTH):
                print("✅ File is readable by others")
            else:
                print("⚠️  Warning: File might not have correct permissions")
                print("   Run: chmod 644 static/description/icon.png")
        else:
            print(f"❌ Icon file not found: {icon_path}")
    
    print("\nTroubleshooting steps:")
    print("1. Make sure static/description/icon.png exists and is a valid PNG file")
    print("2. Make sure the module is properly installed and updated")
    print("3. Try clearing your browser cache or use an incognito window")
    print("4. Restart the Odoo server with: ./docker_dev.sh restart")
    print("5. Update the module with: ./docker_dev.sh update product_image_export")
    print("6. Check Docker logs for errors: docker-compose logs odoo")

if __name__ == "__main__":
    main()
