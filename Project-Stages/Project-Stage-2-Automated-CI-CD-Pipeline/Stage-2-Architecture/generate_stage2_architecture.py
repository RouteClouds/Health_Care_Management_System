#!/usr/bin/env python3
"""
Stage 2 Architecture Diagram Generator
Healthcare Management System - Automated CI/CD Pipeline
Tech Stack: Jest + Selenium + SonarQube + Trivy
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch
import numpy as np

def create_stage2_architecture():
    # Create figure with high DPI for crisp PNG output
    fig, ax = plt.subplots(1, 1, figsize=(24, 16))
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')
    
    # Color scheme - Professional healthcare colors
    colors = {
        'github': '#24292e',
        'ci_cd': '#2ea44f',
        'testing': '#0969da',
        'quality': '#8250df',
        'security': '#cf222e',
        'docker': '#2496ed',
        'aws': '#ff9900',
        'k8s': '#326ce5',
        'app': '#28a745',
        'db': '#6f42c1',
        'monitoring': '#fd7e14'
    }
    
    # Title
    ax.text(50, 95, 'Stage 2: Automated CI/CD Pipeline Architecture', 
            fontsize=24, fontweight='bold', ha='center',
            bbox=dict(boxstyle="round,pad=0.5", facecolor='lightblue', alpha=0.8))
    
    ax.text(50, 92, 'Healthcare Management System - Jest + Selenium + SonarQube + Trivy Stack', 
            fontsize=16, ha='center', style='italic')
    
    # ============================================================================
    # SECTION 1: SOURCE CODE & VERSION CONTROL (Top Left)
    # ============================================================================
    
    # GitHub Repository
    github_box = FancyBboxPatch((2, 82), 18, 8, 
                               boxstyle="round,pad=0.3", 
                               facecolor=colors['github'], 
                               edgecolor='black', linewidth=2)
    ax.add_patch(github_box)
    ax.text(11, 87, '📁 GitHub Repository', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(11, 85, 'Healthcare Management System', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(11, 83, 'Source Code + Kubernetes Manifests', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Developer Workflow
    dev_box = FancyBboxPatch((2, 72), 18, 8, 
                            boxstyle="round,pad=0.3", 
                            facecolor='#6c757d', 
                            edgecolor='black', linewidth=2)
    ax.add_patch(dev_box)
    ax.text(11, 77, '👨‍💻 Developer Workflow', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(11, 75, 'git push → Triggers Pipeline', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(11, 73, 'Automated Testing & Deployment', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 2: CI/CD PIPELINE (Center Top)
    # ============================================================================
    
    # GitHub Actions Header
    actions_header = FancyBboxPatch((25, 82), 50, 8, 
                                   boxstyle="round,pad=0.3", 
                                   facecolor=colors['ci_cd'], 
                                   edgecolor='black', linewidth=2)
    ax.add_patch(actions_header)
    ax.text(50, 87, '🚀 GitHub Actions CI/CD Pipeline', fontsize=14, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(50, 85, 'Automated Testing, Quality Gates & Deployment', fontsize=11, 
            ha='center', va='center', color='white')
    ax.text(50, 83, 'Triggers: Push to main, Pull Requests', fontsize=10, 
            ha='center', va='center', color='white')
    
    # Pipeline Stages
    stages = [
        {'name': 'Security\nAnalysis', 'tool': 'Trivy\nFilesystem', 'x': 27, 'color': colors['security']},
        {'name': 'Unit\nTesting', 'tool': 'Jest\nCoverage', 'x': 37, 'color': colors['testing']},
        {'name': 'Code\nQuality', 'tool': 'SonarQube\nGates', 'x': 47, 'color': colors['quality']},
        {'name': 'Build\nImages', 'tool': 'Docker\nBuild', 'x': 57, 'color': colors['docker']},
        {'name': 'E2E\nTesting', 'tool': 'Selenium\nChrome/Firefox', 'x': 67, 'color': colors['testing']},
    ]
    
    for i, stage in enumerate(stages):
        # Stage box
        stage_box = FancyBboxPatch((stage['x']-3, 70), 8, 10, 
                                  boxstyle="round,pad=0.3", 
                                  facecolor=stage['color'], 
                                  edgecolor='black', linewidth=1.5)
        ax.add_patch(stage_box)
        
        # Stage text
        ax.text(stage['x']+1, 77, stage['name'], fontsize=10, fontweight='bold', 
                ha='center', va='center', color='white')
        ax.text(stage['x']+1, 74, stage['tool'], fontsize=8, 
                ha='center', va='center', color='white')
        
        # Port numbers for clarity
        if 'Testing' in stage['name']:
            ax.text(stage['x']+1, 71.5, '🔗 Port: 3000', fontsize=7, 
                    ha='center', va='center', color='white')
        
        # Arrows between stages
        if i < len(stages) - 1:
            arrow = ConnectionPatch((stage['x']+5, 75), (stages[i+1]['x']-3, 75), 
                                  "data", "data", 
                                  arrowstyle="->", shrinkA=0, shrinkB=0, 
                                  mutation_scale=20, fc="black", lw=2)
            ax.add_artist(arrow)
    
    # ============================================================================
    # SECTION 3: QUALITY & SECURITY TOOLS (Left Side)
    # ============================================================================
    
    # SonarQube Cloud
    sonar_box = FancyBboxPatch((2, 55), 18, 12, 
                              boxstyle="round,pad=0.3", 
                              facecolor=colors['quality'], 
                              edgecolor='black', linewidth=2)
    ax.add_patch(sonar_box)
    ax.text(11, 63, '📊 SonarQube Cloud', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(11, 61, 'Code Quality Analysis', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(11, 59, '• Coverage > 80%', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(11, 57.5, '• Quality Gate: A Rating', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(11, 56, '• Technical Debt Analysis', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Trivy Security Scanner
    trivy_box = FancyBboxPatch((2, 40), 18, 12, 
                              boxstyle="round,pad=0.3", 
                              facecolor=colors['security'], 
                              edgecolor='black', linewidth=2)
    ax.add_patch(trivy_box)
    ax.text(11, 48, '🛡️ Trivy Security', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(11, 46, 'Vulnerability Scanning', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(11, 44, '• Filesystem Scan', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(11, 42.5, '• Container Image Scan', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(11, 41, '• K8s Manifest Scan', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 4: CONTAINER REGISTRY (Center)
    # ============================================================================
    
    # Docker Hub
    docker_box = FancyBboxPatch((25, 55), 25, 12, 
                               boxstyle="round,pad=0.3", 
                               facecolor=colors['docker'], 
                               edgecolor='black', linewidth=2)
    ax.add_patch(docker_box)
    ax.text(37.5, 63, '🐳 Docker Hub Registry', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(37.5, 61, 'Container Images', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(37.5, 59, '• healthcare-frontend:latest', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(37.5, 57.5, '• healthcare-backend:latest', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(37.5, 56, '• Automated security scanning', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 5: AWS INFRASTRUCTURE (Right Side)
    # ============================================================================
    
    # AWS Cloud Header
    aws_header = FancyBboxPatch((78, 82), 20, 8, 
                               boxstyle="round,pad=0.3", 
                               facecolor=colors['aws'], 
                               edgecolor='black', linewidth=2)
    ax.add_patch(aws_header)
    ax.text(88, 87, '☁️ AWS Cloud', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(88, 85, 'us-east-1 Region', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(88, 83, 'Production Infrastructure', fontsize=9, 
            ha='center', va='center', color='white')
    
    # EKS Cluster
    eks_box = FancyBboxPatch((78, 55), 20, 25, 
                            boxstyle="round,pad=0.3", 
                            facecolor=colors['k8s'], 
                            edgecolor='black', linewidth=2)
    ax.add_patch(eks_box)
    ax.text(88, 75, '⚙️ EKS Cluster', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(88, 73, 'healthcare-cluster', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(88, 71, 'Kubernetes v1.32', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Node Groups
    ax.text(88, 68, '🖥️ Worker Nodes', fontsize=10, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(88, 66.5, '2x t3.medium instances', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(88, 65, 'Auto Scaling: 1-4 nodes', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Applications
    ax.text(88, 62, '📱 Applications', fontsize=10, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(88, 60.5, '• Frontend (React)', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(88, 59, '• Backend (Node.js)', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(88, 57.5, '• PostgreSQL Database', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(88, 56, '• Load Balancer (ALB)', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 6: DEPLOYMENT ENVIRONMENTS (Bottom)
    # ============================================================================
    
    # Environment Flow
    env_y = 35
    environments = [
        {'name': 'Development', 'desc': 'Auto-deploy\nevery push', 'x': 15, 'color': '#28a745'},
        {'name': 'Staging', 'desc': 'E2E Testing\nSelenium', 'x': 35, 'color': '#ffc107'},
        {'name': 'Production', 'desc': 'Manual Approval\nRequired', 'x': 55, 'color': '#dc3545'},
    ]
    
    ax.text(35, 42, '🌍 Deployment Environments', fontsize=14, fontweight='bold', 
            ha='center', va='center')
    
    for i, env in enumerate(environments):
        env_box = FancyBboxPatch((env['x']-7, env_y-5), 14, 10, 
                                boxstyle="round,pad=0.3", 
                                facecolor=env['color'], 
                                edgecolor='black', linewidth=2)
        ax.add_patch(env_box)
        
        ax.text(env['x'], env_y+2, env['name'], fontsize=11, fontweight='bold', 
                ha='center', va='center', color='white')
        ax.text(env['x'], env_y-1, env['desc'], fontsize=9, 
                ha='center', va='center', color='white')
        
        # Arrows between environments
        if i < len(environments) - 1:
            arrow = ConnectionPatch((env['x']+7, env_y), (environments[i+1]['x']-7, env_y), 
                                  "data", "data", 
                                  arrowstyle="->", shrinkA=0, shrinkB=0, 
                                  mutation_scale=20, fc="black", lw=2)
            ax.add_artist(arrow)
    
    # ============================================================================
    # SECTION 7: MONITORING & OBSERVABILITY (Bottom Right)
    # ============================================================================
    
    monitoring_box = FancyBboxPatch((75, 25), 23, 15, 
                                   boxstyle="round,pad=0.3", 
                                   facecolor=colors['monitoring'], 
                                   edgecolor='black', linewidth=2)
    ax.add_patch(monitoring_box)
    ax.text(86.5, 35, '📊 Monitoring & Alerts', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(86.5, 33, 'Pipeline & Application Health', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(86.5, 31, '• GitHub Actions Status', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(86.5, 29.5, '• SonarQube Quality Gates', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(86.5, 28, '• Trivy Security Alerts', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(86.5, 26.5, '• EKS Cluster Health', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 8: DATA FLOW ARROWS
    # ============================================================================
    
    # Main pipeline flow
    main_arrows = [
        # GitHub to Actions
        ((20, 86), (25, 86)),
        # Actions to Docker Hub
        ((50, 82), (37.5, 67)),
        # Docker Hub to EKS
        ((50, 61), (78, 67)),
        # SonarQube integration
        ((20, 61), (25, 75)),
        # Trivy integration
        ((20, 46), (25, 75)),
    ]
    
    for start, end in main_arrows:
        arrow = ConnectionPatch(start, end, "data", "data", 
                              arrowstyle="->", shrinkA=0, shrinkB=0, 
                              mutation_scale=20, fc="darkblue", lw=2.5)
        ax.add_artist(arrow)
    
    # ============================================================================
    # SECTION 9: LEGEND & TECH STACK
    # ============================================================================
    
    # Tech Stack Box
    tech_box = FancyBboxPatch((2, 5), 35, 18, 
                             boxstyle="round,pad=0.3", 
                             facecolor='lightgray', 
                             edgecolor='black', linewidth=2)
    ax.add_patch(tech_box)
    ax.text(19.5, 20, '🛠️ Stage 2 Tech Stack', fontsize=12, fontweight='bold', 
            ha='center', va='center')
    
    tech_items = [
        '✅ Unit Testing: Jest (mature, stable)',
        '✅ E2E Testing: Selenium WebDriver (cross-browser)',
        '✅ Code Quality: SonarQube (industry standard)',
        '✅ Security: Trivy (comprehensive scanning)',
        '✅ CI/CD: GitHub Actions (automated)',
        '✅ Containers: Docker + Docker Hub',
        '✅ Orchestration: Kubernetes (EKS)',
        '✅ Infrastructure: AWS (us-east-1)',
    ]
    
    for i, item in enumerate(tech_items):
        ax.text(4, 18 - i*1.5, item, fontsize=9, ha='left', va='center')
    
    # Benefits Box
    benefits_box = FancyBboxPatch((40, 5), 35, 18, 
                                 boxstyle="round,pad=0.3", 
                                 facecolor='lightgreen', 
                                 edgecolor='black', linewidth=2)
    ax.add_patch(benefits_box)
    ax.text(57.5, 20, '🎯 Stage 2 Benefits', fontsize=12, fontweight='bold', 
            ha='center', va='center')
    
    benefits = [
        '🚀 Automated testing & deployment',
        '🔒 Comprehensive security scanning',
        '📊 Code quality gates & compliance',
        '🌐 Cross-browser E2E testing',
        '⚡ Fast feedback loops (< 15 min)',
        '🛡️ Healthcare industry standards',
        '💰 Cost-optimized infrastructure',
        '📈 Scalable enterprise architecture',
    ]
    
    for i, benefit in enumerate(benefits):
        ax.text(42, 18 - i*1.5, benefit, fontsize=9, ha='left', va='center')
    
    # ============================================================================
    # SECTION 10: FINAL TOUCHES
    # ============================================================================
    
    # Version and timestamp
    ax.text(98, 2, 'Stage 2 Architecture v2.0\nGenerated: August 2025', 
            fontsize=8, ha='right', va='bottom', style='italic')
    
    # Cost information
    ax.text(2, 2, '💰 Estimated Cost: ~$63/month\n🔄 Pipeline Time: ~15 minutes', 
            fontsize=8, ha='left', va='bottom', style='italic')
    
    plt.tight_layout()
    return fig

def main():
    """Generate and save the Stage 2 architecture diagram"""
    print("🎨 Generating Stage 2 Architecture Diagram...")
    
    # Create the diagram
    fig = create_stage2_architecture()
    
    # Save as high-quality PNG
    output_file = 'Stage-2-Architecture-Diagram.png'
    fig.savefig(output_file, dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='none')
    
    print(f"✅ Architecture diagram saved as: {output_file}")
    print("📊 Diagram features:")
    print("   • Complete CI/CD pipeline visualization")
    print("   • Jest + Selenium + SonarQube + Trivy stack")
    print("   • AWS EKS infrastructure details")
    print("   • Deployment environments flow")
    print("   • Security and quality gates")
    print("   • High-resolution PNG format")
    print("   • No overlapping text")
    print("   • Professional healthcare color scheme")
    
    plt.close()

if __name__ == "__main__":
    main()
