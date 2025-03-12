# Odoo Module Coding Conventions

## Module Structure

- Use the standard Odoo module structure with directories: controllers, data, models, security, static, views, wizard
- Name the module clearly and descriptively
- Include a README.rst file explaining module functionality

## Python Code

- Follow PEP8 guidelines with 4 spaces for indentation
- Maximum line length of 80-85 characters
- Use descriptive names for variables, functions, and classes
- Add docstrings to explain functions, methods, and complex logic
- Keep one object per Python file
- Use compute field naming convention: \_compute_field_name
- Use self.ensure_one() for methods expecting single records

## XML

- Use native Bootstrap classes for styling
- Apply underscore lowercase for class names
- Don't use the id tag in XML templates

## JavaScript/OWL

- Follow Odoo JS coding standards
- Use proper indentation and meaningful variable names

## General

- Provide logs for debugging purposes
- Inherit and use super() calls where possible instead of overriding
- Add help text to fields when needed
- Use filtered() method for multiple records

## Security

- Define proper access rights and record rules
- Use ir.model.access.csv for model access rights

## Naming Conventions

- Model names: use singular form (e.g., res.partner, sale.order)
- Transient models: <related_base_model>.<action>
- Report models: <related_base_model>.report.<action>
- Python classes: use CamelCase

## Imports

- Order imports: Python stdlib, Odoo, Odoo addons
- Alphabetically sort imports within each group

## Comments

- Use comments to explain complex logic or algorithms
- Keep comments up-to-date with code changes

# File Structure

odoo-imgs/
│
├── **init**.py # Module initialization file
├── **manifest**.py # Module manifest with metadata
│
├── models/ # Model definitions
│ ├── **init**.py # Models initialization file
│ ├── product.py # Product model extension
│ └── export_extension.py # Export functionality extension
│
├── security/ # Security configuration
│ └── ir.model.access.csv # Access control rules
│
└── static/ # Static files
└── description/ # Module description assets
└── icon.png # Module icon
