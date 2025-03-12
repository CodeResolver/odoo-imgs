from odoo import models, fields, api

class ProductExportExtension(models.TransientModel):
    _inherit = 'base_export.xlsx'
    
    def _get_extra_fields(self, model):
        """Add image_url to the list of available export fields"""
        res = super()._get_extra_fields(model)
        
        if model in ['product.template', 'product.product']:
            res.append('image_url')
            
        return res

class XLSXExporter(models.AbstractModel):
    _inherit = 'base.xlsx.exporter'
    
    def _get_fields_for_export(self, model):
        """Add image_url to the list of fields for export"""
        fields = super()._get_fields_for_export(model)
        
        if model in ['product.template', 'product.product']:
            if 'image_url' not in fields:
                fields.append('image_url')
                
        return fields