#!/usr/bin/env python3
"""
Enhanced Stage 2 Architecture Diagram Generator
Healthcare Management System - Complete CI/CD Pipeline with Monitoring
Includes: Jest + Selenium + SonarQube + Trivy + Prometheus + Grafana + Helm

Updated: August 2, 2025 - Phase D Complete
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch
import numpy as np

def create_enhanced_stage2_architecture():
    """Create enhanced Stage 2 architecture diagram with all Phase D components"""
    
    # Create figure and axis
    fig, ax = plt.subplots(1, 1, figsize=(20, 14))
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')
    
    # Color scheme
    colors = {
        'github': '#24292e',
        'actions': '#2088ff',
        'testing': '#28a745',
        'quality': '#6f42c1',
        'security': '#dc3545',
        'registry': '#0db7ed',
        'k8s': '#326ce5',
        'aws': '#ff9900',
        'monitoring': '#e6522c',
        'helm': '#0f1689',
        'grafana': '#ff6b35',
        'db': '#336791'
    }
    
    # Title
    ax.text(50, 95, 'Stage 2: Enhanced CI/CD Pipeline Architecture', 
            fontsize=24, fontweight='bold', ha='center',
            bbox=dict(boxstyle="round,pad=0.5", facecolor='lightblue', alpha=0.8))
    
    ax.text(50, 92, 'Healthcare Management System - Complete Stack with Monitoring & Helm', 
            fontsize=16, ha='center', style='italic')
    
    ax.text(50, 89, 'Jest + Selenium + SonarQube + Trivy + Prometheus + Grafana + Helm', 
            fontsize=12, ha='center', color='#666666')
    
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
    ax.text(11, 83, 'Source Code + Helm Charts', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 2: CI/CD PIPELINE (Center Top)
    # ============================================================================
    
    # GitHub Actions
    actions_box = FancyBboxPatch((25, 82), 50, 8, 
                                boxstyle="round,pad=0.3", 
                                facecolor=colors['actions'], 
                                edgecolor='black', linewidth=2)
    ax.add_patch(actions_box)
    ax.text(50, 87, '🚀 GitHub Actions CI/CD Pipeline', fontsize=14, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(50, 85, '9 Jobs: Security → Unit Tests → Quality → Build → E2E → Deploy', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(50, 83, 'Multi-Environment: Development → Staging → Production', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 3: TESTING LAYER (Upper Middle)
    # ============================================================================
    
    # Jest Unit Testing
    jest_box = FancyBboxPatch((2, 70), 15, 10, 
                             boxstyle="round,pad=0.3", 
                             facecolor=colors['testing'], 
                             edgecolor='black', linewidth=2)
    ax.add_patch(jest_box)
    ax.text(9.5, 76, '🧪 Jest Testing', fontsize=11, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(9.5, 74, 'Unit Tests', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(9.5, 72, '• Backend (Node.js)', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(9.5, 71, '• 80% Coverage', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Vitest Frontend Testing
    vitest_box = FancyBboxPatch((19, 70), 15, 10, 
                               boxstyle="round,pad=0.3", 
                               facecolor='#9333ea', 
                               edgecolor='black', linewidth=2)
    ax.add_patch(vitest_box)
    ax.text(26.5, 76, '⚡ Vitest Testing', fontsize=11, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(26.5, 74, 'Frontend Tests', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(26.5, 72, '• React Components', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(26.5, 71, '• 80% Coverage', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Selenium E2E Testing
    selenium_box = FancyBboxPatch((36, 70), 15, 10, 
                                 boxstyle="round,pad=0.3", 
                                 facecolor='#43b02a', 
                                 edgecolor='black', linewidth=2)
    ax.add_patch(selenium_box)
    ax.text(43.5, 76, '🌐 Selenium E2E', fontsize=11, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(43.5, 74, 'Cross-Browser', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(43.5, 72, '• Chrome + Firefox', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(43.5, 71, '• Healthcare Workflows', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 4: QUALITY & SECURITY (Middle)
    # ============================================================================
    
    # SonarQube Quality Gates
    sonar_box = FancyBboxPatch((53, 70), 15, 10, 
                              boxstyle="round,pad=0.3", 
                              facecolor=colors['quality'], 
                              edgecolor='black', linewidth=2)
    ax.add_patch(sonar_box)
    ax.text(60.5, 76, '📊 SonarQube', fontsize=11, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(60.5, 74, 'Quality Gates', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(60.5, 72, '• A-Rating Required', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(60.5, 71, '• HIPAA Compliance', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Trivy Security Scanning
    trivy_box = FancyBboxPatch((70, 70), 15, 10, 
                              boxstyle="round,pad=0.3", 
                              facecolor=colors['security'], 
                              edgecolor='black', linewidth=2)
    ax.add_patch(trivy_box)
    ax.text(77.5, 76, '🛡️ Trivy Security', fontsize=11, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(77.5, 74, 'Vulnerability Scan', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(77.5, 72, '• Zero Critical CVEs', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(77.5, 71, '• Container Security', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 5: CONTAINER REGISTRY (Middle Right)
    # ============================================================================
    
    # Docker Hub
    registry_box = FancyBboxPatch((87, 70), 11, 10, 
                                 boxstyle="round,pad=0.3", 
                                 facecolor=colors['registry'], 
                                 edgecolor='black', linewidth=2)
    ax.add_patch(registry_box)
    ax.text(92.5, 76, '🐳 Docker Hub', fontsize=11, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(92.5, 74, 'Container Registry', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(92.5, 72, '• Frontend Image', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(92.5, 71, '• Backend Image', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 6: HELM DEPLOYMENT LAYER (Upper Infrastructure)
    # ============================================================================
    
    # Helm Charts
    helm_box = FancyBboxPatch((2, 55), 96, 8, 
                             boxstyle="round,pad=0.3", 
                             facecolor=colors['helm'], 
                             edgecolor='black', linewidth=2)
    ax.add_patch(helm_box)
    ax.text(50, 60, '⚙️ Helm Charts - Multi-Environment Deployment', fontsize=14, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(20, 57, '🔧 Development', fontsize=11, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(20, 56, 'Minimal resources, Debug enabled', fontsize=9, 
            ha='center', va='center', color='white')
    
    ax.text(50, 57, '🧪 Staging', fontsize=11, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(50, 56, 'Production-like testing', fontsize=9, 
            ha='center', va='center', color='white')
    
    ax.text(80, 57, '🏭 Production', fontsize=11, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(80, 56, 'High availability, Auto-scaling', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 7: KUBERNETES INFRASTRUCTURE (Middle)
    # ============================================================================
    
    # EKS Cluster
    eks_box = FancyBboxPatch((2, 35), 45, 18, 
                            boxstyle="round,pad=0.3", 
                            facecolor=colors['k8s'], 
                            edgecolor='black', linewidth=2)
    ax.add_patch(eks_box)
    ax.text(24.5, 48, '☸️ AWS EKS Cluster', fontsize=14, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(24.5, 46, 'healthcare-cluster (us-east-1)', fontsize=11, 
            ha='center', va='center', color='white')
    
    # Application Pods
    ax.text(12, 43, '🎯 Frontend Pods', fontsize=10, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(12, 41, 'React Application', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(12, 39, 'Auto-scaling: 2-10', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(12, 37, 'Health checks', fontsize=9, 
            ha='center', va='center', color='white')
    
    ax.text(37, 43, '⚡ Backend Pods', fontsize=10, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(37, 41, 'Node.js API', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(37, 39, 'Auto-scaling: 3-15', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(37, 37, 'Load balancing', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 8: ENHANCED MONITORING STACK (Right Side)
    # ============================================================================
    
    # Prometheus Monitoring
    prometheus_box = FancyBboxPatch((53, 42), 20, 11, 
                                   boxstyle="round,pad=0.3", 
                                   facecolor=colors['monitoring'], 
                                   edgecolor='black', linewidth=2)
    ax.add_patch(prometheus_box)
    ax.text(63, 49, '📊 Prometheus', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(63, 47, 'Healthcare Metrics', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(63, 45, '• Patient data access', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(63, 44, '• API performance', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(63, 43, '• HIPAA compliance alerts', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Grafana Dashboards
    grafana_box = FancyBboxPatch((75, 42), 23, 11, 
                                boxstyle="round,pad=0.3", 
                                facecolor=colors['grafana'], 
                                edgecolor='black', linewidth=2)
    ax.add_patch(grafana_box)
    ax.text(86.5, 49, '📈 Grafana', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(86.5, 47, 'Real-time Dashboards', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(86.5, 45, '• Healthcare KPIs', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(86.5, 44, '• System health overview', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(86.5, 43, '• Business metrics', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 9: DATABASE & STORAGE (Bottom Left)
    # ============================================================================
    
    # PostgreSQL Database
    db_box = FancyBboxPatch((2, 20), 20, 12, 
                           boxstyle="round,pad=0.3", 
                           facecolor=colors['db'], 
                           edgecolor='black', linewidth=2)
    ax.add_patch(db_box)
    ax.text(12, 28, '🗄️ PostgreSQL', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(12, 26, 'Healthcare Database', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(12, 24, '• Patient records', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(12, 22.5, '• Appointments', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(12, 21, '• Encrypted at rest', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 10: INFRASTRUCTURE AUTOMATION (Bottom Center)
    # ============================================================================
    
    # Automation Scripts
    automation_box = FancyBboxPatch((25, 20), 48, 12, 
                                   boxstyle="round,pad=0.3", 
                                   facecolor='#17a2b8', 
                                   edgecolor='black', linewidth=2)
    ax.add_patch(automation_box)
    ax.text(49, 28, '🤖 Infrastructure Automation', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(49, 26, 'Validation & Deployment Scripts', fontsize=10, 
            ha='center', va='center', color='white')
    
    ax.text(35, 24, '✅ validate-infrastructure.sh', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(35, 22.5, 'Complete validation checks', fontsize=8, 
            ha='center', va='center', color='white')
    ax.text(35, 21, 'K8s, Helm, configs', fontsize=8, 
            ha='center', va='center', color='white')
    
    ax.text(63, 24, '🚀 deploy-healthcare.sh', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(63, 22.5, 'Multi-env deployment', fontsize=8, 
            ha='center', va='center', color='white')
    ax.text(63, 21, 'Dry-run capabilities', fontsize=8, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # SECTION 11: COMPLIANCE & SECURITY (Bottom Right)
    # ============================================================================
    
    # Compliance
    compliance_box = FancyBboxPatch((75, 20), 23, 12, 
                                   boxstyle="round,pad=0.3", 
                                   facecolor='#6c757d', 
                                   edgecolor='black', linewidth=2)
    ax.add_patch(compliance_box)
    ax.text(86.5, 28, '🔒 Healthcare Compliance', fontsize=12, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(86.5, 26, 'Industry Standards', fontsize=10, 
            ha='center', va='center', color='white')
    ax.text(86.5, 24, '• HIPAA Compliance', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(86.5, 22.5, '• FDA Requirements', fontsize=9, 
            ha='center', va='center', color='white')
    ax.text(86.5, 21, '• SOX Compliance', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # ARROWS AND CONNECTIONS
    # ============================================================================
    
    # GitHub to Actions
    ax.arrow(20, 86, 4, 0, head_width=1, head_length=1, fc='black', ec='black')
    
    # Actions to Testing Layer
    ax.arrow(30, 82, 0, -1, head_width=1, head_length=0.5, fc='black', ec='black')
    ax.arrow(50, 82, 0, -1, head_width=1, head_length=0.5, fc='black', ec='black')
    ax.arrow(70, 82, 0, -1, head_width=1, head_length=0.5, fc='black', ec='black')
    
    # Testing to Registry
    ax.arrow(85, 75, 2, 0, head_width=1, head_length=1, fc='black', ec='black')
    
    # Registry to Helm
    ax.arrow(92.5, 70, 0, -6, head_width=1, head_length=0.5, fc='black', ec='black')
    
    # Helm to EKS
    ax.arrow(25, 55, 0, -1, head_width=1, head_length=0.5, fc='black', ec='black')
    
    # EKS to Monitoring
    ax.arrow(47, 44, 5, 3, head_width=1, head_length=1, fc='black', ec='black')
    
    # EKS to Database
    ax.arrow(24.5, 35, -2, -2, head_width=1, head_length=1, fc='black', ec='black')
    
    # ============================================================================
    # LEGEND
    # ============================================================================
    
    legend_box = FancyBboxPatch((2, 2), 96, 15, 
                               boxstyle="round,pad=0.3", 
                               facecolor='#f8f9fa', 
                               edgecolor='black', linewidth=1)
    ax.add_patch(legend_box)
    
    ax.text(50, 14, '📋 Stage 2 Enhanced Architecture Components', fontsize=14, fontweight='bold', 
            ha='center', va='center')
    
    # Legend items
    legend_items = [
        ('🔄 CI/CD Flow:', 'GitHub → Actions → Testing → Quality → Security → Registry → Helm → EKS'),
        ('🧪 Testing Stack:', 'Jest (Backend) + Vitest (Frontend) + Selenium (E2E) - 80% Coverage'),
        ('📊 Quality & Security:', 'SonarQube A-Rating + Trivy Zero CVEs + HIPAA Compliance'),
        ('⚙️ Infrastructure:', 'Helm Multi-Environment + Prometheus Monitoring + Grafana Dashboards'),
        ('🤖 Automation:', 'Infrastructure Validation + Automated Deployment + Health Checks')
    ]
    
    y_pos = 11
    for title, description in legend_items:
        ax.text(4, y_pos, title, fontsize=10, fontweight='bold', ha='left', va='center')
        ax.text(20, y_pos, description, fontsize=9, ha='left', va='center')
        y_pos -= 1.8
    
    # Save the diagram
    plt.tight_layout()
    plt.savefig('Stage-2-Enhanced-Architecture.png', dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='none')
    plt.show()
    
    print("✅ Enhanced Stage 2 architecture diagram generated successfully!")
    print("📁 Saved as: Stage-2-Enhanced-Architecture.png")
    print("🎯 Includes all Phase D components: Helm + Prometheus + Grafana + Automation")

if __name__ == "__main__":
    create_enhanced_stage2_architecture()
