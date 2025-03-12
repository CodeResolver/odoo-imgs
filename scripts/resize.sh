#!/bin/bash

# Helper script to run resize_images.py through Poetry

# Make sure the script is executable
chmod +x resize_images.py

echo "Running image resizer through Poetry environment..."
poetry run python resize_images.py

if [ $? -ne 0 ]; then
    echo "Failed to run with Poetry. Trying to install dependencies..."
    poetry install
    echo "Now running the script..."
    poetry run python resize_images.py
fi
