from odoo.tests import common, tagged

@tagged('post_install', '-at_install')
class TestProductImageExport(common.TransactionCase):

    def setUp(self):
        super().setUp()
        self.product = self.env['product.template'].create({'name': 'Test Product'})

    def test_compute_image_url(self):
        # Ensure that the image_url is computed correctly
        self.product.image_1920 = b'test_image_data'  # Simulate having an image
        self.product._compute_image_url()
        self.assertTrue(bool(self.product.image_url), "Image URL should be computed")

    def test_no_image_url(self):
        # Ensure that the image_url is False when there is no image
        self.product._compute_image_url()
        self.assertFalse(self.product.image_url, "Image URL should be False when no image is present")
