from odoo import models, fields, api
from urllib.parse import urljoin
import base64

class ProductTemplate(models.Model):
    _inherit = 'product.template'
    
    image_url = fields.Char(string='Image URL', compute='_compute_image_url', store=False)
    
    @api.depends('image_1920')
    def _compute_image_url(self):
        """Compute the public URL for the product image"""
        base_url = self.env['ir.config_parameter'].sudo().get_param('web.base.url')
        
        for product in self:
            if product.image_1920:
                # Get the attachment that stores this image
                attachment = self.env['ir.attachment'].sudo().search([
                    ('res_model', '=', 'product.template'),
                    ('res_id', '=', product.id),
                    ('res_field', '=', 'image_1920')
                ], limit=1)
                
                if attachment:
                    # Create a public URL for the attachment
                    image_url = urljoin(base_url, f'/web/image/{attachment.id}')
                    product.image_url = image_url
                else:
                    product.image_url = False
            else:
                product.image_url = False


class ProductProduct(models.Model):
    _inherit = 'product.product'
    
    image_url = fields.Char(string='Image URL', compute='_compute_image_url', store=False)
    
    @api.depends('image_1920')
    def _compute_image_url(self):
        """Compute the public URL for the product image"""
        base_url = self.env['ir.config_parameter'].sudo().get_param('web.base.url')
        
        for product in self:
            if product.image_1920:
                # Get the attachment that stores this image
                attachment = self.env['ir.attachment'].sudo().search([
                    ('res_model', '=', 'product.product'),
                    ('res_id', '=', product.id),
                    ('res_field', '=', 'image_1920')
                ], limit=1)
                
                if attachment:
                    # Create a public URL for the attachment
                    image_url = urljoin(base_url, f'/web/image/{attachment.id}')
                    product.image_url = image_url
                else:
                    product.image_url = False
            else:
                product.image_url = False