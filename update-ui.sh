#!/bin/bash

# HeySym - Update UI Script
# Copy custom static files to JupyterHub static directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/static/custom"
VENV_DIR="$SCRIPT_DIR/venv"
TARGET_DIR="$VENV_DIR/share/jupyterhub/static/custom"

echo "🎨 Updating HeySym UI..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check source directory
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Source directory not found: $SOURCE_DIR"
    exit 1
fi

# Check venv
if [ ! -d "$VENV_DIR" ]; then
    echo "❌ Virtual environment not found: $VENV_DIR"
    exit 1
fi

# Create target directory
echo "📁 Creating target directory..."
mkdir -p "$TARGET_DIR"

# Copy files
echo "📋 Copying custom files..."
cp -v "$SOURCE_DIR"/* "$TARGET_DIR/"

echo ""
echo "✅ UI files updated successfully!"
echo ""
echo "📊 Files in target directory:"
ls -lh "$TARGET_DIR/"

echo ""
echo "🔄 Restart JupyterHub to apply changes:"
echo "   ./restart.sh"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
