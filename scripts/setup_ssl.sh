#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Setting up directories for SSL certificates...${NC}"

# Create Traefik configuration directory
mkdir -p traefik
touch traefik/acme.json
chmod 600 traefik/acme.json

# Check if .env file exists, if not, copy from example
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file from template...${NC}"
    cp .env.example .env
    echo -e "${GREEN}Created .env file. Please edit it to set your domain and email.${NC}"
else
    echo -e "${YELLOW}Checking .env file for required variables...${NC}"
    
    # Check if DOMAIN is set
    if ! grep -q "DOMAIN=" .env; then
        echo 'DOMAIN=odoo.example.com' >> .env
        echo -e "${YELLOW}Added DOMAIN=odoo.example.com to .env file. Please update it.${NC}"
    fi
    
    # Check if ACME_EMAIL is set
    if ! grep -q "ACME_EMAIL=" .env; then
        echo 'ACME_EMAIL=admin@example.com' >> .env
        echo -e "${YELLOW}Added ACME_EMAIL=admin@example.com to .env file. Please update it.${NC}"
    fi
fi

echo -e "${GREEN}SSL setup complete!${NC}"
echo -e "Next steps:"
echo -e "1. Edit your .env file and set your domain name and email address"
echo -e "2. Start your containers with: ./odoo-tools start"
echo -e "3. Your site will be available at https://your-domain.com"
echo -e "\nNote: Make sure your domain's DNS is pointed to your server's IP address"
