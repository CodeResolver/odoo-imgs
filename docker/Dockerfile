FROM odoo:16.0

USER root

# Install additional system dependencies if needed
RUN apt-get update && apt-get install -y \
    python3-dev \
    build-essential \
    wget \
    git \
    # Add ssh client for deployment operations
    openssh-client \
    # Add rsync for deployment
    rsync \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install additional Python packages if needed
RUN pip3 install --no-cache-dir pytest pytest-odoo dokploy

# Set up module directory with the correct name
RUN mkdir -p /mnt/extra-addons/product_image_export

# Set permissions for odoo user
RUN chown -R odoo:odoo /mnt/extra-addons

# Switch back to odoo user
USER odoo

# Health check to verify Odoo is responding
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s CMD curl -f http://localhost:8069/web/health || exit 1
