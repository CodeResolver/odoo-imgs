# Troubleshooting Product Image Export

If you're having issues with the Product Image Export module, follow these steps to resolve common issues.

## Image URL Field Not Appearing in Export Dialog

### Check Module Installation

1. Go to Apps menu
2. Remove the "Apps" filter (click the x on the Apps filter)
3. Search for "Product Image Export"
4. Make sure it shows as "Installed"
5. If not installed, click "Install"
6. After installation, restart Odoo or refresh your browser

### Force Update of the Module

1. Enter Developer Mode (add "/web?debug=1" to your URL)
2. Go to Settings > Technical > Modules > All Modules
3. Find "Product Image Export"
4. Click "Upgrade" or "Update"

### Check Field Registration

1. In Developer Mode, go to Settings > Technical > Database Structure > Models
2. Search for "product.template"
3. Find the "image_url" field in the list of fields
4. If it's not there, the module might not be correctly installed

## Using the Export Dialog Correctly

1. Go to Sales > Products (or Inventory > Products)
2. Select the product(s) you want to export
3. Click the "Export" button (download icon)
4. Select "Export all or Export selected"
5. Under "Available fields" search for "image_url" or scroll to find it
6. Make sure it's added to "Fields to export" column
7. Click "Export to File" button

## Manual Field Addition

If the field is still not visible, try these steps:

1. In the export dialog, go to "Add Field" section at the bottom
2. Type "image_url" and press Enter
3. It should appear as a custom field you can add

## Check for Error Logs

1. Run `./docker_dev.sh logs` to check for any error messages
2. Look for errors related to the module installation or field registration

## General Troubleshooting

1. Clear browser cache and cookies
2. Log out and log back in to Odoo
3. Restart the Odoo server: `./docker_dev.sh restart`

## Verify Image URLs are Generated

1. Go to a product that has an image
2. In Developer Mode, click "View Metadata" option
3. You should see the "image_url" field in the list

If you continue to experience issues, check the Odoo server logs for more detailed error information.
