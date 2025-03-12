{
    'name': 'Product Image Export',
    'version': '1.0',
    'category': 'Sales',
    'summary': 'Export product images as URLs in Excel/CSV exports',
    'description': """
        This module adds the ability to include product image URLs
        when exporting products to Excel or CSV formats.
    """,
    'author': 'Your Company',
    'website': 'https://www.yourcompany.com',
    'depends': ['product', 'sale'],
    'data': [
        'security/ir.model.access.csv',
    ],
    'installable': True,
    'application': False,
    'auto_install': False,
}