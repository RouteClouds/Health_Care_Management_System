#!/usr/bin/env python3
"""
Stage 2 Pipeline Flow Diagram Generator
Healthcare Management System - Detailed CI/CD Workflow
Tech Stack: Jest + Selenium + SonarQube + Trivy
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch, Circle
import numpy as np

def create_pipeline_flow():
    # Create figure with high DPI for crisp PNG output
    fig, ax = plt.subplots(1, 1, figsize=(28, 20))
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')
    
    # Color scheme
    colors = {
        'trigger': '#28a745',
        'security': '#dc3545',
        'test': '#007bff',
        'quality': '#6f42c1',
        'build': '#fd7e14',
        'deploy': '#20c997',
        'success': '#28a745',
        'fail': '#dc3545'
    }
    
    # Title
    ax.text(50, 96, 'Stage 2: Detailed CI/CD Pipeline Flow', 
            fontsize=26, fontweight='bold', ha='center',
            bbox=dict(boxstyle="round,pad=0.5", facecolor='lightblue', alpha=0.8))
    
    ax.text(50, 93, 'Healthcare Management System - Automated Testing & Deployment Pipeline', 
            fontsize=16, ha='center', style='italic')
    
    # ============================================================================
    # PIPELINE STAGES - VERTICAL FLOW
    # ============================================================================
    
    stages = [
        {
            'name': 'Trigger',
            'title': '🚀 Pipeline Trigger',
            'details': ['git push origin main', 'Pull Request created', 'Manual workflow dispatch'],
            'y': 85,
            'color': colors['trigger'],
            'time': '< 1 min'
        },
        {
            'name': 'Security Analysis',
            'title': '🛡️ Security Analysis',
            'details': ['Trivy filesystem scan', 'Dependency vulnerability check', 'License compliance scan'],
            'y': 75,
            'color': colors['security'],
            'time': '2-3 min'
        },
        {
            'name': 'Unit Testing',
            'title': '🧪 Unit Testing',
            'details': ['Jest test execution', 'Coverage analysis (>80%)', 'Test result reporting'],
            'y': 65,
            'color': colors['test'],
            'time': '3-4 min'
        },
        {
            'name': 'Code Quality',
            'title': '📊 Code Quality Analysis',
            'details': ['SonarQube analysis', 'Quality gate evaluation', 'Technical debt assessment'],
            'y': 55,
            'color': colors['quality'],
            'time': '2-3 min'
        },
        {
            'name': 'Build',
            'title': '🐳 Container Build',
            'details': ['Docker image build', 'Multi-stage optimization', 'Image tagging & push'],
            'y': 45,
            'color': colors['build'],
            'time': '4-5 min'
        },
        {
            'name': 'Image Security',
            'title': '🔍 Image Security Scan',
            'details': ['Trivy container scan', 'Vulnerability assessment', 'Security report generation'],
            'y': 35,
            'color': colors['security'],
            'time': '2-3 min'
        },
        {
            'name': 'E2E Testing',
            'title': '🌐 End-to-End Testing',
            'details': ['Selenium WebDriver tests', 'Chrome & Firefox browsers', 'User journey validation'],
            'y': 25,
            'color': colors['test'],
            'time': '5-8 min'
        },
        {
            'name': 'Deployment',
            'title': '🚀 Automated Deployment',
            'details': ['Staging deployment', 'Health checks', 'Production approval gate'],
            'y': 15,
            'color': colors['deploy'],
            'time': '3-5 min'
        }
    ]
    
    # Draw pipeline stages
    for i, stage in enumerate(stages):
        # Main stage box
        stage_box = FancyBboxPatch((10, stage['y']-3), 35, 6, 
                                  boxstyle="round,pad=0.3", 
                                  facecolor=stage['color'], 
                                  edgecolor='black', linewidth=2)
        ax.add_patch(stage_box)
        
        # Stage title
        ax.text(12, stage['y']+1, stage['title'], fontsize=12, fontweight='bold', 
                ha='left', va='center', color='white')
        
        # Time indicator
        ax.text(43, stage['y']+1, f"⏱️ {stage['time']}", fontsize=10, 
                ha='right', va='center', color='white')
        
        # Stage details
        for j, detail in enumerate(stage['details']):
            ax.text(12, stage['y']-1-j*0.7, f"• {detail}", fontsize=9, 
                    ha='left', va='center', color='white')
        
        # Arrow to next stage
        if i < len(stages) - 1:
            arrow = ConnectionPatch((27.5, stage['y']-3), (27.5, stages[i+1]['y']+3), 
                                  "data", "data", 
                                  arrowstyle="->", shrinkA=0, shrinkB=0, 
                                  mutation_scale=25, fc="black", lw=3)
            ax.add_artist(arrow)
    
    # ============================================================================
    # PARALLEL PROCESSES & INTEGRATIONS (Right Side)
    # ============================================================================
    
    # External Services
    external_services = [
        {
            'name': 'SonarQube Cloud',
            'icon': '📊',
            'details': ['Quality gates', 'Coverage reports', 'Code smells'],
            'y': 60,
            'color': colors['quality']
        },
        {
            'name': 'Docker Hub',
            'icon': '🐳',
            'details': ['Image registry', 'Automated builds', 'Security scanning'],
            'y': 45,
            'color': colors['build']
        },
        {
            'name': 'AWS EKS',
            'icon': '☁️',
            'details': ['Kubernetes cluster', 'Auto-scaling', 'Load balancing'],
            'y': 20,
            'color': colors['deploy']
        }
    ]
    
    for service in external_services:
        service_box = FancyBboxPatch((55, service['y']-2), 20, 4, 
                                    boxstyle="round,pad=0.3", 
                                    facecolor=service['color'], 
                                    edgecolor='black', linewidth=2)
        ax.add_patch(service_box)
        
        ax.text(57, service['y']+0.5, f"{service['icon']} {service['name']}", 
                fontsize=11, fontweight='bold', ha='left', va='center', color='white')
        
        for j, detail in enumerate(service['details']):
            ax.text(57, service['y']-0.5-j*0.5, f"• {detail}", fontsize=8, 
                    ha='left', va='center', color='white')
    
    # ============================================================================
    # DECISION POINTS & GATES
    # ============================================================================
    
    # Quality Gates
    gates = [
        {'name': 'Security Gate', 'y': 70, 'condition': 'No Critical Vulnerabilities'},
        {'name': 'Test Gate', 'y': 60, 'condition': 'All Tests Pass + Coverage >80%'},
        {'name': 'Quality Gate', 'y': 50, 'condition': 'SonarQube Rating: A'},
        {'name': 'Deployment Gate', 'y': 10, 'condition': 'Manual Approval Required'}
    ]
    
    for gate in gates:
        # Diamond shape for decision point
        diamond = patches.RegularPolygon((80, gate['y']), 4, radius=2, 
                                       orientation=np.pi/4, 
                                       facecolor='yellow', 
                                       edgecolor='black', linewidth=2)
        ax.add_patch(diamond)
        
        ax.text(80, gate['y'], '?', fontsize=14, fontweight='bold', 
                ha='center', va='center')
        
        ax.text(85, gate['y']+1, gate['name'], fontsize=10, fontweight='bold', 
                ha='left', va='center')
        ax.text(85, gate['y']-1, gate['condition'], fontsize=8, 
                ha='left', va='center', style='italic')
    
    # ============================================================================
    # SUCCESS/FAILURE PATHS
    # ============================================================================
    
    # Success path
    success_box = FancyBboxPatch((85, 5), 12, 4, 
                                boxstyle="round,pad=0.3", 
                                facecolor=colors['success'], 
                                edgecolor='black', linewidth=2)
    ax.add_patch(success_box)
    ax.text(91, 7, '✅ Success', fontsize=11, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(91, 5.5, 'Deploy to Production', fontsize=9, 
            ha='center', va='center', color='white')
    
    # Failure path
    failure_box = FancyBboxPatch((85, 85), 12, 4, 
                                boxstyle="round,pad=0.3", 
                                facecolor=colors['fail'], 
                                edgecolor='black', linewidth=2)
    ax.add_patch(failure_box)
    ax.text(91, 87, '❌ Failure', fontsize=11, fontweight='bold', 
            ha='center', va='center', color='white')
    ax.text(91, 85.5, 'Stop Pipeline', fontsize=9, 
            ha='center', va='center', color='white')
    
    # ============================================================================
    # METRICS & PERFORMANCE
    # ============================================================================
    
    metrics_box = FancyBboxPatch((2, 2), 25, 8, 
                                boxstyle="round,pad=0.3", 
                                facecolor='lightgray', 
                                edgecolor='black', linewidth=2)
    ax.add_patch(metrics_box)
    ax.text(14.5, 8, '📊 Pipeline Metrics', fontsize=12, fontweight='bold', 
            ha='center', va='center')
    
    metrics = [
        'Total Pipeline Time: 15-25 minutes',
        'Success Rate Target: >95%',
        'Test Coverage Requirement: >80%',
        'Security Vulnerabilities: 0 Critical',
        'Quality Gate: A Rating Required'
    ]
    
    for i, metric in enumerate(metrics):
        ax.text(3, 7-i*0.8, f"• {metric}", fontsize=9, 
                ha='left', va='center')
    
    # ============================================================================
    # TECHNOLOGY STACK
    # ============================================================================
    
    tech_box = FancyBboxPatch((30, 2), 25, 8, 
                             boxstyle="round,pad=0.3", 
                             facecolor='lightblue', 
                             edgecolor='black', linewidth=2)
    ax.add_patch(tech_box)
    ax.text(42.5, 8, '🛠️ Technology Stack', fontsize=12, fontweight='bold', 
            ha='center', va='center')
    
    tech_stack = [
        'Unit Testing: Jest + Supertest',
        'E2E Testing: Selenium WebDriver',
        'Code Quality: SonarQube Cloud',
        'Security: Trivy Scanner',
        'CI/CD: GitHub Actions'
    ]
    
    for i, tech in enumerate(tech_stack):
        ax.text(31, 7-i*0.8, f"• {tech}", fontsize=9, 
                ha='left', va='center')
    
    # ============================================================================
    # ENVIRONMENTS
    # ============================================================================
    
    env_box = FancyBboxPatch((58, 2), 25, 8, 
                            boxstyle="round,pad=0.3", 
                            facecolor='lightgreen', 
                            edgecolor='black', linewidth=2)
    ax.add_patch(env_box)
    ax.text(70.5, 8, '🌍 Deployment Environments', fontsize=12, fontweight='bold', 
            ha='center', va='center')
    
    environments = [
        'Development: Auto-deploy every push',
        'Staging: E2E testing environment',
        'Production: Manual approval required',
        'Infrastructure: AWS EKS (us-east-1)',
        'Monitoring: GitHub Actions + AWS'
    ]
    
    for i, env in enumerate(environments):
        ax.text(59, 7-i*0.8, f"• {env}", fontsize=9, 
                ha='left', va='center')
    
    # ============================================================================
    # INTEGRATION ARROWS
    # ============================================================================
    
    # Connect pipeline to external services
    integration_arrows = [
        # SonarQube integration
        ((45, 55), (55, 60)),
        # Docker Hub integration
        ((45, 45), (55, 45)),
        # EKS deployment
        ((45, 15), (55, 20)),
    ]
    
    for start, end in integration_arrows:
        arrow = ConnectionPatch(start, end, "data", "data", 
                              arrowstyle="->", shrinkA=0, shrinkB=0, 
                              mutation_scale=20, fc="blue", lw=2)
        ax.add_artist(arrow)
    
    plt.tight_layout()
    return fig

def main():
    """Generate and save the pipeline flow diagram"""
    print("🎨 Generating Stage 2 Pipeline Flow Diagram...")
    
    # Create the diagram
    fig = create_pipeline_flow()
    
    # Save as high-quality PNG
    output_file = 'Stage-2-Pipeline-Flow-Diagram.png'
    fig.savefig(output_file, dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='none')
    
    print(f"✅ Pipeline flow diagram saved as: {output_file}")
    print("📊 Diagram features:")
    print("   • Detailed CI/CD pipeline workflow")
    print("   • Step-by-step process visualization")
    print("   • Quality gates and decision points")
    print("   • Technology stack integration")
    print("   • Performance metrics and timing")
    print("   • Success/failure paths")
    print("   • External service integrations")
    
    plt.close()

if __name__ == "__main__":
    main()
