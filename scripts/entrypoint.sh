#!/bin/bash
set -e

# Check if uv is available
which uv || echo "uv not found in PATH"

# Fix git ownership issues with mounted volumes
git config --global --add safe.directory /app/repos/arbor
git config --global --add safe.directory /app/repos/dspy

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

# Check if we need to start arbor server
if [[ "$START_ARBOR" == "true" ]]; then
    echo "Starting Arbor server..."
    cd "$ARBOR_DIR"
    
    # Use custom config if provided
    if [[ -n "$ARBOR_CONFIG" && -f "$ARBOR_CONFIG" ]]; then
        echo "Using Arbor config: $ARBOR_CONFIG"
        python -m arbor.server -port 7453 --config "$ARBOR_CONFIG" &
    else
        python -m arbor.server --port 7453 &
    fi
    ARBOR_PID=$!
    
    # Wait for arbor server to be ready
    echo "Waiting for Arbor server to start..."
    for i in {1..10}; do
        if curl -s http://localhost:7453/health > /dev/null 2>&1; then
            echo "Arbor server is ready!"
            break
        fi
        if [ $i -eq 30 ]; then
            echo "Timeout waiting for Arbor server"
            kill $ARBOR_PID 2>/dev/null || true
            exit 1
        fi
        sleep 5
    done
    
    # Change back to app directory
    cd /app
    
    # Execute the command
    "$@"
    
    # Clean up arbor server
    kill $ARBOR_PID 2>/dev/null || true
else
    # Execute the command passed to the container
    exec "$@"
fi