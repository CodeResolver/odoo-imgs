#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Testing public image URL access...${NC}"

# Get base URL from Odoo config
BASE_URL=$(docker-compose exec odoo python3 -c "
import odoo
from odoo import SUPERUSER_ID
from odoo.api import Environment
try:
    # Get first available database
    from odoo.service.db import list_dbs
    dbs = list_dbs()
    if not dbs:
        print('ERROR: No databases available')
        exit(1)
    
    db_name = dbs[0]
    registry = odoo.registry(db_name)
    
    with registry.cursor() as cr:
        env = Environment(cr, SUPERUSER_ID, {})
        base_url = env['ir.config_parameter'].get_param('web.base.url')
        print(base_url)
except Exception as e:
    print(f'ERROR: {e}')
    exit(1)
")

if [[ $BASE_URL == ERROR* ]]; then
    echo -e "${RED}$BASE_URL${NC}"
    exit 1
fi

echo -e "Base URL: ${GREEN}$BASE_URL${NC}"

# Get a sample public image URL
IMAGE_URL=$(docker-compose exec odoo python3 -c "
import odoo
from odoo import SUPERUSER_ID
from odoo.api import Environment
try:
    # Get first available database
    from odoo.service.db import list_dbs
    dbs = list_dbs()
    if not dbs:
        print('ERROR: No databases available')
        exit(1)
    
    db_name = dbs[0]
    registry = odoo.registry(db_name)
    
    with registry.cursor() as cr:
        env = Environment(cr, SUPERUSER_ID, {})
        
        # Enable auto-public URLs
        env['ir.config_parameter'].set_param('product_image_export.auto_public_urls', 'True')
        
        # Find a product with an image
        product = env['product.template'].search([('image_1920', '!=', False)], limit=1)
        if not product:
            print('ERROR: No products with images found')
            exit(1)
        
        # Force recompute the URL
        product._compute_image_url()
        
        # Get the URL
        if product.image_url:
            print(product.image_url)
        else:
            print('ERROR: No image URL generated')
except Exception as e:
    print(f'ERROR: {e}')
    exit(1)
")

if [[ $IMAGE_URL == ERROR* ]]; then
    echo -e "${RED}$IMAGE_URL${NC}"
    exit 1
fi

echo -e "Image URL: ${GREEN}$IMAGE_URL${NC}"

# Try to access the image URL without authentication
echo -e "\nTesting access to the image URL..."
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$IMAGE_URL")

if [[ $STATUS_CODE == 200 ]]; then
    echo -e "${GREEN}✓ Image is publicly accessible (HTTP $STATUS_CODE)${NC}"
else
    echo -e "${RED}✗ Image is NOT publicly accessible (HTTP $STATUS_CODE)${NC}"
    echo -e "This means the public URLs are not working correctly."
fi

echo -e "\n${YELLOW}To fix public access issues:${NC}"
echo "1. Check that your Odoo instance is correctly configured with proper domain"
echo "2. Verify that 'Public Image URLs by Default' is enabled in settings"
echo "3. Make sure your firewall allows access to the Odoo server"
echo "4. If using a reverse proxy, ensure it's correctly forwarding requests"

echo -e "\n${YELLOW}To manually enable public URLs:${NC}"
echo "Go to Settings > General Settings > Product Image Export and enable 'Public Image URLs by Default'"
