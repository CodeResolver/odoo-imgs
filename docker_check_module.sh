#!/bin/bash

echo "Checking if the module is detected by Odoo..."
docker-compose exec odoo python3 -c "
import odoo
from odoo.service.db import list_dbs
from odoo.modules.module import get_modules
from odoo.addons.base.models.ir_module import Module

print('Available databases:', list_dbs())
print('\\nDetected modules in addons paths:')
modules = get_modules()
print('\\n'.join(modules))

# Check if our module is detected with the correct name
if 'product_image_export' in modules:
    print('\\n✓ Module \"product_image_export\" is detected!')
else:
    print('\\n✗ Module \"product_image_export\" is NOT detected!')
    
# List addons paths
print('\\nAddons paths:')
odoo_conf = odoo.tools.config
print(odoo_conf['addons_path'])
"

echo -e "\n\nFollow these steps to install the module:"
echo "1. Go to Apps menu (make sure the app filter is removed)"
echo "2. Click on 'Update Apps List' from the dropdown menu at top-left"
echo "3. Search for 'Product Image Export'"
echo "4. Click Install"
