#!/bin/bash

# Healthcare Management System - Source Code Version Checker
# This script helps students verify they're using the correct source code version

echo "🔍 Healthcare Management System - Version Checker"
echo "=================================================="

# Check current directory
CURRENT_DIR=$(basename "$PWD")
echo "📁 Current directory: $CURRENT_DIR"

# Check if we're in the right location
if [[ ! -f "backend/package.json" || ! -f "frontend/package.json" ]]; then
    echo "❌ Error: backend/package.json or frontend/package.json not found"
    echo "💡 Make sure you're in the source code root directory"
    exit 1
fi

# Check backend dependencies for Stage-2 indicators
STAGE2_BACKEND_COUNT=$(grep -c "jest\|eslint\|prettier\|supertest" backend/package.json 2>/dev/null || echo "0")
STAGE2_FRONTEND_COUNT=$(grep -c "vitest\|eslint\|prettier" frontend/package.json 2>/dev/null || echo "0")

# Ensure counts are single numbers (remove any extra output)
STAGE2_BACKEND_COUNT=$(echo $STAGE2_BACKEND_COUNT | tr -d '\n' | awk '{print $1}')
STAGE2_FRONTEND_COUNT=$(echo $STAGE2_FRONTEND_COUNT | tr -d '\n' | awk '{print $1}')

echo ""
echo "🔍 Analyzing source code version..."
echo "Backend Stage-2 indicators: $STAGE2_BACKEND_COUNT"
echo "Frontend Stage-2 indicators: $STAGE2_FRONTEND_COUNT"

# Determine version
if [[ $STAGE2_BACKEND_COUNT -eq 0 && $STAGE2_FRONTEND_COUNT -eq 0 ]]; then
    echo ""
    echo "✅ STAGE-1 VERSION DETECTED"
    echo "📚 This is the clean Stage-1 source code"
    echo "🎯 Perfect for: Project-Stage-1-Basic-CI-CD-Deploy"
    echo ""
    echo "📦 Key characteristics:"
    echo "  ✅ Minimal dependencies"
    echo "  ✅ No testing frameworks"
    echo "  ✅ No linting/formatting tools"
    echo "  ✅ Ready for basic Docker builds"
    
elif [[ $STAGE2_BACKEND_COUNT -gt 0 || $STAGE2_FRONTEND_COUNT -gt 0 ]]; then
    echo ""
    echo "⚠️  STAGE-2 VERSION DETECTED"
    echo "📚 This is the enhanced Stage-2 source code"
    echo "🎯 Perfect for: Project-Stage-2-Automated-CI-CD-Pipeline"
    echo ""
    echo "📦 Key characteristics:"
    echo "  ✅ Enhanced dependencies"
    echo "  ✅ Testing frameworks (Jest, Vitest)"
    echo "  ✅ Code quality tools (ESLint, Prettier)"
    echo "  ⚠️  Requires --no-workspaces for npm install"
    
    if [[ "$CURRENT_DIR" == "src-code-stage-1" ]]; then
        echo ""
        echo "❌ MISMATCH DETECTED!"
        echo "🚨 You're in src-code-stage-1/ but the code has Stage-2 features"
        echo "💡 This might cause confusion for Stage-1 students"
    fi
fi

# Check for package-lock.json files
echo ""
echo "🔒 Package lock file status:"
if [[ -f "backend/package-lock.json" ]]; then
    echo "  ✅ backend/package-lock.json exists"
else
    echo "  ❌ backend/package-lock.json missing (will be created on npm install)"
fi

if [[ -f "frontend/package-lock.json" ]]; then
    echo "  ✅ frontend/package-lock.json exists"
else
    echo "  ❌ frontend/package-lock.json missing (will be created on npm install)"
fi

# Provide recommendations
echo ""
echo "💡 RECOMMENDATIONS:"

if [[ $STAGE2_BACKEND_COUNT -eq 0 && $STAGE2_FRONTEND_COUNT -eq 0 ]]; then
    echo "📚 For Stage-1 students:"
    echo "  1. You're using the correct source code version ✅"
    echo "  2. Run: cd backend && npm install"
    echo "  3. Run: cd ../frontend && npm install"
    echo "  4. Build Docker images normally"
    
else
    echo "📚 For Stage-2 students:"
    echo "  1. You're using the enhanced source code version ✅"
    echo "  2. Run: cd backend && npm install --no-workspaces"
    echo "  3. Run: cd ../frontend && npm install --no-workspaces"
    echo "  4. Build Docker images with: docker build --no-cache"
    
    if [[ "$CURRENT_DIR" == "src-code-stage-1" ]]; then
        echo ""
        echo "🔄 If you're a Stage-1 student:"
        echo "  1. Switch to: cd ../src-code-stage-1/"
        echo "  2. Use the clean Stage-1 version instead"
    fi
fi

echo ""
echo "📖 For more details, see: Source-Code-Version-Guide.md"
echo "🆘 Need help? Check the troubleshooting section in the guide"
echo ""
echo "✅ Version check complete!"
