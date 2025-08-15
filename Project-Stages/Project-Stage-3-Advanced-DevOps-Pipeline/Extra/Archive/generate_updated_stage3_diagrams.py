#!/usr/bin/env python3
"""
Stage 3 Architecture Diagrams Generator
Updated for Practical Approach: Separate Directories, Same AWS Region, Separate Pipelines
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

class Stage3DiagramGenerator:
    def __init__(self):
        self.output_dir = Path(__file__).parent / "generated_diagrams"
        self.output_dir.mkdir(exist_ok=True)
        
        # Color scheme for Stage 3
        self.colors = {
            'stage1': '#FF6B6B',      # Red for Stage 1
            'stage2': '#4ECDC4',      # Teal for Stage 2
            'stage3': '#45B7D1',      # Blue for Stage 3
            'aws': '#FF9900',         # AWS Orange
            'github': '#24292E',      # GitHub Dark
            'kubernetes': '#326CE5',  # Kubernetes Blue
            'terraform': '#7B42BC',   # Terraform Purple
            'prometheus': '#E6522C',  # Prometheus Red
            'grafana': '#F46800',     # Grafana Orange
            'elasticsearch': '#00BFB3', # Elasticsearch Teal
            'argocd': '#326CE5',      # ArgoCD Blue
            'istio': '#466BB0',       # Istio Blue
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
        """Generate overall Stage 3 architecture diagram"""
        fig, ax = plt.subplots(1, 1, figsize=(20, 16))
        ax.set_xlim(0, 20)
        ax.set_ylim(0, 16)
        ax.set_aspect('equal')
        
        # Title
        ax.text(10, 15.5, 'Healthcare Management System - Stage 3: Advanced DevOps Architecture',
                ha='center', va='center', fontsize=16, fontweight='bold', color=self.colors['text'])
        
        # Subtitle
        ax.text(10, 15, 'Practical Approach: Separate Directories, Same AWS Region, Independent Pipelines',
                ha='center', va='center', fontsize=12, color=self.colors['text'])
        
        # Stage 1 (Left)
        ax.text(3, 14, 'Stage 1: Basic CI/CD', ha='center', va='center', fontsize=12, fontweight='bold', color=self.colors['stage1'])
        self.create_box(ax, 1, 12, 4, 1.5, 'Manual\nDeployment', self.colors['stage1'])
        self.create_box(ax, 1, 10, 4, 1.5, 'Basic\nDocker', self.colors['stage1'])
        self.create_box(ax, 1, 8, 4, 1.5, 'Simple\nK8s', self.colors['stage1'])
        
        # Stage 2 (Center)
        ax.text(10, 14, 'Stage 2: Automated CI/CD', ha='center', va='center', fontsize=12, fontweight='bold', color=self.colors['stage2'])
        self.create_box(ax, 8, 12, 4, 1.5, 'GitHub\nActions', self.colors['stage2'])
        self.create_box(ax, 8, 10, 4, 1.5, 'Automated\nDeployment', self.colors['stage2'])
        self.create_box(ax, 8, 8, 4, 1.5, 'EKS\nCluster', self.colors['stage2'])
        
        # Stage 3 (Right)
        ax.text(17, 14, 'Stage 3: Advanced DevOps', ha='center', va='center', fontsize=12, fontweight='bold', color=self.colors['stage3'])
        self.create_box(ax, 15, 12, 4, 1.5, 'Terraform\nIaC', self.colors['stage3'])
        self.create_box(ax, 15, 10, 4, 1.5, 'GitOps\nArgoCD', self.colors['stage3'])
        self.create_box(ax, 15, 8, 4, 1.5, 'Monitoring\nStack', self.colors['stage3'])
        
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
            mpatches.Patch(color=self.colors['stage1'], label='Stage 1: Basic CI/CD'),
            mpatches.Patch(color=self.colors['stage2'], label='Stage 2: Automated CI/CD'),
            mpatches.Patch(color=self.colors['stage3'], label='Stage 3: Advanced DevOps'),
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
        plt.savefig(self.output_dir / '01_overall_architecture.png', dpi=300, bbox_inches='tight')
        plt.close()
        print("✅ Generated: 01_overall_architecture.png")
    
    def generate_infrastructure_architecture(self):
        """Generate Stage 3 infrastructure architecture diagram"""
        fig, ax = plt.subplots(1, 1, figsize=(20, 16))
        ax.set_xlim(0, 20)
        ax.set_ylim(0, 16)
        ax.set_aspect('equal')
        
        # Title
        ax.text(10, 15.5, 'Stage 3: Infrastructure Architecture (Same AWS Region, Different Resource Names)',
                ha='center', va='center', fontsize=16, fontweight='bold', color=self.colors['text'])
        
        # AWS Region
        ax.text(10, 14.5, 'AWS Region: us-east-1 (Shared with Stage 2)', ha='center', va='center', fontsize=12, color=self.colors['aws'])
        
        # VPC
        vpc_box = self.create_box(ax, 1, 12, 18, 2, 'VPC (Shared)\n10.0.0.0/16', self.colors['aws'], alpha=0.3, text_color='black')
        
        # Stage 2 Resources (Left)
        ax.text(5, 11.5, 'Stage 2 Resources', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['stage2'])
        self.create_box(ax, 2, 9, 3, 1.5, 'healthcare-eks-cluster\n(Stage 2)', self.colors['stage2'])
        self.create_box(ax, 2, 7, 3, 1.5, 'healthcare-frontend\n(Stage 2)', self.colors['stage2'])
        self.create_box(ax, 2, 5, 3, 1.5, 'healthcare-backend\n(Stage 2)', self.colors['stage2'])
        
        # Stage 3 Resources (Right)
        ax.text(15, 11.5, 'Stage 3 Resources', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['stage3'])
        self.create_box(ax, 15, 9, 3, 1.5, 'healthcare-eks-stage3-dev\n(Stage 3)', self.colors['stage3'])
        self.create_box(ax, 15, 7, 3, 1.5, 'healthcare-frontend-stage3\n(Stage 3)', self.colors['stage3'])
        self.create_box(ax, 15, 5, 3, 1.5, 'healthcare-backend-stage3\n(Stage 3)', self.colors['stage3'])
        
        # Shared Services
        ax.text(10, 3.5, 'Shared AWS Services', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['aws'])
        self.create_box(ax, 6, 2, 2, 1, 'ECR\n(Shared)', self.colors['aws'])
        self.create_box(ax, 9, 2, 2, 1, 'S3\n(Shared)', self.colors['aws'])
        self.create_box(ax, 12, 2, 2, 1, 'IAM\n(Shared)', self.colors['aws'])
        
        # Separation Line
        ax.axvline(x=10, ymin=0.2, ymax=0.8, color='gray', linestyle='--', linewidth=3)
        ax.text(10, 10.5, 'Resource Separation\n(Different Names)', ha='center', va='center', fontsize=10, color='gray', rotation=90)
        
        # Connections
        self.create_arrow(ax, (5, 9.75), (6, 2.5), self.colors['stage2'], '->', 2)
        self.create_arrow(ax, (16.5, 9.75), (12, 2.5), self.colors['stage3'], '->', 2)
        
        ax.set_xticks([])
        ax.set_yticks([])
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.spines['bottom'].set_visible(False)
        ax.spines['left'].set_visible(False)
        
        plt.tight_layout()
        plt.savefig(self.output_dir / '02_infrastructure_architecture.png', dpi=300, bbox_inches='tight')
        plt.close()
        print("✅ Generated: 02_infrastructure_architecture.png")
    
    def generate_cicd_pipeline(self):
        """Generate Stage 3 CI/CD pipeline diagram"""
        fig, ax = plt.subplots(1, 1, figsize=(20, 12))
        ax.set_xlim(0, 20)
        ax.set_ylim(0, 12)
        ax.set_aspect('equal')
        
        # Title
        ax.text(10, 11.5, 'Stage 3: CI/CD Pipeline (Separate GitHub Actions Workflows)',
                ha='center', va='center', fontsize=16, fontweight='bold', color=self.colors['text'])
        
        # GitHub Repository
        ax.text(10, 10.5, 'GitHub Repository: Health_Care_Management_System', ha='center', va='center', fontsize=12, color=self.colors['github'])
        
        # Directory Structure
        ax.text(3, 9.5, 'Project-Stages/', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['text'])
        self.create_box(ax, 1, 8, 4, 0.8, 'Project-Stage-1-Basic-CI-CD-Deploy/', self.colors['stage1'], alpha=0.7, text_color='white')
        self.create_box(ax, 1, 7, 4, 0.8, 'Project-Stage-2-Automated-CI-CD-Pipeline/', self.colors['stage2'], alpha=0.7, text_color='white')
        self.create_box(ax, 1, 6, 4, 0.8, 'Project-Stage-3-Advanced-DevOps-Pipeline/', self.colors['stage3'], alpha=0.7, text_color='white')
        
        # GitHub Actions Workflows
        ax.text(10, 9.5, '.github/workflows/', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['text'])
        self.create_box(ax, 8, 8, 4, 0.8, 'stage1-ci.yml', self.colors['stage1'], alpha=0.7, text_color='white')
        self.create_box(ax, 8, 7, 4, 0.8, 'stage2-ci.yml', self.colors['stage2'], alpha=0.7, text_color='white')
        self.create_box(ax, 8, 6, 4, 0.8, 'stage3-ci.yml', self.colors['stage3'], alpha=0.7, text_color='white')
        
        # Stage 3 Pipeline Flow
        ax.text(15, 9.5, 'Stage 3 Pipeline Flow', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['stage3'])
        
        # Pipeline Steps
        steps = [
            ('Code Push', 15, 8.5),
            ('Terraform Validate', 15, 7.5),
            ('Unit Tests', 15, 6.5),
            ('Security Scan', 15, 5.5),
            ('Build Images', 15, 4.5),
            ('Deploy Infrastructure', 15, 3.5),
            ('Update GitOps', 15, 2.5)
        ]
        
        for i, (step, x, y) in enumerate(steps):
            self.create_box(ax, x-1, y-0.3, 2, 0.6, step, self.colors['stage3'], alpha=0.8, text_color='white')
            if i < len(steps) - 1:
                self.create_arrow(ax, (x, y-0.3), (x, y-0.9), self.colors['stage3'], '->', 2)
        
        # Path-based Triggers
        ax.text(10, 1.5, 'Path-based Pipeline Triggers', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['text'])
        ax.text(10, 1, 'stage1-ci.yml → Project-Stage-1-*/**', ha='center', va='center', fontsize=9, color=self.colors['stage1'])
        ax.text(10, 0.7, 'stage2-ci.yml → Project-Stage-2-*/**', ha='center', va='center', fontsize=9, color=self.colors['stage2'])
        ax.text(10, 0.4, 'stage3-ci.yml → Project-Stage-3-*/**', ha='center', va='center', fontsize=9, color=self.colors['stage3'])
        
        ax.set_xticks([])
        ax.set_yticks([])
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.spines['bottom'].set_visible(False)
        ax.spines['left'].set_visible(False)
        
        plt.tight_layout()
        plt.savefig(self.output_dir / '03_cicd_pipeline.png', dpi=300, bbox_inches='tight')
        plt.close()
        print("✅ Generated: 03_cicd_pipeline.png")
    
    def generate_monitoring_observability(self):
        """Generate Stage 3 monitoring and observability diagram"""
        fig, ax = plt.subplots(1, 1, figsize=(20, 16))
        ax.set_xlim(0, 20)
        ax.set_ylim(0, 16)
        ax.set_aspect('equal')
        
        # Title
        ax.text(10, 15.5, 'Stage 3: Monitoring & Observability Stack (Separate from Stage 2)',
                ha='center', va='center', fontsize=16, fontweight='bold', color=self.colors['text'])
        
        # Stage 2 vs Stage 3 Comparison
        ax.text(5, 14.5, 'Stage 2: Basic Monitoring', ha='center', va='center', fontsize=12, fontweight='bold', color=self.colors['stage2'])
        ax.text(15, 14.5, 'Stage 3: Advanced Monitoring', ha='center', va='center', fontsize=12, fontweight='bold', color=self.colors['stage3'])
        
        # Stage 2 Monitoring
        self.create_box(ax, 2, 12, 6, 1.5, 'CloudWatch\n(Basic)', self.colors['stage2'])
        self.create_box(ax, 2, 10, 6, 1.5, 'Basic Logs\n(Application)', self.colors['stage2'])
        self.create_box(ax, 2, 8, 6, 1.5, 'Simple Alerts\n(Email)', self.colors['stage2'])
        
        # Stage 3 Monitoring Stack
        # Prometheus
        self.create_box(ax, 12, 12, 6, 1.5, 'Prometheus\n(Metrics Collection)', self.colors['prometheus'])
        
        # Grafana
        self.create_box(ax, 12, 10, 6, 1.5, 'Grafana\n(Visualization)', self.colors['grafana'])
        
        # ELK Stack
        self.create_box(ax, 12, 8, 6, 1.5, 'ELK Stack\n(Logging)', self.colors['elasticsearch'])
        
        # Jaeger
        self.create_box(ax, 12, 6, 6, 1.5, 'Jaeger\n(Distributed Tracing)', self.colors['istio'])
        
        # Namespace Separation
        ax.text(10, 4.5, 'Kubernetes Namespace Separation', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['text'])
        self.create_box(ax, 2, 3, 6, 1, 'healthcare\n(Stage 2)', self.colors['stage2'])
        self.create_box(ax, 12, 3, 6, 1, 'healthcare-stage3-dev\n(Stage 3)', self.colors['stage3'])
        
        # Monitoring Namespaces
        self.create_box(ax, 12, 1.5, 6, 1, 'monitoring-stage3\n(Stage 3)', self.colors['prometheus'])
        
        # Connections
        self.create_arrow(ax, (5, 12.75), (12, 12.75), self.colors['stage3'], '->', 2)
        self.create_arrow(ax, (5, 10.75), (12, 10.75), self.colors['stage3'], '->', 2)
        self.create_arrow(ax, (5, 8.75), (12, 8.75), self.colors['stage3'], '->', 2)
        
        ax.set_xticks([])
        ax.set_yticks([])
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.spines['bottom'].set_visible(False)
        ax.spines['left'].set_visible(False)
        
        plt.tight_layout()
        plt.savefig(self.output_dir / '04_monitoring_observability.png', dpi=300, bbox_inches='tight')
        plt.close()
        print("✅ Generated: 04_monitoring_observability.png")
    
    def generate_gitops_workflow(self):
        """Generate Stage 3 GitOps workflow diagram"""
        fig, ax = plt.subplots(1, 1, figsize=(20, 16))
        ax.set_xlim(0, 20)
        ax.set_ylim(0, 16)
        ax.set_aspect('equal')
        
        # Title
        ax.text(10, 15.5, 'Stage 3: GitOps Workflow with ArgoCD (Separate from Stage 2)',
                ha='center', va='center', fontsize=16, fontweight='bold', color=self.colors['text'])
        
        # Git Repository
        ax.text(10, 14.5, 'Git Repository: Health_Care_Management_System', ha='center', va='center', fontsize=12, color=self.colors['github'])
        
        # Stage 2 vs Stage 3 Comparison
        ax.text(5, 13.5, 'Stage 2: Direct Deployment', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['stage2'])
        ax.text(15, 13.5, 'Stage 3: GitOps Deployment', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['stage3'])
        
        # Stage 2 Flow
        self.create_box(ax, 2, 11, 6, 1, 'GitHub Actions\n(Stage 2)', self.colors['stage2'])
        self.create_box(ax, 2, 9, 6, 1, 'Direct kubectl\napply', self.colors['stage2'])
        self.create_box(ax, 2, 7, 6, 1, 'healthcare\nnamespace', self.colors['stage2'])
        
        # Stage 3 Flow
        self.create_box(ax, 12, 11, 6, 1, 'GitHub Actions\n(Stage 3)', self.colors['stage3'])
        self.create_box(ax, 12, 9, 6, 1, 'ArgoCD\n(GitOps)', self.colors['argocd'])
        self.create_box(ax, 12, 7, 6, 1, 'healthcare-stage3-dev\nnamespace', self.colors['stage3'])
        
        # ArgoCD Configuration
        ax.text(10, 5.5, 'ArgoCD Application Configuration', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['text'])
        self.create_box(ax, 8, 4, 4, 1, 'healthcare-stage3\nproject', self.colors['argocd'])
        self.create_box(ax, 8, 2.5, 4, 1, 'healthcare-stage3-app\napplication', self.colors['argocd'])
        
        # GitOps Repository Structure
        ax.text(10, 1.5, 'GitOps Repository Structure', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['text'])
        self.create_box(ax, 2, 0.5, 4, 0.8, 'Project-Stage-2-*/k8s/\n(Stage 2)', self.colors['stage2'])
        self.create_box(ax, 8, 0.5, 4, 0.8, 'Project-Stage-3-*/k8s/\n(Stage 3)', self.colors['stage3'])
        
        # Connections
        self.create_arrow(ax, (5, 11.5), (5, 10), self.colors['stage2'], '->', 2)
        self.create_arrow(ax, (5, 9), (5, 7.5), self.colors['stage2'], '->', 2)
        
        self.create_arrow(ax, (15, 11.5), (15, 10), self.colors['stage3'], '->', 2)
        self.create_arrow(ax, (15, 9), (15, 7.5), self.colors['stage3'], '->', 2)
        
        self.create_arrow(ax, (15, 9), (12, 4.5), self.colors['argocd'], '->', 2)
        self.create_arrow(ax, (12, 4.5), (10, 2.5), self.colors['argocd'], '->', 2)
        
        ax.set_xticks([])
        ax.set_yticks([])
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.spines['bottom'].set_visible(False)
        ax.spines['left'].set_visible(False)
        
        plt.tight_layout()
        plt.savefig(self.output_dir / '05_gitops_workflow.png', dpi=300, bbox_inches='tight')
        plt.close()
        print("✅ Generated: 05_gitops_workflow.png")
    
    def generate_directory_structure(self):
        """Generate Stage 3 directory structure diagram"""
        fig, ax = plt.subplots(1, 1, figsize=(20, 16))
        ax.set_xlim(0, 20)
        ax.set_ylim(0, 16)
        ax.set_aspect('equal')
        
        # Title
        ax.text(10, 15.5, 'Stage 3: Directory Structure (Complete Separation)',
                ha='center', va='center', fontsize=16, fontweight='bold', color=self.colors['text'])
        
        # Root Directory
        ax.text(10, 14.5, 'Health_Care_Management_System/', ha='center', va='center', fontsize=12, fontweight='bold', color=self.colors['text'])
        
        # Project Stages
        ax.text(10, 13.5, 'Project-Stages/', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['text'])
        
        # Stage 1
        ax.text(3, 12.5, 'Project-Stage-1-Basic-CI-CD-Deploy/', ha='center', va='center', fontsize=10, color=self.colors['stage1'])
        self.create_box(ax, 1, 11, 4, 1, 'src-code/\nk8s/\nscripts/\ndocs/', self.colors['stage1'], alpha=0.7, text_color='white')
        
        # Stage 2
        ax.text(10, 12.5, 'Project-Stage-2-Automated-CI-CD-Pipeline/', ha='center', va='center', fontsize=10, color=self.colors['stage2'])
        self.create_box(ax, 8, 11, 4, 1, 'src-code/\nk8s/\nscripts/\ndocs/\n.github/', self.colors['stage2'], alpha=0.7, text_color='white')
        
        # Stage 3
        ax.text(17, 12.5, 'Project-Stage-3-Advanced-DevOps-Pipeline/', ha='center', va='center', fontsize=10, color=self.colors['stage3'])
        self.create_box(ax, 15, 11, 4, 1, 'src-code/\nterraform/\nmonitoring/\nlogging/\nargocd/\ngitops/\nk8s/\nscripts/\ndocs/', self.colors['stage3'], alpha=0.7, text_color='white')
        
        # GitHub Actions
        ax.text(10, 9.5, '.github/workflows/', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['text'])
        self.create_box(ax, 6, 8, 2.5, 1, 'stage1-ci.yml\n(Stage 1)', self.colors['stage1'], alpha=0.8, text_color='white')
        self.create_box(ax, 9, 8, 2.5, 1, 'stage2-ci.yml\n(Stage 2)', self.colors['stage2'], alpha=0.8, text_color='white')
        self.create_box(ax, 12, 8, 2.5, 1, 'stage3-ci.yml\n(Stage 3)', self.colors['stage3'], alpha=0.8, text_color='white')
        
        # Key Features
        ax.text(10, 6.5, 'Key Features of Stage 3 Structure', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['text'])
        
        features = [
            ('Complete Separation', 'Each stage is independent'),
            ('Same AWS Region', 'Reuse existing infrastructure'),
            ('Separate Pipelines', 'Clear workflow boundaries'),
            ('Copy Foundation', 'Build upon Stage 2 success'),
            ('Enhanced Tools', 'Terraform, ArgoCD, Monitoring')
        ]
        
        for i, (feature, description) in enumerate(features):
            y_pos = 5.5 - i * 0.8
            self.create_box(ax, 2, y_pos-0.3, 6, 0.6, f'{feature}\n{description}', self.colors['stage3'], alpha=0.7, text_color='white')
        
        # Benefits
        ax.text(15, 6.5, 'Benefits', ha='center', va='center', fontsize=11, fontweight='bold', color=self.colors['text'])
        benefits = [
            'No Conflicts',
            'Student Clarity',
            'Easy Maintenance',
            'Cost Effective',
            'Real-world Pattern'
        ]
        
        for i, benefit in enumerate(benefits):
            y_pos = 5.5 - i * 0.6
            self.create_box(ax, 12, y_pos-0.2, 6, 0.4, benefit, self.colors['success'], alpha=0.8, text_color='white')
        
        ax.set_xticks([])
        ax.set_yticks([])
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.spines['bottom'].set_visible(False)
        ax.spines['left'].set_visible(False)
        
        plt.tight_layout()
        plt.savefig(self.output_dir / '06_directory_structure.png', dpi=300, bbox_inches='tight')
        plt.close()
        print("✅ Generated: 06_directory_structure.png")
    
    def generate_all_diagrams(self):
        """Generate all Stage 3 diagrams"""
        print("🚀 Generating Stage 3 Architecture Diagrams...")
        print("📋 Based on Practical Approach: Separate Directories, Same AWS Region, Separate Pipelines")
        print("=" * 80)
        
        try:
            self.generate_overall_architecture()
            self.generate_infrastructure_architecture()
            self.generate_cicd_pipeline()
            self.generate_monitoring_observability()
            self.generate_gitops_workflow()
            self.generate_directory_structure()
            
            print("=" * 80)
            print("🎉 All Stage 3 diagrams generated successfully!")
            print(f"📁 Output directory: {self.output_dir}")
            print("📋 Generated diagrams:")
            print("  - 01_overall_architecture.png")
            print("  - 02_infrastructure_architecture.png")
            print("  - 03_cicd_pipeline.png")
            print("  - 04_monitoring_observability.png")
            print("  - 05_gitops_workflow.png")
            print("  - 06_directory_structure.png")
            
        except Exception as e:
            print(f"❌ Error generating diagrams: {e}")
            import traceback
            traceback.print_exc()

def main():
    """Main function to generate all diagrams"""
    generator = Stage3DiagramGenerator()
    generator.generate_all_diagrams()

if __name__ == "__main__":
    main() 