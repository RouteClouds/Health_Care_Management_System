#!/usr/bin/env python3
"""
Stage 2 Onboarding Workflow Diagram Generator
Healthcare Management System - New User Roadmap
Visual guide for new users jumping into Stage 2

Created: August 2, 2025
Purpose: Help new users understand project structure and getting started
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch, Circle
import numpy as np

def create_onboarding_roadmap():
    """Create comprehensive onboarding roadmap for Stage 2"""
    
    # Create figure with high resolution
    fig, ax = plt.subplots(1, 1, figsize=(24, 18))
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')
    
    # Color scheme for different sections
    colors = {
        'start': '#28a745',      # Green for start
        'docs': '#007bff',       # Blue for documentation
        'code': '#6f42c1',       # Purple for source code
        'infra': '#fd7e14',      # Orange for infrastructure
        'deploy': '#dc3545',     # Red for deployment
        'monitor': '#20c997',    # Teal for monitoring
        'path': '#ffc107',       # Yellow for pathway
        'important': '#e83e8c'   # Pink for important notes
    }
    
    # Main Title
    ax.text(50, 95, 'Stage 2: New User Onboarding Roadmap', 
            fontsize=28, fontweight='bold', ha='center',
            bbox=dict(boxstyle="round,pad=0.8", facecolor='lightblue', alpha=0.9))
    
    ax.text(50, 91, 'Healthcare Management System - Complete Getting Started Guide', 
            fontsize=18, ha='center', style='italic')
    
    ax.text(50, 88, 'Visual Navigation Map: Where to Find Everything & How to Start', 
            fontsize=14, ha='center', color='#666666')
    
    # ============================================================================
    # SECTION 1: GETTING STARTED (Top Left)
    # ============================================================================
    
    # Start Here Box
    start_box = FancyBboxPatch((2, 78), 20, 8, 
                              boxstyle="round,pad=0.5", 
                              facecolor=colors['start'], 
                              edgecolor='black', linewidth=3)
    ax.add_patch(start_box)
    ax.text(12, 83, 'START HERE', fontsize=16, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(12, 81, 'New to Stage 2?', fontsize=12, 
            ha='center', va='center', color='white')
    ax.text(12, 79, 'Follow the numbered path!', fontsize=10, 
            ha='center', va='center', color='white')
    
    # Step numbers
    step_positions = [
        (12, 75),   # 1
        (35, 75),   # 2
        (65, 75),   # 3
        (85, 75),   # 4
        (85, 55),   # 5
        (65, 55),   # 6
        (35, 55),   # 7
        (12, 55),   # 8
        (12, 35),   # 9
        (35, 35),   # 10
        (65, 35),   # 11
        (85, 35),   # 12
    ]
    
    for i, (x, y) in enumerate(step_positions, 1):
        circle = Circle((x, y), 2, facecolor=colors['path'], 
                       edgecolor='black', linewidth=2)
        ax.add_patch(circle)
        ax.text(x, y, str(i), fontsize=12, fontweight='bold', 
                ha='center', va='center', color='black')
    
    # Connect the steps with arrows
    for i in range(len(step_positions) - 1):
        start_pos = step_positions[i]
        end_pos = step_positions[i + 1]
        
        # Calculate arrow direction
        dx = end_pos[0] - start_pos[0]
        dy = end_pos[1] - start_pos[1]
        
        # Adjust start and end points to avoid overlapping circles
        if dx != 0:
            start_x = start_pos[0] + (2 if dx > 0 else -2)
            end_x = end_pos[0] + (-2 if dx > 0 else 2)
            start_y = start_pos[1]
            end_y = end_pos[1]
        else:
            start_x = start_pos[0]
            end_x = end_pos[0]
            start_y = start_pos[1] + (-2 if dy > 0 else 2)
            end_y = end_pos[1] + (2 if dy > 0 else -2)
        
        arrow = ConnectionPatch((start_x, start_y), (end_x, end_y), 
                              "data", "data", 
                              arrowstyle="->", shrinkA=0, shrinkB=0, 
                              mutation_scale=20, fc=colors['path'], 
                              ec=colors['path'], lw=3)
        ax.add_artist(arrow)
    
    # ============================================================================
    # SECTION 2: DOCUMENTATION ROADMAP (Step 1-3)
    # ============================================================================
    
    # Step 1: Master Documentation
    doc1_box = FancyBboxPatch((25, 70), 18, 10, 
                             boxstyle="round,pad=0.3", 
                             facecolor=colors['docs'], 
                             edgecolor='black', linewidth=2)
    ax.add_patch(doc1_box)
    ax.text(34, 77, '1. Read Master Guide', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(34, 75, 'docs/01-STAGE-2-INDEX.md', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(34, 73, 'Complete project overview', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(34, 71, 'Technology stack explained', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Step 2: Implementation Plan
    doc2_box = FancyBboxPatch((55, 70), 18, 10, 
                             boxstyle="round,pad=0.3", 
                             facecolor=colors['docs'], 
                             edgecolor='black', linewidth=2)
    ax.add_patch(doc2_box)
    ax.text(64, 77, '2. Study Implementation', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(64, 75, 'docs/IMPLEMENTATION-PLAN-SUMMARY.md', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(64, 73, '4-phase roadmap', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(64, 71, 'What was built & why', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Step 3: Architecture Overview
    doc3_box = FancyBboxPatch((75, 70), 18, 10, 
                             boxstyle="round,pad=0.3", 
                             facecolor=colors['docs'], 
                             edgecolor='black', linewidth=2)
    ax.add_patch(doc3_box)
    ax.text(84, 77, '3. View Architecture', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(84, 75, 'Stage-2-Architecture/', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(84, 73, 'Visual diagrams (PNG)', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(84, 71, 'Complete system overview', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 3: SOURCE CODE EXPLORATION (Step 4-6)
    # ============================================================================
    
    # Step 4: Source Code Location
    code1_box = FancyBboxPatch((75, 50), 18, 10, 
                              boxstyle="round,pad=0.3", 
                              facecolor=colors['code'], 
                              edgecolor='black', linewidth=2)
    ax.add_patch(code1_box)
    ax.text(84, 57, '4. Find Source Code', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(84, 55, '../../src-code/', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(84, 53, 'React frontend', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(84, 51, 'Node.js backend', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Step 5: Test Configuration
    code2_box = FancyBboxPatch((55, 50), 18, 10, 
                              boxstyle="round,pad=0.3", 
                              facecolor=colors['code'], 
                              edgecolor='black', linewidth=2)
    ax.add_patch(code2_box)
    ax.text(64, 57, '5. Check Test Setup', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(64, 55, 'Jest + Vitest + Selenium', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(64, 53, 'package.json updated', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(64, 51, '80% coverage enforced', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Step 6: CI/CD Pipeline
    code3_box = FancyBboxPatch((25, 50), 18, 10, 
                              boxstyle="round,pad=0.3", 
                              facecolor=colors['code'], 
                              edgecolor='black', linewidth=2)
    ax.add_patch(code3_box)
    ax.text(34, 57, '6. Review CI/CD Pipeline', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(34, 55, '.github/workflows/', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(34, 53, '9-job automated pipeline', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(34, 51, 'GitHub Actions ready', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 4: INFRASTRUCTURE SETUP (Step 7-9)
    # ============================================================================
    
    # Step 7: Kubernetes Manifests
    infra1_box = FancyBboxPatch((2, 50), 18, 10, 
                               boxstyle="round,pad=0.3", 
                               facecolor=colors['infra'], 
                               edgecolor='black', linewidth=2)
    ax.add_patch(infra1_box)
    ax.text(11, 57, '7. K8s Infrastructure', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(11, 55, 'k8s/ directory', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(11, 53, 'Kubernetes manifests', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(11, 51, 'Ready for deployment', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Step 8: Helm Charts
    infra2_box = FancyBboxPatch((2, 30), 18, 10, 
                               boxstyle="round,pad=0.3", 
                               facecolor=colors['infra'], 
                               edgecolor='black', linewidth=2)
    ax.add_patch(infra2_box)
    ax.text(11, 37, '8. Helm Deployment', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(11, 35, 'helm-charts/', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(11, 33, 'Multi-environment', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(11, 31, 'Dev/Staging/Prod', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Step 9: Deployment Scripts
    infra3_box = FancyBboxPatch((25, 30), 18, 10, 
                               boxstyle="round,pad=0.3", 
                               facecolor=colors['infra'], 
                               edgecolor='black', linewidth=2)
    ax.add_patch(infra3_box)
    ax.text(34, 37, '9. Automation Scripts', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(34, 35, 'scripts/', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(34, 33, 'validate-infrastructure.sh', fontsize=8, 
            ha='center', va='center', color='white')
    ax.text(34, 31, 'deploy-healthcare.sh', fontsize=8, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 5: DEPLOYMENT & MONITORING (Step 10-12)
    # ============================================================================
    
    # Step 10: Prerequisites
    deploy1_box = FancyBboxPatch((55, 30), 18, 10, 
                                boxstyle="round,pad=0.3", 
                                facecolor=colors['deploy'], 
                                edgecolor='black', linewidth=2)
    ax.add_patch(deploy1_box)
    ax.text(64, 37, '10. Check Prerequisites', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(64, 35, 'docs/STAGE-2-OPERATIONS-GUIDE.md', fontsize=8, 
            ha='center', va='center', color='white')
    ax.text(64, 33, 'kubectl, helm, docker', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(64, 31, 'AWS EKS cluster', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Step 11: Deploy Development
    deploy2_box = FancyBboxPatch((75, 30), 18, 10, 
                                boxstyle="round,pad=0.3", 
                                facecolor=colors['deploy'], 
                                edgecolor='black', linewidth=2)
    ax.add_patch(deploy2_box)
    ax.text(84, 37, '11. Deploy Development', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(84, 35, './scripts/deploy-healthcare.sh', fontsize=8, 
            ha='center', va='center', color='white')
    ax.text(84, 33, '-e development', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(84, 31, 'Start with dev environment', fontsize=8, 
            ha='center', va='center', color='white')
    
    # Step 12: Monitor & Validate
    monitor_box = FancyBboxPatch((75, 10), 18, 10, 
                                boxstyle="round,pad=0.3", 
                                facecolor=colors['monitor'], 
                                edgecolor='black', linewidth=2)
    ax.add_patch(monitor_box)
    ax.text(84, 17, '12. Monitor & Validate', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(84, 15, 'Prometheus + Grafana', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(84, 13, 'Health checks', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(84, 11, 'Verify deployment', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 6: QUICK REFERENCE PANEL (Left Side)
    # ============================================================================
    
    # Quick Reference Box
    ref_box = FancyBboxPatch((2, 5), 40, 20, 
                            boxstyle="round,pad=0.5", 
                            facecolor='#f8f9fa', 
                            edgecolor='black', linewidth=2)
    ax.add_patch(ref_box)
    
    ax.text(22, 22, 'Quick Reference: Key Locations', fontsize=14, fontweight='bold', 
            ha='center', va='center')
    
    # Reference items
    ref_items = [
        ('Documentation Hub:', 'docs/01-STAGE-2-INDEX.md'),
        ('Source Code:', '../../src-code/ (React + Node.js)'),
        ('CI/CD Pipeline:', '.github/workflows/stage2-ci-cd.yml'),
        ('Kubernetes:', 'k8s/ (manifests) + helm-charts/'),
        ('Deployment:', 'scripts/deploy-healthcare.sh'),
        ('Monitoring:', 'Prometheus + Grafana (auto-deployed)'),
        ('Architecture:', 'Stage-2-Architecture/*.png'),
        ('Operations:', 'docs/STAGE-2-OPERATIONS-GUIDE.md'),
        ('Troubleshooting:', 'docs/STAGE-2-TROUBLESHOOTING-REFERENCE.md'),
    ]
    
    y_pos = 19.5
    for title, path in ref_items:
        ax.text(4, y_pos, title, fontsize=10, fontweight='bold', 
                ha='left', va='center')
        ax.text(4, y_pos - 0.8, path, fontsize=9, 
                ha='left', va='center', color='#666666')
        y_pos -= 2
    
    # ============================================================================
    # SECTION 7: IMPORTANT NOTES (Right Side)
    # ============================================================================
    
    # Important Notes Box
    notes_box = FancyBboxPatch((45, 5), 30, 20, 
                              boxstyle="round,pad=0.5", 
                              facecolor='#fff3cd', 
                              edgecolor=colors['important'], linewidth=2)
    ax.add_patch(notes_box)
    
    ax.text(60, 22, 'Important Notes for New Users', fontsize=14, fontweight='bold', 
            ha='center', va='center', color=colors['important'])
    
    notes = [
        '1. Start with documentation (steps 1-3) before coding',
        '2. Source code is in ../../src-code/ (shared with Stage 1)',
        '3. All Stage 2 configs are in this directory',
        '4. Use development environment first (safest)',
        '5. Validate infrastructure before deploying',
        '6. Monitor logs during first deployment',
        '7. Healthcare compliance is built-in (HIPAA/FDA)',
        '8. 80% test coverage is enforced',
        '9. All tools are pre-configured and ready',
        '10. Follow numbered path for best results!'
    ]
    
    y_pos = 19.5
    for note in notes:
        ax.text(46, y_pos, note, fontsize=9, 
                ha='left', va='center')
        y_pos -= 1.6
    
    # ============================================================================
    # FINAL TOUCHES
    # ============================================================================
    
    # Add legend for colors
    legend_y = 85
    legend_items = [
        ('Documentation', colors['docs']),
        ('Source Code', colors['code']),
        ('Infrastructure', colors['infra']),
        ('Deployment', colors['deploy']),
        ('Monitoring', colors['monitor'])
    ]
    
    for i, (label, color) in enumerate(legend_items):
        x_pos = 2 + i * 8
        legend_circle = Circle((x_pos, legend_y), 1, facecolor=color, 
                              edgecolor='black', linewidth=1)
        ax.add_patch(legend_circle)
        ax.text(x_pos, legend_y - 3, label, fontsize=8, 
                ha='center', va='center', rotation=45)
    
    # Version info
    ax.text(98, 2, 'Stage 2 Onboarding v1.0\nGenerated: August 2025', 
            fontsize=8, ha='right', va='bottom', style='italic')
    
    plt.tight_layout()
    return fig

def main():
    """Generate and save the onboarding roadmap diagram"""
    print("🗺️  Generating Stage 2 Onboarding Roadmap...")
    
    # Create the diagram
    fig = create_onboarding_roadmap()
    
    # Save as high-quality PNG
    output_file = 'Stage-2-Onboarding-Roadmap.png'
    fig.savefig(output_file, dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='none')
    
    print(f"✅ Onboarding roadmap saved as: {output_file}")
    print("🎯 Features:")
    print("   • 12-step visual pathway for new users")
    print("   • Complete project navigation guide")
    print("   • Source code location mapping")
    print("   • Infrastructure setup roadmap")
    print("   • Quick reference panel")
    print("   • Important notes and tips")
    print("   • Color-coded sections")
    print("   • High-resolution PNG format")
    
    plt.close()

if __name__ == "__main__":
    main()
