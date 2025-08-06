#!/usr/bin/env python3
"""
Generate All Stage 2 Diagrams
Healthcare Management System - Complete Diagram Suite
Generates all architecture and workflow diagrams

Created: August 2, 2025
Updated: August 4, 2025 - 100% Complete Production-Ready
Purpose: One-click generation of all Stage 2 visual documentation
"""

import subprocess
import sys
import os
from datetime import datetime

def run_script(script_name, description):
    """Run a diagram generation script and handle errors"""
    print(f"\n🎨 Generating {description}...")
    print(f"📄 Running: {script_name}")
    
    try:
        result = subprocess.run([sys.executable, script_name], 
                              capture_output=True, text=True, check=True)
        print(f"✅ {description} generated successfully!")
        if result.stdout:
            print(f"📝 Output: {result.stdout.strip()}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error generating {description}:")
        print(f"📝 Error: {e.stderr}")
        return False
    except FileNotFoundError:
        print(f"❌ Script not found: {script_name}")
        return False

def check_dependencies():
    """Check if required Python packages are installed"""
    print("🔍 Checking dependencies...")
    
    try:
        import matplotlib
        import numpy
        print("✅ matplotlib and numpy are available")
        return True
    except ImportError as e:
        print(f"❌ Missing dependency: {e}")
        print("💡 Install with: sudo apt install python3-matplotlib python3-numpy")
        return False

def main():
    """Generate all Stage 2 diagrams"""
    print("🎯 Stage 2 Complete Diagram Generation Suite")
    print("=" * 50)
    print(f"📅 Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    # Check dependencies first
    if not check_dependencies():
        print("\n❌ Cannot proceed without required dependencies")
        sys.exit(1)
    
    # List of diagrams to generate (updated for essential files only)
    diagrams = [
        {
            'script': 'generate_enhanced_stage2_architecture.py',
            'description': 'Complete Stage 2 Architecture (Production-Ready)',
            'output': 'Stage-2-Enhanced-Architecture.png'
        },
        {
            'script': 'generate_pipeline_flow.py',
            'description': 'CI/CD Pipeline Flow Diagram (9-Job Pipeline)',
            'output': 'Stage-2-Pipeline-Flow-Diagram.png'
        },
        {
            'script': 'generate_updated_onboarding_roadmap.py',
            'description': 'Updated Onboarding Roadmap (All Recent Changes)',
            'output': 'Stage-2-Updated-Onboarding-Roadmap.png'
        }
    ]
    
    # Track success/failure
    successful = []
    failed = []
    
    # Generate each diagram
    for diagram in diagrams:
        script_name = diagram['script']
        description = diagram['description']
        output_file = diagram['output']
        
        if os.path.exists(script_name):
            if run_script(script_name, description):
                successful.append({
                    'name': description,
                    'file': output_file
                })
            else:
                failed.append({
                    'name': description,
                    'script': script_name
                })
        else:
            print(f"⚠️  Script not found: {script_name}")
            failed.append({
                'name': description,
                'script': script_name
            })
    
    # Summary report
    print("\n" + "=" * 50)
    print("📊 Generation Summary Report")
    print("=" * 50)
    
    if successful:
        print(f"\n✅ Successfully Generated ({len(successful)}):")
        for item in successful:
            print(f"   • {item['name']}")
            print(f"     📁 File: {item['file']}")
            
            # Check if file actually exists
            if os.path.exists(item['file']):
                file_size = os.path.getsize(item['file'])
                print(f"     📊 Size: {file_size:,} bytes")
            else:
                print(f"     ⚠️  File not found after generation")
    
    if failed:
        print(f"\n❌ Failed to Generate ({len(failed)}):")
        for item in failed:
            print(f"   • {item['name']}")
            print(f"     📄 Script: {item['script']}")
    
    # Final status
    total_diagrams = len(diagrams)
    success_count = len(successful)
    
    print(f"\n🎯 Overall Status: {success_count}/{total_diagrams} diagrams generated")
    
    if success_count == total_diagrams:
        print("🎉 All diagrams generated successfully!")
        print("\n📋 Available Diagrams:")
        print("   • Stage-2-Enhanced-Architecture.png (Recommended for presentations)")
        print("   • Stage-2-Pipeline-Flow-Diagram.png (CI/CD workflow)")
        print("   • Stage-2-Onboarding-Roadmap.png (New user guide)")
        print("   • Stage-2-Architecture-Diagram.png (Original enhanced)")
        
        print("\n💡 Usage Recommendations:")
        print("   🎯 For stakeholder presentations: Use Enhanced Architecture")
        print("   📚 For technical documentation: Use Pipeline Flow")
        print("   👋 For new team members: Use Onboarding Roadmap")
        print("   📖 For complete reference: Use all diagrams")
        
    elif success_count > 0:
        print("⚠️  Partial success - some diagrams generated")
    else:
        print("❌ No diagrams were generated successfully")
        sys.exit(1)
    
    print(f"\n📅 Completed: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("🏥 Healthcare Management System - Stage 2 Visual Documentation Complete!")

if __name__ == "__main__":
    main()
