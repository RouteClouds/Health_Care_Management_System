#!/bin/bash

echo "🎨 Stage 2 Architecture Diagram Generator"
echo "Healthcare Management System"
echo "Tech Stack: Jest + Selenium + SonarQube + Trivy"
echo "=========================================="

# Check if virtual environment exists
if [ ! -d "stage2-diagrams-env" ]; then
    echo "📦 Creating Python virtual environment..."
    python3 -m venv stage2-diagrams-env
    
    echo "📥 Installing required packages..."
    source stage2-diagrams-env/bin/activate
    pip install matplotlib numpy
else
    echo "✅ Virtual environment already exists"
fi

# Activate virtual environment and generate diagrams
echo "🚀 Activating virtual environment and generating diagrams..."
source stage2-diagrams-env/bin/activate

# Generate diagrams
echo "🎨 Generating architecture diagrams..."
python3 generate_all_diagrams.py

# Check if diagrams were created successfully
if [ -f "Stage-2-Architecture-Diagram.png" ] && [ -f "Stage-2-Pipeline-Flow-Diagram.png" ]; then
    echo ""
    echo "🎉 SUCCESS: All diagrams generated successfully!"
    echo ""
    echo "📁 Generated files:"
    echo "   • Stage-2-Architecture-Diagram.png"
    echo "   • Stage-2-Pipeline-Flow-Diagram.png"
    echo "   • README.md"
    echo ""
    echo "📊 File sizes:"
    ls -lah *.png *.md | grep -E '\.(png|md)$'
    echo ""
    echo "🎯 Features:"
    echo "   ✅ High-resolution PNG format (300 DPI)"
    echo "   ✅ No overlapping text"
    echo "   ✅ Professional healthcare color scheme"
    echo "   ✅ Complete Jest + Selenium + SonarQube + Trivy stack"
    echo "   ✅ AWS EKS infrastructure visualization"
    echo "   ✅ Detailed CI/CD pipeline workflow"
    echo ""
    echo "📖 View diagrams:"
    echo "   • Architecture: Stage-2-Architecture-Diagram.png"
    echo "   • Pipeline Flow: Stage-2-Pipeline-Flow-Diagram.png"
    echo "   • Documentation: README.md"
else
    echo "❌ ERROR: Diagram generation failed"
    echo "Check the output above for error messages"
    exit 1
fi

echo ""
echo "✨ Diagram generation complete!"
