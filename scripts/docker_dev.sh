#!/bin/bash

# Colors for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Make sure docker directory exists
mkdir -p docker
mkdir -p config

function show_help {
    echo -e "${GREEN}Odoo Docker Development Environment${NC}"
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start       Start the development environment"
    echo "  stop        Stop the development environment"
    echo "  restart     Restart the development environment"
    echo "  rebuild     Rebuild the Docker images"
    echo "  logs        Show logs"
    echo "  shell       Open a shell in the Odoo container"
    echo "  dev         Start with enhanced development features"
    echo "  update      Update a specific module"
    echo "  help        Show this help message"
    echo ""
    echo "Once started, Odoo will be available at http://localhost:8069"
    echo "Default master password: admin"
}

function start_env {
    echo -e "${GREEN}Starting Odoo development environment...${NC}"
    docker-compose up -d
    echo -e "${GREEN}Odoo is starting at http://localhost:8069${NC}"
    echo -e "${YELLOW}It may take a few moments for Odoo to fully initialize.${NC}"
}

function stop_env {
    echo -e "${GREEN}Stopping Odoo development environment...${NC}"
    docker-compose down
}

function restart_env {
    stop_env
    start_env
}

function rebuild_env {
    echo -e "${GREEN}Rebuilding Odoo development environment...${NC}"
    docker-compose build --no-cache
    start_env
}

function show_logs {
    echo -e "${GREEN}Showing logs...${NC}"
    docker-compose logs -f
}

function open_shell {
    echo -e "${GREEN}Opening shell in Odoo container...${NC}"
    docker-compose exec odoo bash
}

function start_dev {
    echo -e "${GREEN}Starting Odoo in enhanced development mode...${NC}"
    echo -e "${YELLOW}This mode enables auto-reloading and more verbose logs${NC}"
    
    # Stop any running containers
    docker-compose down
    
    # Start in foreground with dev mode flags
    docker-compose up --build
}

function update_module {
    if [ -z "$1" ]; then
        echo -e "${YELLOW}Please specify a module name to update${NC}"
        echo "Usage: $0 update <module_name>"
        return 1
    fi
    
    module=$1
    echo -e "${GREEN}Updating module: $module${NC}"
    docker-compose exec odoo python3 /usr/bin/odoo -u $module --stop-after-init
    echo -e "${GREEN}Module updated. Restarting Odoo...${NC}"
    docker-compose restart odoo
}

# Process command
case "$1" in
    start)
        start_env
        ;;
    stop)
        stop_env
        ;;
    restart)
        restart_env
        ;;
    rebuild)
        rebuild_env
        ;;
    logs)
        show_logs
        ;;
    shell)
        open_shell
        ;;
    dev)
        start_dev
        ;;
    update)
        update_module "$2"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        ;;
esac
