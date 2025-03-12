# Product Image Export for Odoo

This module extends Odoo's product export functionality to include image URLs when exporting products to Excel or CSV.

## Features

- Adds an `image_url` field to products
- Automatically computes public URLs for product images
- Includes image URLs in Excel and CSV exports

## Installation

### Development Environment Setup

1. Install Poetry:

   ```bash
   pip install poetry
   ```

2. Clone the repository:

   ```bash
   git clone https://github.com/your-username/product_image_export.git
   cd product_image_export
   ```

3. Create a Poetry virtual environment without installing Odoo as a dependency:

   ```bash
   poetry install
   ```

4. Link your local Odoo installation by either:

   a. Adding your Odoo directory to PYTHONPATH:

   ```bash
   export PYTHONPATH="/path/to/odoo:$PYTHONPATH"
   ```

   b. Or creating a symlink to Odoo in your virtual environment:

   ```bash
   cd $(poetry env info -p)/lib/python3.X/site-packages/
   ln -s /path/to/odoo odoo
   ```

### Odoo Installation

For this module to work, you need to have Odoo 16.0 installed. You can:

1. Use official Docker images:

   ```bash
   docker pull odoo:16.0
   ```

2. Or clone from GitHub:
   ```bash
   git clone https://github.com/odoo/odoo.git -b 16.0 --depth=1
   ```

## Usage

1. Start Odoo with the module in your addons path.
2. Go to Sales > Products or Inventory > Products.
3. Select the products you want to export.
4. Click the "Export" button.
5. Select Excel or CSV format.
6. Make sure "image_url" is included in the list of fields to export.
7. Click "Export" to download your file.

The exported file will now include a column with the public URL for each product's image.

## Technical Notes

- The module computes image URLs based on the Odoo attachment system
- URLs are based on the `web.base.url` system parameter
- The URLs are publicly accessible without authentication

## Compatibility

- Odoo 16.0
- Compatible with Community and Enterprise editions

## License

This module is licensed under LGPL-3.

## Support

For questions or support, please contact your system administrator or the module author.
