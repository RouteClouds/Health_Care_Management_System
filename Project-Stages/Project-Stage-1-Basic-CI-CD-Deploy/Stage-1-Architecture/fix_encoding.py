#!/usr/bin/env python3
"""
Quick fix for encoding issues in generate_all_diagrams.py
"""

import re

def fix_encoding():
    """Fix encoding issues in the main script"""
    
    # Read the file
    with open('generate_all_diagrams.py', 'r', encoding='utf-8', errors='replace') as f:
        content = f.read()
    
    # Fix the problematic lines
    content = content.replace('print("�️  Format:', 'print("🖼️  Format:')
    content = content.replace('print("�📁 Location:', 'print("📁 Location:')
    
    # Write back
    with open('generate_all_diagrams.py', 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("✅ Fixed encoding issues in generate_all_diagrams.py")

if __name__ == "__main__":
    fix_encoding()
