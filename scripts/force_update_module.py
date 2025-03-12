#!/usr/bin/env python3
"""
Script to force update Product Image Export module in Odoo via RPC.
Ensures the field is registered properly.
"""
import xmlrpc.client
import sys
import argparse
import getpass

def main():
    parser = argparse.ArgumentParser(description='Force update Product Image Export module')
    parser.add_argument('--url', default='http://localhost:8069', help='Odoo URL')
    parser.add_argument('--db', default='odoo', help='Database name')
    parser.add_argument('--user', default='admin', help='User login')
    parser.add_argument('--module', default='product_image_export', help='Module technical name')
    
    args = parser.parse_args()
    
    # Ask for password
    password = getpass.getpass('Password for %s@%s: ' % (args.user, args.url))
    
    print(f"Connecting to Odoo at {args.url}...")
    
    # Connect to Odoo
    common = xmlrpc.client.ServerProxy('{}/xmlrpc/2/common'.format(args.url))
    uid = common.authenticate(args.db, args.user, password, {})
    
    if not uid:
        print("Authentication failed! Check your credentials.")
        sys.exit(1)
    
    print(f"Authentication successful (uid: {uid})")
    
    # Connect to object endpoint
    models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(args.url))
    
    # Check if module exists
    module_ids = models.execute_kw(args.db, uid, password,
        'ir.module.module', 'search', [[('name', '=', args.module)]])
    
    if not module_ids:
        print(f"Module '{args.module}' not found!")
        sys.exit(1)
    
    module_id = module_ids[0]
    
    # Get module state
    module_data = models.execute_kw(args.db, uid, password,
        'ir.module.module', 'read', [module_id], {'fields': ['state']})
    
    module_state = module_data[0]['state']
    print(f"Module '{args.module}' found with state: {module_state}")
    
    # Check if module is installed and update it
    if module_state in ['installed', 'to upgrade']:
        print("Updating module...")
        models.execute_kw(args.db, uid, password,
            'ir.module.module', 'button_immediate_upgrade', [module_id])
        print("Module updated successfully!")
    else:
        print("Module is not installed! Installing it...")
        models.execute_kw(args.db, uid, password,
            'ir.module.module', 'button_immediate_install', [module_id])
        print("Module installed successfully!")
    
    # Verify field existence
    image_url_field_ids = models.execute_kw(args.db, uid, password,
        'ir.model.fields', 'search', [[('model', '=', 'product.template'), ('name', '=', 'image_url')]])
    
    if image_url_field_ids:
        print("The 'image_url' field is properly registered!")
    else:
        print("Warning: The 'image_url' field is not registered. The module might not be properly installed.")

if __name__ == "__main__":
    main()
