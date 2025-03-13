{
    'name': 'Product Image Export',
    'version': '1.0',
    'category': 'Sales',
    'summary': 'Export product images as URLs in Excel/CSV exports',
    'description': """
        This module adds the ability to include product image URLs
        when exporting products to Excel or CSV formats.
    """,
    'author': 'Jp Cabral',
    'website': 'https://www.unifywebservices.com',
    'depends': [
        'product',
        'sale',
        'web',
        'base_setup',
        # Removed dependency on base_export as it's not available
    ],
    'data': [
        'security/ir.model.access.csv',
        'views/product_export_settings.xml',
    ],
    'installable': True,
    'application': True,
    'auto_install': False,
    
    # Fix icon path by adding module name prefix
    'icon': '/product_image_export/static/description/icon.png',
    'images': ['/product_image_export/static/description/banner.png'],
    
    'license': 'LGPL-3',
    'sequence': 100,
    
    # Add assets to ensure images are loaded
    'assets': {},
    
    # Indicate this module has web assets
    'web': True,
}