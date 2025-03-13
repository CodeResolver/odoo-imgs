from odoo import models, fields, api
from urllib.parse import urljoin
import base64

class ProductTemplate(models.Model):
    _inherit = 'product.template'
    
    # Add an option to make the URL public
    image_url_public = fields.Boolean(
        string="Public Image URL", 
        default=False,
        help="If checked, the image URL will be publicly accessible without login"
    )
    
    image_url = fields.Char(
        string='Image URL', 
        compute='_compute_image_url', 
        store=True,
        help="URL to access the product image - may require authentication if not set to public",
        exportable=True
    )  
    
    @api.depends('image_1920', 'image_url_public')
    def _compute_image_url(self):
        """Compute the URL for the product image"""
        base_url = self.env['ir.config_parameter'].sudo().get_param('web.base.url')
        # Check if automatic public URLs are enabled
        auto_public = self.env['ir.config_parameter'].sudo().get_param('product_image_export.auto_public_urls', 'False').lower() == 'true'
        
        for product in self:
            if product.image_1920:
                # Get the attachment that stores this image
                attachment = self.env['ir.attachment'].sudo().search([
                    ('res_model', '=', 'product.template'),
                    ('res_id', '=', product.id),
                    ('res_field', '=', 'image_1920')
                ], limit=1)
                
                if attachment:
                    # Make public if configured or if the product setting is enabled
                    if product.image_url_public or auto_public:
                        # Make the attachment public and generate a public URL
                        attachment.sudo().write({'public': True})
                        # Use the share URL format with access_token for public access
                        access_token = attachment.sudo()._generate_access_token() if hasattr(attachment, '_generate_access_token') else ''
                        image_url = urljoin(base_url, f'/web/image/{attachment.id}?access_token={access_token}')
                    else:
                        # Standard URL that requires authentication
                        image_url = urljoin(base_url, f'/web/image/{attachment.id}')
                        
                    product.image_url = image_url
                else:
                    product.image_url = False
            else:
                product.image_url = False


class ProductProduct(models.Model):
    _inherit = 'product.product'
    
    # Add an option to make the URL public
    image_url_public = fields.Boolean(
        string="Public Image URL", 
        default=False,
        help="If checked, the image URL will be publicly accessible without login"
    )
    
    image_url = fields.Char(
        string='Image URL', 
        compute='_compute_image_url', 
        store=True,
        help="URL to access the product variant image - may require authentication if not set to public",
        exportable=True
    )
    
    @api.depends('image_1920', 'image_url_public')
    def _compute_image_url(self):
        """Compute the URL for the product image"""
        base_url = self.env['ir.config_parameter'].sudo().get_param('web.base.url')
        # Check if automatic public URLs are enabled
        auto_public = self.env['ir.config_parameter'].sudo().get_param('product_image_export.auto_public_urls', 'False').lower() == 'true'
        
        for product in self:
            if product.image_1920:
                # Get the attachment that stores this image
                attachment = self.env['ir.attachment'].sudo().search([
                    ('res_model', '=', 'product.product'),
                    ('res_id', '=', product.id),
                    ('res_field', '=', 'image_1920')
                ], limit=1)
                
                if attachment:
                    # Make public if configured or if the product setting is enabled
                    if product.image_url_public or auto_public:
                        # Make the attachment public and generate a public URL
                        attachment.sudo().write({'public': True})
                        # Use the share URL format with access_token for public access
                        access_token = attachment.sudo()._generate_access_token() if hasattr(attachment, '_generate_access_token') else ''
                        image_url = urljoin(base_url, f'/web/image/{attachment.id}?access_token={access_token}')
                    else:
                        # Standard URL that requires authentication
                        image_url = urljoin(base_url, f'/web/image/{attachment.id}')
                        
                    product.image_url = image_url
                else:
                    product.image_url = False
            else:
                product.image_url = False