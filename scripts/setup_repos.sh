#!/bin/bash
set -e

echo "Setting up local repositories..."

# Create repos directory if it doesn't exist
mkdir -p repos

# Clone arbor repository if it doesn't exist
if [ ! -d "repos/arbor" ]; then
    echo "Cloning arbor repository..."
    git clone https://github.com/Ziems/arbor.git repos/arbor
else
    echo "arbor repository already exists, skipping..."
fi

# Clone dspy repository if it doesn't exist
if [ ! -d "repos/dspy" ]; then
    echo "Cloning dspy repository..."
    git clone https://github.com/stanfordnlp/dspy.git repos/dspy
else
    echo "dspy repository already exists, skipping..."
fi

echo "✓ Repositories are ready!"
echo ""
echo "To run with local repos:"
echo "docker run -v \$(pwd)/repos:/app/repos arbor-test"