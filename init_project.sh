#!/bin/bash
# HeySym Project Initialization Script
# Run this after cloning the repository

echo "🎓 Initializing HeySym project structure..."

# Create required directories
echo "📁 Creating directories..."
mkdir -p config courses logs exchange backups

echo "✅ Project structure created!"
echo ""
echo "📋 Next steps:"
echo "1. Follow PLAN.md Phase 1 for detailed setup"
echo "2. Create Python virtual environment: python3.11 -m venv venv"
echo "3. Activate venv: source venv/bin/activate"
echo "4. Install dependencies: pip install jupyterhub jupyterlab nbgrader jupyter-ai sympy numpy scipy matplotlib pandas jupyterhub-nativeauthenticator"
echo ""
echo "🚀 Happy coding!"
