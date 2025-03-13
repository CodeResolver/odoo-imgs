from odoo import models, fields, api

# Use standard Odoo base module for export functionality
class ProductExportMixin(models.AbstractModel):
    """Mixin to add image_url field to product exports"""
    _name = 'product.export.mixin'
    _description = 'Product Export Mixin'
    
    def get_export_fields(self, original_fields, model):
        """Add image_url to product export fields"""
        if model in ['product.template', 'product.product']:
            if 'image_url' not in original_fields:
                original_fields.append('image_url')
        return original_fields

# Override default export behavior to include image_url
class BaseExportMixin(models.AbstractModel):
    _name = 'base_export.mixin'
    _description = 'Base Export Mixin'
    
    def _get_available_field_names(self):
        """Add image_url to available export field names"""
        field_names = super(BaseExportMixin, self)._get_available_field_names() \
            if hasattr(super(BaseExportMixin, self), '_get_available_field_names') \
            else []
        
        # Add image_url to the list if exporting from product models
        active_model = self.env.context.get('active_model')
        if active_model in ['product.product', 'product.template']:
            if 'image_url' not in field_names:
                field_names.append('image_url')
        
        return field_names

# Hook into base export functionality
class DataExport(models.TransientModel):
    _inherit = 'base.export.wizard' if 'base.export.wizard' in models.MetaModel.module_to_models.get('base', []) else 'base_import.import'
    
    def default_get(self, fields_list):
        """Add image_url when exporting products"""
        res = super(DataExport, self).default_get(fields_list)
        
        active_model = self.env.context.get('active_model')
        if active_model in ['product.template', 'product.product']:
            # Try to add image_url to export fields, structure may vary based on Odoo version
            if 'fields_list' in res and isinstance(res['fields_list'], list):
                if 'image_url' not in [f[0] if isinstance(f, (list, tuple)) else f for f in res['fields_list']]:
                    res['fields_list'].append('image_url')
                    
            # Enable auto-public URLs for export if configured
            auto_public = self.env['ir.config_parameter'].sudo().get_param('product_image_export.auto_public_urls', 'False').lower() == 'true'
            export_auto_public = self.env['ir.config_parameter'].sudo().get_param('product_image_export.export_auto_public', 'True').lower() == 'true'
            
            # If exporting, temporarily enable auto-public if configured
            if export_auto_public and not auto_public:
                self.env['ir.config_parameter'].sudo().set_param('product_image_export.auto_public_urls', 'True')
                # Schedule recomputation of image_url field
                self.env['product.template'].sudo().search([]).write({'image_url_public': False})
                self.env['product.product'].sudo().search([]).write({'image_url_public': False})
        
        return res

# Add a new settings model
class ProductImageExportSettings(models.TransientModel):
    _inherit = 'res.config.settings'
    
    product_image_auto_public = fields.Boolean(
        string='Public Image URLs by Default',
        help='If enabled, all product images will have public URLs by default',
        config_parameter='product_image_export.auto_public_urls'
    )
    
    product_image_export_auto_public = fields.Boolean(
        string='Make Images Public on Export',
        help='If enabled, all product images will be made public when exported',
        default=True,
        config_parameter='product_image_export.export_auto_public'
    )