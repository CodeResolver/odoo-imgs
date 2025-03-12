#!/bin/bash

# Setup script for development environment

# Install poetry if not already installed
if ! command -v poetry &> /dev/null
then
    echo "Poetry not found, installing..."
    curl -sSL https://install.python-poetry.org | python3 -
fi

# Install dependencies
echo "Installing project dependencies..."
poetry install

# Create a .env file for configuration
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cat > .env << EOF
# Path to your Odoo installation
ODOO_PATH=/path/to/your/odoo
# Add to PYTHONPATH
export PYTHONPATH=\$ODOO_PATH:\$PYTHONPATH
EOF
fi

echo "Development environment setup complete!"
echo "Please edit the .env file with your actual Odoo installation path."
echo "To activate the environment, run: poetry shell"
echo "Then source the .env file: source .env"
