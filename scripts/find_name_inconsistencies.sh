#!/bin/bash

echo "Searching for inconsistent module names in the codebase..."
grep -r "odoo-imgs" --include="*.py" --include="*.xml" --include="*.yml" --include="*.sh" --include="Dockerfile" .

echo -e "\nIf any files were found above, they need to be updated to use 'product_image_export' instead."
