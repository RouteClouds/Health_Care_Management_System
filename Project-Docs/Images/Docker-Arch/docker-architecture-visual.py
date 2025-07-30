#!/usr/bin/env python3
"""
Health Care Management System - Docker Architecture Visual Diagram Generator
Generates professional PNG diagrams with modern icons, detailed ports, and workflow visualization.

Author: Health Care Management System Team
Date: July 28, 2025
Version: 2.0 - Production Docker Architecture
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch, Circle
import numpy as np
import os
import sys

def install_dependencies():
    """Auto-install required dependencies if not available."""
    try:
        import matplotlib
        import numpy
        print("✅ All dependencies available")
    except ImportError as e:
        print(f"📦 Installing missing dependency: {e.name}")
        import subprocess
        subprocess.check_call([sys.executable, "-m", "pip", "install", "matplotlib", "numpy"])
        print("✅ Dependencies installed successfully")

def create_docker_architecture_diagram():
    """Create comprehensive Docker architecture diagram with modern styling."""
    
    # Install dependencies if needed
    install_dependencies()
    
    print("🎨 Generating Professional Docker Architecture Diagram...")
    
    # Create figure with high DPI for crisp output
    fig, ax = plt.subplots(1, 1, figsize=(20, 14))
    ax.set_xlim(0, 20)
    ax.set_ylim(0, 14)
    ax.axis('off')
    
    # Modern color palette
    colors = {
        'docker_blue': '#0db7ed',
        'react_blue': '#61dafb',
        'node_green': '#68a063',
        'postgres_blue': '#336791',
        'nginx_green': '#009639',
        'background': '#f8f9fa',
        'border': '#dee2e6',
        'text_primary': '#212529',
        'text_secondary': '#6c757d',
        'success': '#28a745',
        'warning': '#ffc107',
        'info': '#17a2b8'
    }
    
    # Set background
    fig.patch.set_facecolor(colors['background'])
    
    # Title section
    title_box = FancyBboxPatch((1, 12.5), 18, 1.2, 
                              boxstyle="round,pad=0.1", 
                              facecolor=colors['docker_blue'], 
                              edgecolor='white', 
                              linewidth=3)
    ax.add_patch(title_box)
    ax.text(10, 13.1, '🐳 Health Care Management System - Docker Production Architecture', 
            fontsize=24, fontweight='bold', ha='center', color='white')
    ax.text(10, 12.7, 'Containerized Multi-Service Architecture with Health Monitoring & Load Balancing', 
            fontsize=14, ha='center', color='white', style='italic')
    
    # Docker Host Container
    host_box = FancyBboxPatch((0.5, 1), 19, 11, 
                             boxstyle="round,pad=0.2", 
                             facecolor='white', 
                             edgecolor=colors['docker_blue'], 
                             linewidth=3)
    ax.add_patch(host_box)
    ax.text(1, 11.5, '🖥️ Docker Host (Ubuntu Linux)', 
            fontsize=16, fontweight='bold', color=colors['docker_blue'])
    ax.text(1, 11.1, 'Container Runtime: Docker Engine 24.0+', 
            fontsize=12, color=colors['text_secondary'])
    
    # Network section
    network_box = FancyBboxPatch((1, 9.5), 18, 1.2, 
                                boxstyle="round,pad=0.1", 
                                facecolor=colors['info'], 
                                edgecolor='white', 
                                linewidth=2, alpha=0.8)
    ax.add_patch(network_box)
    ax.text(10, 10.1, '🌐 Docker Network: healthcare-network (bridge)', 
            fontsize=14, fontweight='bold', ha='center', color='white')
    ax.text(10, 9.7, 'Inter-container communication with DNS resolution', 
            fontsize=11, ha='center', color='white')
    
    return fig, ax, colors

def add_containers(ax, colors):
    """Add all Docker containers with detailed information."""
    
    # Container positions and details
    containers = [
        {
            'name': 'Nginx Proxy',
            'service': 'healthcare-nginx',
            'icon': '🌐',
            'color': colors['nginx_green'],
            'pos': (2, 7.3),
            'size': (3.5, 2.0),
            'details': ['Nginx 1.25 Alpine', 'Reverse Proxy', 'Load Balancer', 'SSL Termination'],
            'ports': ['80:80', '443:443'],
            'status': '✅ Healthy'
        },
        {
            'name': 'Frontend',
            'service': 'healthcare-frontend',
            'icon': '⚛️',
            'color': colors['react_blue'],
            'pos': (6.5, 7.3),
            'size': (3.5, 2.0),
            'details': ['React 18 + TypeScript', 'Vite Build Tool', 'Tailwind CSS', 'Redux Toolkit'],
            'ports': ['5173:80'],
            'status': '✅ Healthy'
        },
        {
            'name': 'Backend API',
            'service': 'healthcare-backend',
            'icon': '🔧',
            'color': colors['node_green'],
            'pos': (11, 7.3),
            'size': (3.5, 2.0),
            'details': ['Node.js 20 LTS', 'Express.js', 'Prisma ORM', 'JWT Auth'],
            'ports': ['3002:3002'],
            'status': '✅ Healthy'
        },
        {
            'name': 'Database',
            'service': 'healthcare-db',
            'icon': '🗄️',
            'color': colors['postgres_blue'],
            'pos': (15.5, 7.3),
            'size': (3.5, 2.0),
            'details': ['PostgreSQL 15', 'Alpine Linux', 'Persistent Storage', 'Health Checks'],
            'ports': ['5432:5432'],
            'status': '✅ Healthy'
        }
    ]
    
    # Draw containers
    for container in containers:
        # Main container box
        container_box = FancyBboxPatch(
            container['pos'], container['size'][0], container['size'][1],
            boxstyle="round,pad=0.1",
            facecolor=container['color'],
            edgecolor='white',
            linewidth=2
        )
        ax.add_patch(container_box)
        
        # Container header
        x, y = container['pos']
        ax.text(x + container['size'][0]/2, y + container['size'][1] - 0.15,
                f"{container['icon']} {container['name']}",
                fontsize=12, fontweight='bold', ha='center', color='white')

        # Service name
        ax.text(x + container['size'][0]/2, y + container['size'][1] - 0.4,
                container['service'],
                fontsize=10, ha='center', color='white', style='italic')

        # Details - with better spacing
        for i, detail in enumerate(container['details']):
            ax.text(x + container['size'][0]/2, y + container['size'][1] - 0.65 - (i * 0.18),
                    detail, fontsize=9, ha='center', color='white')

        # Ports - on separate line with clear spacing
        ports_text = ' | '.join(container['ports'])
        ax.text(x + container['size'][0]/2, y + 0.35,
                "Ports:",
                fontsize=9, ha='center', color='lightblue', fontweight='bold')
        ax.text(x + container['size'][0]/2, y + 0.18,
                ports_text,
                fontsize=10, ha='center', color='white', fontweight='bold')

        # Status
        ax.text(x + container['size'][0]/2, y + 0.02,
                container['status'],
                fontsize=8, ha='center', color='lightgreen', fontweight='bold')
    
    return containers

def add_workflow_arrows(ax, containers, colors):
    """Add workflow arrows showing data flow between containers."""
    
    # Define connections with labels
    connections = [
        {
            'from': 0,  # Nginx
            'to': 1,    # Frontend
            'label': 'HTTP/HTTPS\nStatic Files',
            'color': colors['nginx_green']
        },
        {
            'from': 1,  # Frontend
            'to': 2,    # Backend
            'label': 'API Calls\nREST/JSON',
            'color': colors['react_blue']
        },
        {
            'from': 2,  # Backend
            'to': 3,    # Database
            'label': 'SQL Queries\nPrisma ORM',
            'color': colors['node_green']
        }
    ]
    
    # Draw connections
    for conn in connections:
        from_container = containers[conn['from']]
        to_container = containers[conn['to']]
        
        # Calculate connection points
        from_x = from_container['pos'][0] + from_container['size'][0]
        from_y = from_container['pos'][1] + from_container['size'][1]/2
        
        to_x = to_container['pos'][0]
        to_y = to_container['pos'][1] + to_container['size'][1]/2
        
        # Draw arrow
        arrow = ConnectionPatch((from_x, from_y), (to_x, to_y), 
                               "data", "data",
                               arrowstyle="->", 
                               shrinkA=5, shrinkB=5,
                               mutation_scale=20, 
                               fc=conn['color'], 
                               ec=conn['color'],
                               linewidth=3)
        ax.add_patch(arrow)
        
        # Add label
        mid_x = (from_x + to_x) / 2
        mid_y = (from_y + to_y) / 2 + 0.4
        ax.text(mid_x, mid_y, conn['label'],
                fontsize=9, ha='center', va='center',
                bbox=dict(boxstyle="round,pad=0.3", facecolor='white', alpha=0.9),
                color=colors['text_primary'], fontweight='bold')

def add_external_access(ax, colors):
    """Add external access points and user interactions."""
    
    # External user
    user_circle = Circle((0.5, 4), 0.4, facecolor=colors['info'], edgecolor='white', linewidth=2)
    ax.add_patch(user_circle)
    ax.text(0.5, 4, '👤', fontsize=20, ha='center', va='center')
    ax.text(0.5, 3.3, 'Users\n(Patients/Doctors)', fontsize=10, ha='center', fontweight='bold')
    
    # Internet cloud
    internet_box = FancyBboxPatch((0.2, 5.5), 1.6, 1, 
                                 boxstyle="round,pad=0.1", 
                                 facecolor=colors['warning'], 
                                 edgecolor='white', 
                                 linewidth=2)
    ax.add_patch(internet_box)
    ax.text(1, 6, '☁️ Internet', fontsize=12, ha='center', fontweight='bold', color='white')
    
    # Connection from internet to nginx
    internet_arrow = ConnectionPatch((1.8, 6), (2, 8.3),
                                   "data", "data",
                                   arrowstyle="->",
                                   shrinkA=5, shrinkB=5,
                                   mutation_scale=20,
                                   fc=colors['warning'],
                                   ec=colors['warning'],
                                   linewidth=3)
    ax.add_patch(internet_arrow)
    
    # Add access URLs
    ax.text(1, 5.2, 'Access Points:', fontsize=10, fontweight='bold')
    ax.text(1, 4.9, '• http://localhost:80', fontsize=9)
    ax.text(1, 4.6, '• http://localhost:5173', fontsize=9)
    ax.text(1, 4.3, '• http://localhost:3002/api', fontsize=9)

def add_performance_metrics(ax, colors):
    """Add performance metrics and system information."""
    
    # Performance box
    perf_box = FancyBboxPatch((1, 1.5), 8, 2.5, 
                             boxstyle="round,pad=0.1", 
                             facecolor='white', 
                             edgecolor=colors['success'], 
                             linewidth=2)
    ax.add_patch(perf_box)
    
    ax.text(5, 3.7, '📊 Performance Metrics', fontsize=14, fontweight='bold', ha='center', color=colors['success'])
    
    metrics = [
        '• Total Memory Usage: ~107MB',
        '• Startup Time: <12 seconds',
        '• Health Check Interval: 30s',
        '• Container Images: ~515MB total',
        '• Network Latency: <5ms internal',
        '• API Response Time: <100ms avg'
    ]
    
    for i, metric in enumerate(metrics):
        ax.text(1.5, 3.3 - (i * 0.25), metric, fontsize=10, color=colors['text_primary'])

def add_health_monitoring(ax, colors):
    """Add health monitoring and status information."""
    
    # Health monitoring box
    health_box = FancyBboxPatch((10, 1.5), 8.5, 2.5, 
                               boxstyle="round,pad=0.1", 
                               facecolor='white', 
                               edgecolor=colors['success'], 
                               linewidth=2)
    ax.add_patch(health_box)
    
    ax.text(14.25, 3.7, '🏥 Health Monitoring', fontsize=14, fontweight='bold', ha='center', color=colors['success'])
    
    health_info = [
        '• All containers: ✅ Healthy',
        '• Auto-restart: enabled',
        '• Health check: every 30s',
        '• Logging: centralized',
        '• Backup: automated daily',
        '• Monitoring: real-time'
    ]
    
    for i, info in enumerate(health_info):
        ax.text(10.5, 3.3 - (i * 0.25), info, fontsize=10, color=colors['text_primary'])

def save_diagram(fig):
    """Save the diagram in multiple formats."""
    
    # Ensure output directory exists
    output_dir = "/home/ubuntu/Projects/Health_Care_Management_System/Project-Docs/Images/Docker-Arch"
    os.makedirs(output_dir, exist_ok=True)
    
    # Save in multiple formats
    formats = [
        ('png', 300),  # High-resolution PNG
        ('pdf', None), # Vector PDF
        ('svg', None)  # Vector SVG
    ]
    
    for fmt, dpi in formats:
        filename = f"{output_dir}/docker-architecture-professional.{fmt}"
        if dpi:
            fig.savefig(filename, format=fmt, dpi=dpi, bbox_inches='tight', 
                       facecolor='white', edgecolor='none')
        else:
            fig.savefig(filename, format=fmt, bbox_inches='tight', 
                       facecolor='white', edgecolor='none')
        print(f"✅ Saved: {filename}")

def main():
    """Main function to generate the Docker architecture diagram."""
    
    print("🎨 Starting Professional Docker Architecture Diagram Generation...")
    print("=" * 80)
    
    # Create base diagram
    fig, ax, colors = create_docker_architecture_diagram()
    
    # Add all components
    containers = add_containers(ax, colors)
    add_workflow_arrows(ax, containers, colors)
    add_external_access(ax, colors)
    add_performance_metrics(ax, colors)
    add_health_monitoring(ax, colors)
    
    # Save diagram
    save_diagram(fig)
    
    print("=" * 80)
    print("🎉 Professional Docker Architecture Diagram Generated Successfully!")
    print("")
    print("📁 Generated files:")
    print("   • docker-architecture-professional.png (High-resolution)")
    print("   • docker-architecture-professional.pdf (Vector)")
    print("   • docker-architecture-professional.svg (Vector)")
    print("")
    print("📍 Location: /home/ubuntu/Projects/Health_Care_Management_System/Project-Docs/Images/Docker-Arch/")
    print("🎯 Features: Modern icons, detailed ports, workflow arrows, performance metrics")

if __name__ == "__main__":
    main()
