#!/usr/bin/env python3
"""
Stage 3 Architecture Diagrams Generator - CORRECTED VERSION
Based on User Feedback: Stage 1 uses scripts, ECR instead of Docker Hub, No Istio for monolith
"""

import os
import sys
from pathlib import Path

# Add the project root to the path
project_root = Path(__file__).parent.parent.parent.parent
sys.path.append(str(project_root))

try:
    import matplotlib.pyplot as plt
    import matplotlib.patches as patches
    from matplotlib.patches import FancyBboxPatch, ConnectionPatch
    import numpy as np
    from matplotlib.patches import Rectangle, Circle, FancyBboxPatch
    from matplotlib.patches import ConnectionPatch
    import matplotlib.patches as mpatches
except ImportError as e:
    print(f"Error importing matplotlib: {e}")
    print("Please install matplotlib: pip install matplotlib")
    sys.exit(1)

class CorrectedStage3DiagramGenerator:
    def __init__(self):
        self.output_dir = Path(__file__).parent / "generated_diagrams"
        self.output_dir.mkdir(exist_ok=True)
        
        # Color scheme for Stage 3
        self.colors = {
            'stage1': '#FF6B6B',      # Red for Stage 1
            'stage2': '#4ECDC4',      # Teal for Stage 2
            'stage3': '#45B7D1',      # Blue for Stage 3
            'aws': '#FF9900',         # AWS Orange
            'ecr': '#FF9900',         # ECR (AWS)
            'dockerhub': '#2496ED',   # Docker Hub Blue
            'github': '#24292E',      # GitHub Dark
            'kubernetes': '#326CE5',  # Kubernetes Blue
            'terraform': '#7B42BC',   # Terraform Purple
            'prometheus': '#E6522C',  # Prometheus Red
            'grafana': '#F46800',     # Grafana Orange
            'elasticsearch': '#00BFB3', # Elasticsearch Teal
            'argocd': '#326CE5',      # ArgoCD Blue
            'background': '#F8F9FA',  # Light Gray
            'border': '#E9ECEF',      # Border Gray
            'text': '#212529',        # Dark Text
            'success': '#28A745',     # Success Green
            'warning': '#FFC107',     # Warning Yellow
            'info': '#17A2B8'         # Info Blue
        }
        
        # Set up matplotlib
        plt.rcParams['figure.figsize'] = (16, 12)
        plt.rcParams['font.size'] = 10
        plt.rcParams['font.family'] = 'DejaVu Sans'
        
    def create_box(self, ax, x, y, width, height, label, color, alpha=0.8, text_color='white'):
        """Create a styled box with label"""
        box = FancyBboxPatch((x, y), width, height,
                            boxstyle="round,pad=0.1",
                            facecolor=color,
                            edgecolor='white',
                            linewidth=2,
                            alpha=alpha)
        ax.add_patch(box)
        
        # Add label
        ax.text(x + width/2, y + height/2, label,
                ha='center', va='center',
                color=text_color,
                fontsize=9,
                fontweight='bold',
                wrap=True)
        return box
    
    def create_arrow(self, ax, start, end, color='black', style='->', linewidth=2):
        """Create an arrow between two points"""
        arrow = ConnectionPatch(start, end, "data", "data",
                              arrowstyle=style,
                              shrinkA=5, shrinkB=5,
                              mutation_scale=20,
                              fc=color, ec=color,
                              linewidth=linewidth)
        ax.add_patch(arrow)
        return arrow
    
    def generate_overall_architecture(self):
        """Generate overall Stage 3 architecture diagram - CORRECTED"""
        fig, ax = plt.subplots(1, 1, figsize=(20, 16))
        ax.set_xlim(0, 20)
        ax.set_ylim(0, 16)
        ax.set_aspect('equal')
        
        # Title
        ax.text(10, 15.5, 'Healthcare Management System - Stage 3: Advanced DevOps Architecture',
                ha='center', va='center', fontsize=16, fontweight='bold', color=self.colors['text'])
        
        # Subtitle
        ax.text(10, 15, 'CORRECTED: Stage 1 uses scripts, ECR instead of Docker Hub, No Istio for monolith',
                ha='center', va='center', fontsize=12, color=self.colors['text'])
        
        # Stage 1 (Left) - CORRECTED: Uses scripts, not GitHub Actions
        ax.text(3, 14, 'Stage 1: Basic CI/CD', ha='center', va='center', fontsize=12, fontweight='bold', color=self.colors['stage1'])
        self.create_box(ax, 1, 12, 4, 1.5, 'Manual\nDeployment\nScripts', self.colors['stage1'])
        self.create_box(ax, 1, 10, 4, 1.5, 'Basic\nDocker', self.colors['stage1'])
        self.create_box(ax, 1, 8, 4, 1.5, 'Direct\nkubectl', self.colors['stage1'])
        
        # Stage 2 (Center) - Uses Docker Hub
        ax.text(10, 14, 'Stage 2: Automated CI/CD', ha='center', va='center', fontsize=12, fontweight='bold', color=self.colors['stage2'])
        self.create_box(ax, 8, 12, 4, 1.5, 'GitHub\nActions', self.colors['stage2'])
        self.create_box(ax, 8, 10, 4, 1.5, 'Docker Hub\nRegistry', self.colors['dockerhub'])
        self.create_box(ax, 8, 8, 4, 1.5, 'EKS\nCluster', self.colors['stage2'])
        
        # Stage 3 (Right) - Uses ECR, No Istio
        ax.text(17, 14, 'Stage 3: Advanced DevOps', ha='center', va='center', fontsize=12, fontweight='bold', color=self.colors['stage3'])
        self.create_box(ax, 15, 12, 4, 1.5, 'Terraform\nIaC', self.colors['stage3'])
        self.create_box(ax, 15, 10, 4, 1.5, 'AWS ECR\nRegistry', self.colors['ecr'])
        self.create_box(ax, 15, 8, 4, 1.5, 'GitOps\nArgoCD', self.colors['stage3'])
        
        # AWS Region (Bottom)
        ax.text(10, 6, 'AWS Region: us-east-1 (Shared)', ha='center', va='center', fontsize=14, fontweight='bold', color=self.colors['aws'])
        self.create_box(ax, 2, 4, 16, 1.5, 'Shared AWS Infrastructure\n(VPC, IAM, ECR, S3)', self.colors['aws'], text_color='white')
        
        # Separation Lines
        ax.axvline(x=6, ymin=0.1, ymax=0.9, color='gray', linestyle='--', linewidth=2)
        ax.axvline(x=13, ymin=0.1, ymax=0.9, color='gray', linestyle='--', linewidth=2)
        
        # Evolution Arrows
        self.create_arrow(ax, (5.5, 12.75), (7.5, 12.75), self.colors['stage2'], '->', 3)
        self.create_arrow(ax, (12.5, 12.75), (14.5, 12.75), self.colors['stage3'], '->', 3)
        
        # Legend
        legend_elements = [
            mpatches.Patch(color=self.colors['stage1'], label='Stage 1: Scripts & Manual'),
            mpatches.Patch(color=self.colors['stage2'], label='Stage 2: GitHub Actions + Docker Hub'),
            mpatches.Patch(color=self.colors['stage3'], label='Stage 3: Terraform + ECR + ArgoCD'),
            mpatches.Patch(color=self.colors['aws'], label='Shared AWS Infrastructure')
        ]
        ax.legend(handles=legend_elements, loc='upper left', bbox_to_anchor=(0, 0.95))
        
        ax.set_xticks([])
        ax.set_yticks([])
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.spines['bottom'].set_visible(False)
        ax.spines['left'].set_visible(False)
        
        plt.tight_layout()
        plt.savefig(self.output_dir / '01_overall_architecture_corrected.png', dpi=300, bbox_inches='tight')
        plt.close()
        print("✅ Generated: 01_overall_architecture_corrected.png")
    
    def generate_registry_comparison(self):
        """Generate Docker Hub vs ECR comparison diagram"""
        fig, ax = plt.subplots(1, 1, figsize=(20, 12))
        ax.set_xlim(0, 20)
        ax.set_ylim(0, 12)
        ax.set_aspect('equal')
        
        # Title
        ax.text(10, 11.5, 'Container Registry Comparison: Docker Hub vs AWS ECR',
                ha='center', va='center', fontsize=16, fontweight='bold', color=self.colors['text'])
        
        # Stage 2: Docker Hub
        ax.text(5, 10.5, 'Stage 2: Docker Hub', ha='center', va='center', fontsize=14, fontweight='bold', color=self.colors['dockerhub'])
        self.create_box(ax, 1, 8, 8, 1.5, 'Docker Hub Registry\nrouteclouds/healthcare-*', self.colors['dockerhub'])
        self.create_box(ax, 1, 6, 8, 1.5, 'Authentication\nUsername/Password', self.colors['dockerhub'])
        self.create_box(ax, 1, 4, 8, 1.5, 'Rate Limits\nPublic/Private', self.colors['dockerhub'])
        self.create_box(ax, 1, 2, 8, 1.5, 'External Service\nhub.docker.com', self.colors['dockerhub'])
        
        # Stage 3: AWS ECR
        ax.text(15, 10.5, 'Stage 3: AWS ECR', ha='center', va='center', fontsize=14, fontweight='bold', color=self.colors['ecr'])
        self.create_box(ax, 11, 8, 8, 1.5, 'AWS ECR Registry\nhealthcare-*-stage3', self.colors['ecr'])
        self.create_box(ax, 11, 6, 8, 1.5, 'Authentication\nIAM Roles', self.colors['ecr'])
        self.create_box(ax, 11, 4, 8, 1.5, 'No Rate Limits\nAWS Native', self.colors['ecr'])
        self.create_box(ax, 11, 2, 8, 1.5, 'AWS Service\nSame Region', self.colors['ecr'])
        
        # Comparison Arrow
        self.create_arrow(ax, (9.5, 8.75), (10.5, 8.75), self.colors['stage3'], '->', 4)
        ax.text(10, 9.5, 'Migration Path', ha='center', va='center', fontsize=12, fontweight='bold', color=self.colors['stage3'])
        
        # Benefits
        ax.text(10, 0.5, 'Benefits: Better AWS Integration, Security, Cost Efficiency', 
                ha='center', va='center', fontsize=12, color=self.colors['success'])
        
        ax.set_xticks([])
        ax.set_yticks([])
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.spines['bottom'].set_visible(False)
        ax.spines['left'].set_visible(False)
        
        plt.tight_layout()
        plt.savefig(self.output_dir / '02_registry_comparison.png', dpi=300, bbox_inches='tight')
        plt.close()
        print("✅ Generated: 02_registry_comparison.png")
    
    def generate_stage1_correction(self):
        """Generate Stage 1 correction diagram - No GitHub Actions"""
        fig, ax = plt.subplots(1, 1, figsize=(20, 12))
        ax.set_xlim(0, 20)
        ax.set_ylim(0, 12)
        ax.set_aspect('equal')
        
        # Title
        ax.text(10, 11.5, 'Stage 1: Manual Deployment (CORRECTED - No GitHub Actions)',
                ha='center', va='center', fontsize=16, fontweight='bold', color=self.colors['text'])
        
        # Stage 1 Workflow
        ax.text(10, 10.5, 'Stage 1: Scripts and Manual Commands', ha='center', va='center', fontsize=14, fontweight='bold', color=self.colors['stage1'])
        
        # Workflow Steps
        steps = [
            ('Code Changes', 2, 9),
            ('Manual Build\nScripts', 5, 9),
            ('Docker Build\nScripts', 8, 9),
            ('Manual Push\nScripts', 11, 9),
            ('Direct kubectl\napply', 14, 9),
            ('Deployment\nComplete', 17, 9)
        ]
        
        for i, (step, x, y) in enumerate(steps):
            self.create_box(ax, x-1, y-0.3, 2, 0.6, step, self.colors['stage1'], alpha=0.8, text_color='white')
            if i < len(steps) - 1:
                self.create_arrow(ax, (x+1, y), (x+2, y), self.colors['stage1'], '->', 2)
        
        # Scripts Directory
        ax.text(10, 7.5, 'Scripts Directory Structure', ha='center', va='center', fontsize=12, fontweight='bold', color=self.colors['text'])
        self.create_box(ax, 2, 6, 4, 1, 'deploy.sh\nManual deployment', self.colors['stage1'])
        self.create_box(ax, 7, 6, 4, 1, 'build-images.sh\nDocker build', self.colors['stage1'])
        self.create_box(ax, 12, 6, 4, 1, 'setup-env.sh\nEnvironment setup', self.colors['stage1'])
        
        # Key Characteristics
        ax.text(10, 4.5, 'Stage 1 Characteristics', ha='center', va='center', fontsize=12, fontweight='bold', color=self.colors['text'])
        characteristics = [
            '❌ No GitHub Actions',
            '✅ Manual Scripts',
            '✅ Direct kubectl',
            '✅ Learning Focus'
        ]
        
        for i, char in enumerate(characteristics):
            y_pos = 3.5 - i * 0.6
            self.create_box(ax, 2, y_pos-0.2, 16, 0.4, char, self.colors['stage1'], alpha=0.6, text_color='white')
        
        ax.set_xticks([])
        ax.set_yticks([])
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.spines['bottom'].set_visible(False)
        ax.spines['left'].set_visible(False)
        
        plt.tight_layout()
        plt.savefig(self.output_dir / '03_stage1_correction.png', dpi=300, bbox_inches='tight')
        plt.close()
        print("✅ Generated: 03_stage1_correction.png")
    
    def generate_no_istio_justification(self):
        """Generate diagram explaining why no Istio for monolith"""
        fig, ax = plt.subplots(1, 1, figsize=(20, 12))
        ax.set_xlim(0, 20)
        ax.set_ylim(0, 12)
        ax.set_aspect('equal')
        
        # Title
        ax.text(10, 11.5, 'Why No Istio for Stage 3: Monolithic Application',
                ha='center', va='center', fontsize=16, fontweight='bold', color=self.colors['text'])
        
        # Application Architecture
        ax.text(10, 10.5, 'Current Application Architecture', ha='center', va='center', fontsize=14, fontweight='bold', color=self.colors['text'])
        
        # Monolith Structure
        self.create_box(ax, 2, 8, 6, 1.5, 'Frontend\nReact.js (SPA)', self.colors['stage3'])
        self.create_box(ax, 10, 8, 6, 1.5, 'Backend\nNode.js/Express (Monolith)', self.colors['stage3'])
        self.create_box(ax, 6, 6, 6, 1, 'PostgreSQL\nSingle Database', self.colors['stage3'])
        
        # Istio vs Kubernetes Native
        ax.text(5, 4.5, 'Istio (Microservices)', ha='center', va='center', fontsize=12, fontweight='bold', color=self.colors['warning'])
        ax.text(15, 4.5, 'Kubernetes Native (Monolith)', ha='center', va='center', fontsize=12, fontweight='bold', color=self.colors['success'])
        
        # Istio Cons
        istio_cons = [
            '❌ Overkill for monolith',
            '❌ Adds complexity',
            '❌ Learning curve',
            '❌ Resource overhead'
        ]
        
        for i, con in enumerate(istio_cons):
            y_pos = 3.5 - i * 0.5
            self.create_box(ax, 1, y_pos-0.2, 8, 0.4, con, self.colors['warning'], alpha=0.7, text_color='white')
        
        # Kubernetes Native Pros
        k8s_pros = [
            '✅ Simple Ingress',
            '✅ Basic Load Balancing',
            '✅ Core DevOps focus',
            '✅ Future ready'
        ]
        
        for i, pro in enumerate(k8s_pros):
            y_pos = 3.5 - i * 0.5
            self.create_box(ax, 11, y_pos-0.2, 8, 0.4, pro, self.colors['success'], alpha=0.7, text_color='white')
        
        # Recommendation
        ax.text(10, 1, 'Recommendation: Use Kubernetes Ingress + Basic Load Balancing', 
                ha='center', va='center', fontsize=12, fontweight='bold', color=self.colors['success'])
        
        ax.set_xticks([])
        ax.set_yticks([])
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.spines['bottom'].set_visible(False)
        ax.spines['left'].set_visible(False)
        
        plt.tight_layout()
        plt.savefig(self.output_dir / '04_no_istio_justification.png', dpi=300, bbox_inches='tight')
        plt.close()
        print("✅ Generated: 04_no_istio_justification.png")
    
    def generate_naming_convention_changes(self):
        """Generate diagram showing naming convention changes"""
        fig, ax = plt.subplots(1, 1, figsize=(20, 16))
        ax.set_xlim(0, 20)
        ax.set_ylim(0, 16)
        ax.set_aspect('equal')
        
        # Title
        ax.text(10, 15.5, 'Stage 3 Naming Convention Changes',
                ha='center', va='center', fontsize=16, fontweight='bold', color=self.colors['text'])
        
        # Stage 2 vs Stage 3 Comparison
        ax.text(5, 14.5, 'Stage 2 (Current)', ha='center', va='center', fontsize=12, fontweight='bold', color=self.colors['stage2'])
        ax.text(15, 14.5, 'Stage 3 (Proposed)', ha='center', va='center', fontsize=12, fontweight='bold', color=self.colors['stage3'])
        
        # Registry Changes
        ax.text(10, 13.5, 'Container Registry', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['text'])
        self.create_box(ax, 1, 12, 8, 1, 'Docker Hub\nrouteclouds/healthcare-*', self.colors['dockerhub'])
        self.create_box(ax, 11, 12, 8, 1, 'AWS ECR\nhealthcare-*-stage3', self.colors['ecr'])
        
        # Package Names
        ax.text(10, 11.5, 'Package Names', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['text'])
        self.create_box(ax, 1, 10, 8, 1, 'healthcare-backend\nhealthcare-frontend', self.colors['stage2'])
        self.create_box(ax, 11, 10, 8, 1, 'healthcare-backend-stage3\nhealthcare-frontend-stage3', self.colors['stage3'])
        
        # Database
        ax.text(10, 9.5, 'Database', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['text'])
        self.create_box(ax, 1, 8, 8, 1, 'healthcare_db\nhealthcare_user', self.colors['stage2'])
        self.create_box(ax, 11, 8, 8, 1, 'healthcare_stage3_db\nhealthcare_stage3_user', self.colors['stage3'])
        
        # Domains
        ax.text(10, 7.5, 'Domains', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['text'])
        self.create_box(ax, 1, 6, 8, 1, 'healthcare.example.com\napi.healthcare.example.com', self.colors['stage2'])
        self.create_box(ax, 11, 6, 8, 1, 'stage3.healthcare.example.com\napi.stage3.healthcare.example.com', self.colors['stage3'])
        
        # Kubernetes Resources
        ax.text(10, 5.5, 'Kubernetes Resources', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['text'])
        self.create_box(ax, 1, 4, 8, 1, 'healthcare namespace\nhealthcare-frontend-svc', self.colors['stage2'])
        self.create_box(ax, 11, 4, 8, 1, 'healthcare-stage3-dev namespace\nhealthcare-frontend-stage3-svc', self.colors['stage3'])
        
        # Files to Change
        ax.text(10, 3.5, 'Files Requiring Changes', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['text'])
        files = [
            'package.json files',
            'Kubernetes manifests',
            'Helm chart values',
            'Database scripts',
            'Environment configs',
            'Deployment scripts'
        ]
        
        for i, file in enumerate(files):
            y_pos = 2.5 - i * 0.3
            self.create_box(ax, 2, y_pos-0.1, 16, 0.2, file, self.colors['info'], alpha=0.6, text_color='white')
        
        # Migration Arrow
        self.create_arrow(ax, (9.5, 12), (10.5, 12), self.colors['stage3'], '->', 3)
        ax.text(10, 13, 'Migration Path', ha='center', va='center', fontsize=10, fontweight='bold', color=self.colors['stage3'])
        
        ax.set_xticks([])
        ax.set_yticks([])
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.spines['bottom'].set_visible(False)
        ax.spines['left'].set_visible(False)
        
        plt.tight_layout()
        plt.savefig(self.output_dir / '05_naming_convention_changes.png', dpi=300, bbox_inches='tight')
        plt.close()
        print("✅ Generated: 05_naming_convention_changes.png")
    
    def generate_corrected_pipeline_comparison(self):
        """Generate corrected pipeline comparison - Stage 1 uses scripts"""
        fig, ax = plt.subplots(1, 1, figsize=(20, 12))
        ax.set_xlim(0, 20)
        ax.set_ylim(0, 12)
        ax.set_aspect('equal')
        
        # Title
        ax.text(10, 11.5, 'Pipeline Comparison: CORRECTED (Stage 1 uses scripts)',
                ha='center', va='center', fontsize=16, fontweight='bold', color=self.colors['text'])
        
        # Stage 1
        ax.text(3, 10.5, 'Stage 1: Manual Scripts', ha='center', va='center', fontsize=12, fontweight='bold', color=self.colors['stage1'])
        self.create_box(ax, 1, 8, 4, 1, 'deploy.sh\nManual script', self.colors['stage1'])
        self.create_box(ax, 1, 6, 4, 1, 'build-images.sh\nDocker script', self.colors['stage1'])
        self.create_box(ax, 1, 4, 4, 1, 'kubectl apply\nDirect command', self.colors['stage1'])
        
        # Stage 2
        ax.text(10, 10.5, 'Stage 2: GitHub Actions', ha='center', va='center', fontsize=12, fontweight='bold', color=self.colors['stage2'])
        self.create_box(ax, 8, 8, 4, 1, 'stage2-ci.yml\nGitHub Actions', self.colors['stage2'])
        self.create_box(ax, 8, 6, 4, 1, 'Docker Hub\nRegistry', self.colors['dockerhub'])
        self.create_box(ax, 8, 4, 4, 1, 'Automated\nDeployment', self.colors['stage2'])
        
        # Stage 3
        ax.text(17, 10.5, 'Stage 3: Advanced DevOps', ha='center', va='center', fontsize=12, fontweight='bold', color=self.colors['stage3'])
        self.create_box(ax, 15, 8, 4, 1, 'stage3-ci.yml\nGitHub Actions', self.colors['stage3'])
        self.create_box(ax, 15, 6, 4, 1, 'AWS ECR\nRegistry', self.colors['ecr'])
        self.create_box(ax, 15, 4, 4, 1, 'ArgoCD\nGitOps', self.colors['stage3'])
        
        # Evolution Arrows
        self.create_arrow(ax, (5.5, 8.5), (7.5, 8.5), self.colors['stage2'], '->', 2)
        self.create_arrow(ax, (12.5, 8.5), (14.5, 8.5), self.colors['stage3'], '->', 2)
        
        # Key Differences
        ax.text(10, 2.5, 'Key Differences', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['text'])
        differences = [
            'Stage 1: Manual scripts, no CI/CD',
            'Stage 2: GitHub Actions + Docker Hub',
            'Stage 3: GitHub Actions + ECR + GitOps'
        ]
        
        for i, diff in enumerate(differences):
            y_pos = 1.5 - i * 0.4
            self.create_box(ax, 2, y_pos-0.15, 16, 0.3, diff, self.colors['info'], alpha=0.6, text_color='white')
        
        ax.set_xticks([])
        ax.set_yticks([])
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.spines['bottom'].set_visible(False)
        ax.spines['left'].set_visible(False)
        
        plt.tight_layout()
        plt.savefig(self.output_dir / '06_corrected_pipeline_comparison.png', dpi=300, bbox_inches='tight')
        plt.close()
        print("✅ Generated: 06_corrected_pipeline_comparison.png")
    
    def generate_all_corrected_diagrams(self):
        """Generate all corrected Stage 3 diagrams"""
        print("🚀 Generating CORRECTED Stage 3 Architecture Diagrams...")
        print("📋 Based on User Feedback:")
        print("  - Stage 1 uses scripts, not GitHub Actions")
        print("  - ECR instead of Docker Hub for Stage 3")
        print("  - No Istio for monolithic application")
        print("  - Comprehensive naming convention changes")
        print("=" * 80)
        
        try:
            self.generate_overall_architecture()
            self.generate_registry_comparison()
            self.generate_stage1_correction()
            self.generate_no_istio_justification()
            self.generate_naming_convention_changes()
            self.generate_corrected_pipeline_comparison()
            
            print("=" * 80)
            print("🎉 All CORRECTED Stage 3 diagrams generated successfully!")
            print(f"📁 Output directory: {self.output_dir}")
            print("📋 Generated diagrams:")
            print("  - 01_overall_architecture_corrected.png")
            print("  - 02_registry_comparison.png")
            print("  - 03_stage1_correction.png")
            print("  - 04_no_istio_justification.png")
            print("  - 05_naming_convention_changes.png")
            print("  - 06_corrected_pipeline_comparison.png")
            
        except Exception as e:
            print(f"❌ Error generating diagrams: {e}")
            import traceback
            traceback.print_exc()

def main():
    """Main function to generate all corrected diagrams"""
    generator = CorrectedStage3DiagramGenerator()
    generator.generate_all_corrected_diagrams()

if __name__ == "__main__":
    main() 