#!/usr/bin/env python3
"""
CI/CD Pipeline Workflow Visualization
Healthcare Management System - Stage 2

This script creates comprehensive visual diagrams showing:
1. Pipeline trigger workflow
2. Pipeline stages and flow
3. Branch protection integration
4. Deployment process
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch
import numpy as np
from datetime import datetime
import os

# Set up the plotting style
plt.style.use('default')
plt.rcParams['figure.facecolor'] = 'white'
plt.rcParams['axes.facecolor'] = 'white'

def create_pipeline_trigger_diagram():
    """Create a diagram showing how the CI/CD pipeline gets triggered"""
    
    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 12)
    ax.axis('off')
    
    # Title
    ax.text(5, 11.5, 'CI/CD Pipeline Trigger Workflow', 
            fontsize=20, fontweight='bold', ha='center')
    ax.text(5, 11, 'Healthcare Management System - Stage 2', 
            fontsize=14, ha='center', style='italic')
    
    # Developer Actions (Left Side)
    dev_box = FancyBboxPatch((0.5, 8.5), 2, 2.5, 
                            boxstyle="round,pad=0.1", 
                            facecolor='lightblue', 
                            edgecolor='blue', linewidth=2)
    ax.add_patch(dev_box)
    ax.text(1.5, 10, 'Developer\nActions', fontsize=12, fontweight='bold', ha='center')
    ax.text(1.5, 9.2, '• Create branch\n• Make changes\n• Commit code\n• Push to GitHub', 
            fontsize=10, ha='center')
    
    # Trigger Events (Center)
    trigger1 = FancyBboxPatch((3.5, 9.5), 3, 0.8, 
                             boxstyle="round,pad=0.05", 
                             facecolor='yellow', 
                             edgecolor='orange', linewidth=2)
    ax.add_patch(trigger1)
    ax.text(5, 9.9, 'Trigger 1: Pull Request Created', 
            fontsize=11, fontweight='bold', ha='center')
    
    trigger2 = FancyBboxPatch((3.5, 8.5), 3, 0.8, 
                             boxstyle="round,pad=0.05", 
                             facecolor='yellow', 
                             edgecolor='orange', linewidth=2)
    ax.add_patch(trigger2)
    ax.text(5, 8.9, 'Trigger 2: Merge to Main Branch', 
            fontsize=11, fontweight='bold', ha='center')
    
    # Pipeline Stages (Right Side)
    stage1 = FancyBboxPatch((7.5, 9.5), 2, 0.8, 
                           boxstyle="round,pad=0.05", 
                           facecolor='lightgreen', 
                           edgecolor='green', linewidth=2)
    ax.add_patch(stage1)
    ax.text(8.5, 9.9, 'Quality Checks\nOnly', fontsize=10, fontweight='bold', ha='center')
    
    stage2 = FancyBboxPatch((7.5, 8.5), 2, 0.8, 
                           boxstyle="round,pad=0.05", 
                           facecolor='lightcoral', 
                           edgecolor='red', linewidth=2)
    ax.add_patch(stage2)
    ax.text(8.5, 8.9, 'Full Pipeline\n(Build + Deploy)', fontsize=10, fontweight='bold', ha='center')
    
    # Arrows
    ax.arrow(2.5, 9.7, 0.8, 0, head_width=0.1, head_length=0.1, fc='black', ec='black')
    ax.arrow(2.5, 9.0, 0.8, 0, head_width=0.1, head_length=0.1, fc='black', ec='black')
    ax.arrow(6.5, 9.9, 0.8, 0, head_width=0.1, head_length=0.1, fc='green', ec='green')
    ax.arrow(6.5, 8.9, 0.8, 0, head_width=0.1, head_length=0.1, fc='red', ec='red')
    
    # Detailed Pipeline Flow (Bottom Section)
    ax.text(5, 7.5, 'Detailed Pipeline Flow', fontsize=16, fontweight='bold', ha='center')
    
    # Stage 1: Quality Gates
    quality_box = FancyBboxPatch((0.5, 5.5), 2.8, 1.5, 
                                boxstyle="round,pad=0.1", 
                                facecolor='#E8F5E8', 
                                edgecolor='green', linewidth=2)
    ax.add_patch(quality_box)
    ax.text(1.9, 6.7, 'Stage 1: Quality Gates', fontsize=11, fontweight='bold', ha='center')
    ax.text(1.9, 6.2, '🛡️ Security Analysis\n🧪 Unit Testing\n📊 Code Quality', 
            fontsize=9, ha='center')
    ax.text(1.9, 5.7, '⏱️ ~4-5 minutes', fontsize=8, ha='center', style='italic')
    
    # Stage 2: Build Process
    build_box = FancyBboxPatch((3.6, 5.5), 2.8, 1.5, 
                              boxstyle="round,pad=0.1", 
                              facecolor='#FFF8E1', 
                              edgecolor='orange', linewidth=2)
    ax.add_patch(build_box)
    ax.text(5, 6.7, 'Stage 2: Build Process', fontsize=11, fontweight='bold', ha='center')
    ax.text(5, 6.2, '🖥️ Frontend Build\n⚙️ Backend Build\n📤 Push Images', 
            fontsize=9, ha='center')
    ax.text(5, 5.7, '⏱️ ~4-5 minutes', fontsize=8, ha='center', style='italic')
    
    # Stage 3: Deployment
    deploy_box = FancyBboxPatch((6.7, 5.5), 2.8, 1.5, 
                               boxstyle="round,pad=0.1", 
                               facecolor='#E3F2FD', 
                               edgecolor='blue', linewidth=2)
    ax.add_patch(deploy_box)
    ax.text(8.1, 6.7, 'Stage 3: Deployment', fontsize=11, fontweight='bold', ha='center')
    ax.text(8.1, 6.2, '🧪 Staging Deploy\n✅ Testing\n🌍 Production Deploy', 
            fontsize=9, ha='center')
    ax.text(8.1, 5.7, '⏱️ ~5-6 minutes', fontsize=8, ha='center', style='italic')
    
    # Flow arrows between stages
    ax.arrow(3.3, 6.25, 0.2, 0, head_width=0.1, head_length=0.05, fc='black', ec='black')
    ax.arrow(6.4, 6.25, 0.2, 0, head_width=0.1, head_length=0.05, fc='black', ec='black')
    
    # Branch Protection Integration
    protection_box = FancyBboxPatch((1, 3.5), 8, 1.5, 
                                   boxstyle="round,pad=0.1", 
                                   facecolor='#FFEBEE', 
                                   edgecolor='red', linewidth=2)
    ax.add_patch(protection_box)
    ax.text(5, 4.7, 'Branch Protection Integration', fontsize=12, fontweight='bold', ha='center')
    ax.text(5, 4.2, '🔒 No direct pushes to main  •  ✅ All checks must pass  •  👥 Reviews required', 
            fontsize=10, ha='center')
    ax.text(5, 3.8, '🚫 Merge blocked until: Security ✅ + Tests ✅ + Quality ✅ + Review ✅', 
            fontsize=9, ha='center')
    
    # Timeline
    ax.text(5, 2.8, 'Total Pipeline Time: ~14-16 minutes', 
            fontsize=12, fontweight='bold', ha='center', 
            bbox=dict(boxstyle="round,pad=0.3", facecolor='lightgray'))
    
    # Real-world example
    ax.text(5, 2, 'Example: "Add User Dashboard" → PR Created → Quality Checks (4 min) → Review & Merge → Full Pipeline (12 min) → Live! 🎉', 
            fontsize=10, ha='center', style='italic')
    
    # Legend
    legend_elements = [
        patches.Patch(color='lightblue', label='Developer Actions'),
        patches.Patch(color='yellow', label='Pipeline Triggers'),
        patches.Patch(color='lightgreen', label='Quality Checks Only'),
        patches.Patch(color='lightcoral', label='Full Pipeline'),
    ]
    ax.legend(handles=legend_elements, loc='lower right', bbox_to_anchor=(0.98, 0.02))
    
    plt.tight_layout()
    return fig

def create_detailed_pipeline_stages():
    """Create a detailed diagram of pipeline stages"""
    
    fig, ax = plt.subplots(1, 1, figsize=(18, 14))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 14)
    ax.axis('off')
    
    # Title
    ax.text(6, 13.5, 'Detailed CI/CD Pipeline Stages', 
            fontsize=20, fontweight='bold', ha='center')
    ax.text(6, 13, 'Healthcare Management System - Complete Workflow', 
            fontsize=14, ha='center', style='italic')
    
    # Stage 1: Quality Gates (Detailed)
    stage1_box = FancyBboxPatch((0.5, 10), 3.5, 2.5, 
                               boxstyle="round,pad=0.1", 
                               facecolor='#E8F5E8', 
                               edgecolor='green', linewidth=3)
    ax.add_patch(stage1_box)
    ax.text(2.25, 12, 'Stage 1: Quality Gates', fontsize=14, fontweight='bold', ha='center')
    
    # Security Analysis
    sec_box = FancyBboxPatch((0.7, 11.3), 1, 0.6, 
                            boxstyle="round,pad=0.05", 
                            facecolor='white', 
                            edgecolor='green', linewidth=1)
    ax.add_patch(sec_box)
    ax.text(1.2, 11.6, '🛡️ Security\nAnalysis', fontsize=9, ha='center', fontweight='bold')
    
    # Unit Testing
    test_box = FancyBboxPatch((1.8, 11.3), 1, 0.6, 
                             boxstyle="round,pad=0.05", 
                             facecolor='white', 
                             edgecolor='green', linewidth=1)
    ax.add_patch(test_box)
    ax.text(2.3, 11.6, '🧪 Unit\nTesting', fontsize=9, ha='center', fontweight='bold')
    
    # Code Quality
    quality_box = FancyBboxPatch((2.9, 11.3), 1, 0.6, 
                                boxstyle="round,pad=0.05", 
                                facecolor='white', 
                                edgecolor='green', linewidth=1)
    ax.add_patch(quality_box)
    ax.text(3.4, 11.6, '📊 Code\nQuality', fontsize=9, ha='center', fontweight='bold')
    
    ax.text(2.25, 10.8, 'Tools: Trivy, Jest, SonarQube', fontsize=10, ha='center', style='italic')
    ax.text(2.25, 10.5, '⏱️ Duration: 4-5 minutes', fontsize=10, ha='center')
    ax.text(2.25, 10.2, 'Triggers: PR creation/update', fontsize=9, ha='center')
    
    # Stage 2: Build Process (Detailed)
    stage2_box = FancyBboxPatch((4.25, 10), 3.5, 2.5, 
                               boxstyle="round,pad=0.1", 
                               facecolor='#FFF8E1', 
                               edgecolor='orange', linewidth=3)
    ax.add_patch(stage2_box)
    ax.text(6, 12, 'Stage 2: Build Process', fontsize=14, fontweight='bold', ha='center')
    
    # Frontend Build
    frontend_box = FancyBboxPatch((4.45, 11.3), 1.5, 0.6, 
                                 boxstyle="round,pad=0.05", 
                                 facecolor='white', 
                                 edgecolor='orange', linewidth=1)
    ax.add_patch(frontend_box)
    ax.text(5.2, 11.6, '🖥️ Frontend\nBuild', fontsize=9, ha='center', fontweight='bold')
    
    # Backend Build
    backend_box = FancyBboxPatch((6.05, 11.3), 1.5, 0.6, 
                                boxstyle="round,pad=0.05", 
                                facecolor='white', 
                                edgecolor='orange', linewidth=1)
    ax.add_patch(backend_box)
    ax.text(6.8, 11.6, '⚙️ Backend\nBuild', fontsize=9, ha='center', fontweight='bold')
    
    ax.text(6, 10.8, 'Docker Images: React + Node.js', fontsize=10, ha='center', style='italic')
    ax.text(6, 10.5, '⏱️ Duration: 4-5 minutes', fontsize=10, ha='center')
    ax.text(6, 10.2, 'Triggers: Merge to main branch', fontsize=9, ha='center')
    
    # Stage 3: Deployment (Detailed)
    stage3_box = FancyBboxPatch((8, 10), 3.5, 2.5, 
                               boxstyle="round,pad=0.1", 
                               facecolor='#E3F2FD', 
                               edgecolor='blue', linewidth=3)
    ax.add_patch(stage3_box)
    ax.text(9.75, 12, 'Stage 3: Deployment', fontsize=14, fontweight='bold', ha='center')
    
    # Staging
    staging_box = FancyBboxPatch((8.2, 11.3), 1.5, 0.6, 
                                boxstyle="round,pad=0.05", 
                                facecolor='white', 
                                edgecolor='blue', linewidth=1)
    ax.add_patch(staging_box)
    ax.text(8.95, 11.6, '🧪 Staging\nDeploy', fontsize=9, ha='center', fontweight='bold')
    
    # Production
    prod_box = FancyBboxPatch((9.8, 11.3), 1.5, 0.6, 
                             boxstyle="round,pad=0.05", 
                             facecolor='white', 
                             edgecolor='blue', linewidth=1)
    ax.add_patch(prod_box)
    ax.text(10.55, 11.6, '🌍 Production\nDeploy', fontsize=9, ha='center', fontweight='bold')
    
    ax.text(9.75, 10.8, 'Platform: Kubernetes (EKS)', fontsize=10, ha='center', style='italic')
    ax.text(9.75, 10.5, '⏱️ Duration: 5-6 minutes', fontsize=10, ha='center')
    ax.text(9.75, 10.2, 'Strategy: Rolling updates', fontsize=9, ha='center')
    
    # Flow arrows between stages
    ax.arrow(4, 11.25, 0.2, 0, head_width=0.1, head_length=0.05, fc='black', ec='black', linewidth=2)
    ax.arrow(7.75, 11.25, 0.2, 0, head_width=0.1, head_length=0.05, fc='black', ec='black', linewidth=2)
    
    # Monitoring and Feedback Section
    monitor_box = FancyBboxPatch((1, 7.5), 10, 1.8, 
                                boxstyle="round,pad=0.1", 
                                facecolor='#F3E5F5', 
                                edgecolor='purple', linewidth=2)
    ax.add_patch(monitor_box)
    ax.text(6, 8.8, 'Monitoring & Feedback', fontsize=14, fontweight='bold', ha='center')
    
    # Monitoring tools
    ax.text(2.5, 8.3, '📊 GitHub Actions\nReal-time logs', fontsize=10, ha='center')
    ax.text(6, 8.3, '📱 Notifications\nEmail + Slack', fontsize=10, ha='center')
    ax.text(9.5, 8.3, '🔍 Health Checks\nKubernetes', fontsize=10, ha='center')
    
    ax.text(6, 7.8, 'Commands: gh run list | gh run watch | gh pr checks', 
            fontsize=10, ha='center', style='italic')
    
    # Success Metrics
    metrics_box = FancyBboxPatch((1, 5.5), 10, 1.5, 
                                boxstyle="round,pad=0.1", 
                                facecolor='#E8F5E8', 
                                edgecolor='green', linewidth=2)
    ax.add_patch(metrics_box)
    ax.text(6, 6.7, 'Success Metrics & Outcomes', fontsize=14, fontweight='bold', ha='center')
    
    ax.text(3, 6.2, '✅ Security: 0 vulnerabilities\n✅ Tests: 95%+ coverage\n✅ Quality: Grade A', 
            fontsize=10, ha='center')
    ax.text(9, 6.2, '🚀 Deployment: <15 min\n🌍 Uptime: 99.9%\n📊 Performance: Optimal', 
            fontsize=10, ha='center')
    
    ax.text(6, 5.8, 'Result: Secure, tested, high-quality code deployed automatically! 🎉', 
            fontsize=11, ha='center', fontweight='bold')
    
    # Real Example Timeline
    timeline_box = FancyBboxPatch((1, 3), 10, 2, 
                                 boxstyle="round,pad=0.1", 
                                 facecolor='#FFFDE7', 
                                 edgecolor='#F57F17', linewidth=2)
    ax.add_patch(timeline_box)
    ax.text(6, 4.7, 'Real Example: "Add User Dashboard Feature"', 
            fontsize=14, fontweight='bold', ha='center')
    
    # Timeline steps
    times = ['0:00', '0:30', '4:15', '4:20', '8:35', '8:40', '14:30']
    events = ['PR Created', 'Quality Starts', 'Quality ✅', 'Build Starts', 'Build ✅', 'Deploy Starts', 'Live! 🎉']
    
    for i, (time, event) in enumerate(zip(times, events)):
        x_pos = 1.5 + i * 1.3
        ax.text(x_pos, 4.2, time, fontsize=9, ha='center', fontweight='bold')
        ax.text(x_pos, 3.8, event, fontsize=8, ha='center')
        if i < len(times) - 1:
            ax.arrow(x_pos + 0.4, 4, 0.5, 0, head_width=0.05, head_length=0.03, fc='orange', ec='orange')
    
    ax.text(6, 3.3, 'Total Time: 14 minutes 30 seconds from code to production!', 
            fontsize=11, ha='center', fontweight='bold', style='italic')
    
    # Branch Protection Reminder
    ax.text(6, 2.5, '🔒 Branch Protection Ensures: No broken code reaches users!', 
            fontsize=12, ha='center', fontweight='bold',
            bbox=dict(boxstyle="round,pad=0.3", facecolor='lightcoral', alpha=0.7))
    
    # Footer
    ax.text(6, 1.8, f'Generated on: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}', 
            fontsize=10, ha='center', style='italic')
    ax.text(6, 1.5, 'Healthcare Management System - Stage 2 CI/CD Pipeline', 
            fontsize=10, ha='center')
    
    plt.tight_layout()
    return fig

def main():
    """Generate all CI/CD pipeline diagrams"""
    
    print("🎨 Generating CI/CD Pipeline Workflow Diagrams...")
    
    # Create output directory
    output_dir = "cicd-pipeline-diagrams"
    os.makedirs(output_dir, exist_ok=True)
    
    # Generate Pipeline Trigger Diagram
    print("📊 Creating Pipeline Trigger Workflow diagram...")
    fig1 = create_pipeline_trigger_diagram()
    trigger_path = os.path.join(output_dir, "pipeline-trigger-workflow.png")
    fig1.savefig(trigger_path, dpi=300, bbox_inches='tight', facecolor='white')
    plt.close(fig1)
    print(f"✅ Saved: {trigger_path}")
    
    # Generate Detailed Pipeline Stages Diagram
    print("📊 Creating Detailed Pipeline Stages diagram...")
    fig2 = create_detailed_pipeline_stages()
    stages_path = os.path.join(output_dir, "detailed-pipeline-stages.png")
    fig2.savefig(stages_path, dpi=300, bbox_inches='tight', facecolor='white')
    plt.close(fig2)
    print(f"✅ Saved: {stages_path}")
    
    print("\n🎉 All diagrams generated successfully!")
    print(f"📁 Location: {os.path.abspath(output_dir)}")
    print("\n📋 Generated Files:")
    print(f"  1. {trigger_path}")
    print(f"  2. {stages_path}")
    
    return output_dir

if __name__ == "__main__":
    output_directory = main()
