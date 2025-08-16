#!/bin/bash
set -e

# Check if uv is available
which uv || echo "uv not found in PATH"

# Define directories for the repositories
ARBOR_DIR="/app/repos/arbor"
DSPY_DIR="/app/repos/dspy"

# Create repos directory if it doesn't exist
mkdir -p /app/repos

# Clone or update arbor repository
if [ -d "$ARBOR_DIR" ]; then
    echo "Updating arbor repository..."
    cd "$ARBOR_DIR"
    git pull
else
    echo "Cloning arbor repository..."
    git clone https://github.com/Ziems/arbor.git "$ARBOR_DIR"
fi

# Clone or update dspy repository
if [ -d "$DSPY_DIR" ]; then
    echo "Updating dspy repository..."
    cd "$DSPY_DIR"
    git pull
else
    echo "Cloning dspy repository..."
    git clone https://github.com/stanfordnlp/dspy.git "$DSPY_DIR"
fi

# Install the packages via uv
echo "Installing arbor..."
uv pip install --system "$ARBOR_DIR"

echo "Installing dspy..."
uv pip install --system "$DSPY_DIR"

uv pip install --system datasets==3.6.0
# Change back to app directory
cd /app

# Execute the command passed to the container
exec "$@"