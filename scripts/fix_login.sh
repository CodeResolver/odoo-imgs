#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Diagnosing login issues with Odoo...${NC}"

# Check if Docker containers are running
echo -e "\nChecking if Docker containers are running..."
if docker-compose ps | grep -q "Up"; then
    echo -e "${GREEN}✓ Docker containers are running${NC}"
else
    echo -e "${RED}✗ Docker containers are not running${NC}"
    echo "Please start them with: docker-compose up -d"
    exit 1
fi

# Check database connection
echo -e "\nChecking database connection..."
docker-compose exec odoo python3 -c "
import psycopg2
try:
    conn = psycopg2.connect(
        dbname='postgres',
        user='odoo',
        password='odoo',
        host='db'
    )
    print('\033[92m✓ Database connection successful\033[0m')
    conn.close()
except Exception as e:
    print(f'\033[91m✗ Database connection failed: {e}\033[0m')
"

# Check if database exists
echo -e "\nChecking available databases..."
docker-compose exec odoo python3 -c "
import odoo
from odoo.service.db import list_dbs
dbs = list_dbs()
if dbs:
    print(f'\033[92m✓ Found databases: {dbs}\033[0m')
else:
    print('\033[91m✗ No databases found\033[0m')
"

# Reset admin password if needed
echo -e "\nWould you like to reset the admin password? (y/n) "
read -r choice
if [[ $choice == "y" ]]; then
    echo -e "Enter the name of the database to reset password for: "
    read -r dbname
    docker-compose exec odoo python3 -c "
import odoo
from odoo import SUPERUSER_ID
from odoo.api import Environment

# Create a new environment with superuser
with odoo.registry('$dbname').cursor() as cr:
    env = Environment(cr, SUPERUSER_ID, {})
    
    # Find admin user
    admin_user = env['res.users'].search([('login', '=', 'admin')], limit=1)
    if admin_user:
        admin_user.write({'password': 'admin'})
        print('\033[92m✓ Admin password reset to \"admin\"\033[0m')
    else:
        print('\033[91m✗ Admin user not found\033[0m')
"
fi

echo -e "\n${YELLOW}Troubleshooting steps:${NC}"
echo "1. Make sure you've created a database (if not, go to http://localhost:8069/web/database/manager)"
echo "2. The default credentials are usually admin/admin"
echo "3. If you can't access the database manager, the master password is: admin (as set in odoo.conf)"
echo "4. Try to restart the containers: docker-compose restart"
echo "5. Check the logs for any errors: docker-compose logs odoo"
