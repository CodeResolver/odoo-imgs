#!/bin/bash

# Colors for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Diagnosing common Odoo module issues...${NC}"

# Check if Docker is running
if ! docker ps &>/dev/null; then
    echo -e "${RED}Error: Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# Check if Odoo container is running
if ! docker-compose ps | grep -q "odoo.*Up"; then
    echo -e "${RED}Error: Odoo container is not running.${NC}"
    echo -e "Please start it with: ${GREEN}docker-compose up -d${NC}"
    exit 1
fi

# Check module directory structure
echo -e "\n${YELLOW}Checking module directory structure...${NC}"
required_files=("__init__.py" "__manifest__.py" "models/__init__.py")

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "✅ Found: $file"
    else
        echo -e "❌ Missing: $file"
    fi
done

# Check module name format
module_name=$(basename $(pwd))
echo -e "\n${YELLOW}Checking module name format...${NC}"
if [[ $module_name == *"-"* ]]; then
    echo -e "${RED}Warning: Module name '$module_name' contains hyphens.${NC}"
    echo -e "Odoo modules should use snake_case (underscores)."
    echo -e "Consider renaming to: ${GREEN}${module_name//-/_}${NC}"
else
    echo -e "✅ Module name '$module_name' format is correct."
fi

# Check Odoo logs for errors
echo -e "\n${YELLOW}Checking Odoo logs for errors...${NC}"
docker-compose logs --tail=50 odoo | grep -i "error\|exception\|warning" --color=always

# Try to access module info via Odoo API
echo -e "\n${YELLOW}Checking if module is discovered by Odoo...${NC}"
docker-compose exec odoo python3 -c "
import sys
try:
    import odoo
    from odoo.modules.module import get_modules
    
    modules = list(get_modules())
    
    # Check current module name
    current = '$module_name'
    snake_case = '${module_name//-/_}'
    
    if current in modules:
        print(f'\033[92mModule \"{current}\" is discovered by Odoo ✓\033[0m')
    elif snake_case in modules:
        print(f'\033[92mModule \"{snake_case}\" is discovered by Odoo ✓\033[0m')
    else:
        print(f'\033[91mModule is NOT discovered by Odoo ✗\033[0m')
        print(f'Modules in this path: {[m for m in modules if \"$module_name\" in m or \"${module_name//-/_}\" in m]}')
    
    # Print addons paths
    print(f'\\nAddons paths: {odoo.addons.__path__}')
except Exception as e:
    print(f'Error checking module: {e}')
    sys.exit(1)
"

echo -e "\n${YELLOW}Developer Mode Instructions${NC}"
echo -e "1. Log in to Odoo at http://localhost:8069"
echo -e "2. Navigate to http://localhost:8069/web?debug=1"
echo -e "3. You should now see 'Update Apps List' in the Apps menu dropdown"

echo -e "\n${YELLOW}If you still can't see 'Update Apps List', try these steps:${NC}"
echo -e "1. Make sure you're logged in as Administrator"
echo -e "2. Try restarting Odoo: ${GREEN}docker-compose restart odoo${NC}"
echo -e "3. Check the developer_mode.md file for more instructions"
