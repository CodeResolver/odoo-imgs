# Enabling Developer Mode in Odoo

Developer Mode in Odoo unlocks additional features like "Update Apps List" and technical settings.

## Method 1: Using the URL

1. Log in to your Odoo instance (http://localhost:8069)
2. Add `/web?debug=1` to the URL, so it becomes:
   ```
   http://localhost:8069/web?debug=1
   ```
3. Press Enter to navigate to this URL
4. You should now be in Developer Mode

## Method 2: Using the Settings Menu

1. Log in as Administrator
2. Go to **Settings**
3. Scroll down to find the **Developer Tools** section
4. Click on **Activate the developer mode**

## Method 3: Using the About Menu (Odoo 16+)

1. Click on the user icon in the top-right corner
2. Select **About Odoo**
3. Click on **Activate the developer mode** button at the bottom

## Verifying Developer Mode is Active

Once Developer Mode is active:

- You'll see a bug icon in the top right menu
- More technical options will be available throughout the interface
- In the Apps menu, you should now see "Update Apps List" in the dropdown

## If You Still Don't See Update Apps List

If Developer Mode is enabled but you still don't see the "Update Apps List" option:

1. Make sure you're logged in as Administrator
2. Try clearing your browser cache and cookies
3. Check the Docker logs for any errors: `./docker_dev.sh logs`
4. Make sure the module is correctly mounted in the Docker container
