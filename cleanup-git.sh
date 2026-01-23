#!/bin/bash
# Git Cleanup Script - Remove large files from Git tracking
# Run this script to remove node_modules, build artifacts, and cache files from Git

echo "🧹 Cleaning up Git repository..."
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a Git repository"
    exit 1
fi

# Remove large directories from Git tracking (but keep local files)
echo "📦 Removing node_modules from Git tracking..."
git rm -r --cached backend/node_modules/ 2>/dev/null || echo "  (already removed or doesn't exist)"

echo "🔧 Removing .dart_tool from Git tracking..."
git rm -r --cached .dart_tool/ 2>/dev/null || echo "  (already removed or doesn't exist)"

echo "🏗️  Removing build directories from Git tracking..."
git rm -r --cached build/ 2>/dev/null || echo "  (already removed or doesn't exist)"
git rm -r --cached backend/build/ 2>/dev/null || echo "  (already removed or doesn't exist)"

echo "🐍 Removing Python cache from Git tracking..."
find . -type d -name "__pycache__" -exec git rm -r --cached {} + 2>/dev/null || echo "  (already removed or doesn't exist)"

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Review the changes: git status"
echo "2. Commit the cleanup: git commit -m 'Remove large files from Git tracking'"
echo "3. Push to remote: git push origin <your-branch>"
echo ""
echo "⚠️  Note: This removes files from Git tracking but keeps them locally."
echo "   After committing, the files will no longer be in Git history going forward."

