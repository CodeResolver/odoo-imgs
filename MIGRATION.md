# Migration Guide for Product Image Export

## Handling Missing Dependencies

If you encounter errors about missing dependencies when installing this module, follow these steps:

### For missing 'base_export' module:

The module has been updated to work without the `base_export` dependency. If you encounter errors:

1. Make sure your Odoo version is compatible (tested with Odoo 16.0)
2. Use the latest version of this module which removes the dependency
3. If using a custom export module, adjust the code in `models/export_extension.py` as needed

## Manual Export Solution

If the automatic field addition doesn't work in your specific Odoo setup, you can always:

1. Export products as usual
2. In the export dialog, manually add the `image_url` field
3. The URL will be correctly generated as long as the module is installed

## Technical Details

The module works by:

1. Adding an `image_url` computed field to product models
2. Computing public URLs for product images
3. Making those fields available during export operations

If you face any issues, please submit them to the repository issue tracker.
