#!/usr/bin/env python3
"""
Stage 1 Onboarding Workflow Diagram Generator
Healthcare Management System - New User Roadmap for Basic CI/CD
Visual guide for new users jumping into Stage 1

Created: August 2, 2025
Purpose: Help new users understand Stage 1 project structure and getting started
Focus: Basic CI/CD deployment with AWS EKS and Docker Hub
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch, Circle
import numpy as np

def create_stage1_onboarding_roadmap():
    """Create comprehensive onboarding roadmap for Stage 1"""
    
    # Create figure with high resolution
    fig, ax = plt.subplots(1, 1, figsize=(24, 18))
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')
    
    # Color scheme for different sections
    colors = {
        'start': '#28a745',      # Green for start
        'docs': '#007bff',       # Blue for documentation
        'tools': '#6f42c1',      # Purple for tools setup
        'scripts': '#fd7e14',    # Orange for scripts
        'deploy': '#dc3545',     # Red for deployment
        'verify': '#20c997',     # Teal for verification
        'path': '#ffc107',       # Yellow for pathway
        'important': '#e83e8c'   # Pink for important notes
    }
    
    # Main Title
    ax.text(50, 95, 'Stage 1: New User Onboarding Roadmap', 
            fontsize=28, fontweight='bold', ha='center',
            bbox=dict(boxstyle="round,pad=0.8", facecolor='lightblue', alpha=0.9))
    
    ax.text(50, 91, 'Healthcare Management System - Basic CI/CD Deployment Guide', 
            fontsize=18, ha='center', style='italic')
    
    ax.text(50, 88, 'Visual Navigation: AWS EKS + Docker Hub + Manual Scripts', 
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
    ax.text(12, 81, 'New to Stage 1?', fontsize=12, 
            ha='center', va='center', color='white')
    ax.text(12, 79, 'Follow the numbered path!', fontsize=10, 
            ha='center', va='center', color='white')
    
    # Step numbers (10 steps for Stage 1)
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
    ax.text(34, 75, 'docs/STAGE-1-INDEX.md', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(34, 73, 'Complete project overview', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(34, 71, 'Basic CI/CD with EKS', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Step 2: Architecture Overview
    doc2_box = FancyBboxPatch((55, 70), 18, 10, 
                             boxstyle="round,pad=0.3", 
                             facecolor=colors['docs'], 
                             edgecolor='black', linewidth=2)
    ax.add_patch(doc2_box)
    ax.text(64, 77, '2. View Architecture', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(64, 75, 'Stage-1-Architecture/', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(64, 73, 'Visual diagrams (PNG)', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(64, 71, 'AWS EKS workflow', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Step 3: Prerequisites Check
    doc3_box = FancyBboxPatch((75, 70), 18, 10, 
                             boxstyle="round,pad=0.3", 
                             facecolor=colors['docs'], 
                             edgecolor='black', linewidth=2)
    ax.add_patch(doc3_box)
    ax.text(84, 77, '3. Check Prerequisites', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(84, 75, 'docs/STAGE-1-MASTER-GUIDE.md', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(84, 73, 'AWS CLI, kubectl, eksctl', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(84, 71, 'Docker, AWS account', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 3: TOOLS SETUP (Step 4-5)
    # ============================================================================
    
    # Step 4: Install Tools
    tools1_box = FancyBboxPatch((75, 50), 18, 10, 
                               boxstyle="round,pad=0.3", 
                               facecolor=colors['tools'], 
                               edgecolor='black', linewidth=2)
    ax.add_patch(tools1_box)
    ax.text(84, 57, '4. Install Tools', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(84, 55, 'scripts/setup-tools.sh', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(84, 53, 'AWS CLI, kubectl, eksctl', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(84, 51, 'Docker setup', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Step 5: Configure AWS
    tools2_box = FancyBboxPatch((55, 50), 18, 10, 
                               boxstyle="round,pad=0.3", 
                               facecolor=colors['tools'], 
                               edgecolor='black', linewidth=2)
    ax.add_patch(tools2_box)
    ax.text(64, 57, '5. Configure AWS', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(64, 55, 'aws configure', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(64, 53, 'Access keys & region', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(64, 51, 'EKS permissions', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 4: INFRASTRUCTURE SETUP (Step 6-8)
    # ============================================================================
    
    # Step 6: Create EKS Cluster
    infra1_box = FancyBboxPatch((25, 50), 18, 10, 
                               boxstyle="round,pad=0.3", 
                               facecolor=colors['scripts'], 
                               edgecolor='black', linewidth=2)
    ax.add_patch(infra1_box)
    ax.text(34, 57, '6. Create EKS Cluster', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(34, 55, 'scripts/create-eks-cluster.sh', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(34, 53, 'healthcare-cluster', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(34, 51, '~15 minutes', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Step 7: Find Source Code
    infra2_box = FancyBboxPatch((2, 50), 18, 10, 
                               boxstyle="round,pad=0.3", 
                               facecolor=colors['scripts'], 
                               edgecolor='black', linewidth=2)
    ax.add_patch(infra2_box)
    ax.text(11, 57, '7. Locate Source Code', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(11, 55, '../../src-code/', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(11, 53, 'React frontend', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(11, 51, 'Node.js backend', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Step 8: Deploy Application
    infra3_box = FancyBboxPatch((2, 30), 18, 10, 
                               boxstyle="round,pad=0.3", 
                               facecolor=colors['deploy'], 
                               edgecolor='black', linewidth=2)
    ax.add_patch(infra3_box)
    ax.text(11, 37, '8. Deploy to EKS', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(11, 35, 'scripts/deploy-to-eks.sh', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(11, 33, 'Automated deployment', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(11, 31, '~10 minutes', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 5: VERIFICATION & CLEANUP (Step 9-10)
    # ============================================================================
    
    # Step 9: Verify Deployment
    verify1_box = FancyBboxPatch((25, 30), 18, 10, 
                                boxstyle="round,pad=0.3", 
                                facecolor=colors['verify'], 
                                edgecolor='black', linewidth=2)
    ax.add_patch(verify1_box)
    ax.text(34, 37, '9. Verify Deployment', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(34, 35, 'scripts/verify-deployment.sh', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(34, 33, 'Check pods & services', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(34, 31, 'Test application', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Step 10: Cleanup (Optional)
    verify2_box = FancyBboxPatch((55, 30), 18, 10, 
                                boxstyle="round,pad=0.3", 
                                facecolor=colors['verify'], 
                                edgecolor='black', linewidth=2)
    ax.add_patch(verify2_box)
    ax.text(64, 37, '10. Cleanup (Optional)', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(64, 35, 'scripts/cleanup.sh', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(64, 33, 'Remove all resources', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(64, 31, 'Save costs', fontsize=9, 
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
        ('Documentation Hub:', 'docs/STAGE-1-INDEX.md'),
        ('Master Guide:', 'docs/STAGE-1-MASTER-GUIDE.md'),
        ('Source Code:', '../../src-code/ (React + Node.js)'),
        ('Kubernetes Manifests:', 'k8s/ (deployments)'),
        ('Deployment Scripts:', 'scripts/deploy-to-eks.sh'),
        ('EKS Cluster Setup:', 'scripts/create-eks-cluster.sh'),
        ('Verification:', 'scripts/verify-deployment.sh'),
        ('Cleanup:', 'scripts/cleanup.sh'),
        ('Architecture Diagrams:', 'Stage-1-Architecture/*.png'),
        ('Troubleshooting:', 'docs/STAGE-1-TROUBLESHOOTING-REFERENCE.md'),
    ]
    
    y_pos = 19.5
    for title, path in ref_items:
        ax.text(4, y_pos, title, fontsize=10, fontweight='bold', 
                ha='left', va='center')
        ax.text(4, y_pos - 0.8, path, fontsize=9, 
                ha='left', va='center', color='#666666')
        y_pos -= 1.8
    
    # ============================================================================
    # SECTION 7: IMPORTANT NOTES (Right Side)
    # ============================================================================
    
    # Important Notes Box
    notes_box = FancyBboxPatch((45, 5), 30, 20, 
                              boxstyle="round,pad=0.5", 
                              facecolor='#fff3cd', 
                              edgecolor=colors['important'], linewidth=2)
    ax.add_patch(notes_box)
    
    ax.text(60, 22, 'Important Notes for Stage 1', fontsize=14, fontweight='bold', 
            ha='center', va='center', color=colors['important'])
    
    notes = [
        '1. Stage 1 = Basic CI/CD (no advanced testing)',
        '2. Source code shared with Stage 2 (../../src-code/)',
        '3. Manual deployment using scripts (not automated)',
        '4. AWS EKS cluster costs ~$0.30-0.50/hour',
        '5. Always cleanup resources to save costs',
        '6. EKS cluster creation takes ~15 minutes',
        '7. Deployment is simpler than Stage 2',
        '8. No Helm charts (direct kubectl)',
        '9. Basic monitoring only (no Prometheus)',
        '10. Perfect for learning Kubernetes basics!'
    ]
    
    y_pos = 19.5
    for note in notes:
        ax.text(46, y_pos, note, fontsize=9, 
                ha='left', va='center')
        y_pos -= 1.6
    
    # ============================================================================
    # SECTION 8: TECHNOLOGY STACK (Bottom Right)
    # ============================================================================
    
    # Technology Stack Box
    tech_box = FancyBboxPatch((77, 5), 21, 20, 
                             boxstyle="round,pad=0.5", 
                             facecolor='#e7f3ff', 
                             edgecolor='#007bff', linewidth=2)
    ax.add_patch(tech_box)
    
    ax.text(87.5, 22, 'Stage 1 Tech Stack', fontsize=14, fontweight='bold', 
            ha='center', va='center', color='#007bff')
    
    tech_items = [
        'Frontend: React + Vite',
        'Backend: Node.js + Express',
        'Database: PostgreSQL',
        'Containers: Docker',
        'Registry: Docker Hub',
        'Orchestration: Kubernetes',
        'Cloud: AWS EKS',
        'Deployment: Manual Scripts',
        'Monitoring: Basic (kubectl)',
        'Cost: ~$163/month'
    ]
    
    y_pos = 19.5
    for item in tech_items:
        ax.text(78, y_pos, f'• {item}', fontsize=9, 
                ha='left', va='center', color='#007bff')
        y_pos -= 1.6
    
    # ============================================================================
    # FINAL TOUCHES
    # ============================================================================
    
    # Add legend for colors
    legend_y = 85
    legend_items = [
        ('Documentation', colors['docs']),
        ('Tools Setup', colors['tools']),
        ('Scripts', colors['scripts']),
        ('Deployment', colors['deploy']),
        ('Verification', colors['verify'])
    ]
    
    for i, (label, color) in enumerate(legend_items):
        x_pos = 2 + i * 8
        legend_circle = Circle((x_pos, legend_y), 1, facecolor=color, 
                              edgecolor='black', linewidth=1)
        ax.add_patch(legend_circle)
        ax.text(x_pos, legend_y - 3, label, fontsize=8, 
                ha='center', va='center', rotation=45)
    
    # Version info
    ax.text(98, 2, 'Stage 1 Onboarding v1.0\nGenerated: August 2025', 
            fontsize=8, ha='right', va='bottom', style='italic')
    
    plt.tight_layout()
    return fig

def main():
    """Generate and save the Stage 1 onboarding roadmap diagram"""
    print("🗺️  Generating Stage 1 Onboarding Roadmap...")
    
    # Create the diagram
    fig = create_stage1_onboarding_roadmap()
    
    # Save as high-quality PNG
    output_file = 'Stage-1-Onboarding-Roadmap.png'
    fig.savefig(output_file, dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='none')
    
    print(f"✅ Stage 1 onboarding roadmap saved as: {output_file}")
    print("🎯 Features:")
    print("   • 10-step visual pathway for new users")
    print("   • Complete project navigation guide")
    print("   • AWS EKS deployment workflow")
    print("   • Script-based deployment process")
    print("   • Quick reference panel")
    print("   • Important notes for Stage 1")
    print("   • Technology stack overview")
    print("   • High-resolution PNG format")
    
    plt.show()
    plt.close()

if __name__ == "__main__":
    main()
