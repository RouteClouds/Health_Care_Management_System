#!/usr/bin/env python3
"""
Health Care Management System - Current Architecture Diagram (Simplified)
Creates architecture diagrams using matplotlib (no external dependencies)
Focuses on current 4-container Docker implementation
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch, Circle
import numpy as np
import os
import sys

def create_current_architecture_diagram():
    """Create current system architecture diagram with actual implementation."""
    
    print("🎨 Generating Current Application Architecture Diagram...")
    
    # Create figure with high DPI for crisp output
    fig, ax = plt.subplots(1, 1, figsize=(18, 16))
    ax.set_xlim(0, 18)
    ax.set_ylim(0, 16)
    ax.axis('off')
    
    # Modern color palette
    colors = {
        'docker_blue': '#0db7ed',
        'react_blue': '#61dafb',
        'node_green': '#68a063',
        'postgres_blue': '#336791',
        'nginx_green': '#009639',
        'user_purple': '#6f42c1',
        'api_orange': '#fd7e14',
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
    title_box = FancyBboxPatch((1, 14.5), 16, 1.2, 
                              boxstyle="round,pad=0.1", 
                              facecolor=colors['docker_blue'], 
                              edgecolor='white', 
                              linewidth=3)
    ax.add_patch(title_box)
    ax.text(9, 15.1, '🏥 Health Care Management System - Application Architecture', 
            fontsize=22, fontweight='bold', ha='center', color='white')
    ax.text(9, 14.7, 'Current Implementation: React + Node.js + PostgreSQL + Docker', 
            fontsize=12, ha='center', color='white', style='italic')
    
    # User Layer
    user_box = FancyBboxPatch((1, 12.5), 16, 1.5, 
                             boxstyle="round,pad=0.1", 
                             facecolor=colors['user_purple'], 
                             edgecolor='white', 
                             linewidth=2)
    ax.add_patch(user_box)
    ax.text(9, 13.5, '👥 Users & Access Points', 
            fontsize=16, fontweight='bold', ha='center', color='white')
    
    # User types
    users = [
        {'name': '👨‍⚕️ Doctors', 'pos': (2, 13), 'desc': 'Medical Staff'},
        {'name': '🏥 Patients', 'pos': (6, 13), 'desc': 'Healthcare Seekers'},
        {'name': '👨‍💼 Admin', 'pos': (10, 13), 'desc': 'System Admin'},
        {'name': '🌐 Web Browser', 'pos': (14, 13), 'desc': 'Access Method'}
    ]
    
    for user in users:
        ax.text(user['pos'][0], user['pos'][1], user['name'], 
                fontsize=11, ha='center', color='white', fontweight='bold')
        ax.text(user['pos'][0], user['pos'][1] - 0.3, user['desc'], 
                fontsize=9, ha='center', color='lightgray')
    
    # Frontend Layer
    frontend_box = FancyBboxPatch((1, 10), 7, 2, 
                                 boxstyle="round,pad=0.1", 
                                 facecolor=colors['react_blue'], 
                                 edgecolor='white', 
                                 linewidth=2)
    ax.add_patch(frontend_box)
    ax.text(4.5, 11.5, '⚛️ Frontend Layer (React)', 
            fontsize=14, fontweight='bold', ha='center', color='white')
    
    frontend_components = [
        'React 18 + TypeScript',
        'Redux Toolkit (State)',
        'Tailwind CSS (Styling)',
        'React Router (Navigation)',
        'Vite (Build Tool)'
    ]
    
    for i, comp in enumerate(frontend_components):
        ax.text(4.5, 11.2 - (i * 0.2), f"• {comp}", 
                fontsize=9, ha='center', color='white')
    
    # Backend Layer
    backend_box = FancyBboxPatch((10, 10), 7, 2, 
                                boxstyle="round,pad=0.1", 
                                facecolor=colors['node_green'], 
                                edgecolor='white', 
                                linewidth=2)
    ax.add_patch(backend_box)
    ax.text(13.5, 11.5, '🔧 Backend Layer (Node.js)', 
            fontsize=14, fontweight='bold', ha='center', color='white')
    
    backend_components = [
        'Node.js 20 + Express',
        'Prisma ORM',
        'JWT Authentication',
        'RESTful APIs',
        'TypeScript'
    ]
    
    for i, comp in enumerate(backend_components):
        ax.text(13.5, 11.2 - (i * 0.2), f"• {comp}", 
                fontsize=9, ha='center', color='white')
    
    # API Layer
    api_box = FancyBboxPatch((4, 8), 10, 1.5, 
                            boxstyle="round,pad=0.1", 
                            facecolor=colors['api_orange'], 
                            edgecolor='white', 
                            linewidth=2)
    ax.add_patch(api_box)
    ax.text(9, 8.9, '🔌 API Endpoints (Current Implementation)', 
            fontsize=14, fontweight='bold', ha='center', color='white')
    
    api_endpoints = [
        '/api/auth/* - Authentication & Registration',
        '/api/doctors/* - Doctor Management & Listings',
        '/api/appointments/* - Appointment Booking & Management'
    ]
    
    for i, endpoint in enumerate(api_endpoints):
        ax.text(9, 8.6 - (i * 0.2), endpoint, 
                fontsize=9, ha='center', color='white')
    
    # Database Layer
    db_box = FancyBboxPatch((1, 5.5), 16, 2, 
                           boxstyle="round,pad=0.1", 
                           facecolor=colors['postgres_blue'], 
                           edgecolor='white', 
                           linewidth=2)
    ax.add_patch(db_box)
    ax.text(9, 7, '🗄️ Database Layer (PostgreSQL)', 
            fontsize=14, fontweight='bold', ha='center', color='white')
    
    # Database tables
    db_tables = [
        {'name': 'Users', 'pos': (3, 6.3), 'desc': 'Authentication\nUser Profiles'},
        {'name': 'Doctors', 'pos': (7, 6.3), 'desc': '5 Specialists\nDepartments'},
        {'name': 'Appointments', 'pos': (11, 6.3), 'desc': 'Booking System\nScheduling'},
        {'name': 'Departments', 'pos': (15, 6.3), 'desc': 'Medical Depts\nSpecializations'}
    ]
    
    for table in db_tables:
        table_box = FancyBboxPatch((table['pos'][0] - 0.8, table['pos'][1] - 0.4), 1.6, 0.8, 
                                  boxstyle="round,pad=0.05", 
                                  facecolor='white', 
                                  edgecolor=colors['postgres_blue'], 
                                  linewidth=1, alpha=0.9)
        ax.add_patch(table_box)
        ax.text(table['pos'][0], table['pos'][1], table['name'], 
                fontsize=10, ha='center', fontweight='bold', color=colors['postgres_blue'])
        ax.text(table['pos'][0], table['pos'][1] - 0.25, table['desc'], 
                fontsize=8, ha='center', color=colors['text_secondary'])
    
    # Docker Container Layer
    docker_box = FancyBboxPatch((1, 3), 16, 2, 
                               boxstyle="round,pad=0.1", 
                               facecolor=colors['docker_blue'], 
                               edgecolor='white', 
                               linewidth=2)
    ax.add_patch(docker_box)
    ax.text(9, 4.5, '🐳 Docker Container Architecture', 
            fontsize=14, fontweight='bold', ha='center', color='white')
    
    # Docker containers
    containers = [
        {'name': 'Nginx', 'pos': (3, 3.8), 'ports': '80/443'},
        {'name': 'Frontend', 'pos': (7, 3.8), 'ports': '5173→80'},
        {'name': 'Backend', 'pos': (11, 3.8), 'ports': '3002'},
        {'name': 'Database', 'pos': (15, 3.8), 'ports': '5432'}
    ]
    
    for container in containers:
        container_box = FancyBboxPatch((container['pos'][0] - 0.8, container['pos'][1] - 0.3), 1.6, 0.6, 
                                      boxstyle="round,pad=0.05", 
                                      facecolor='white', 
                                      edgecolor=colors['docker_blue'], 
                                      linewidth=1, alpha=0.9)
        ax.add_patch(container_box)
        ax.text(container['pos'][0], container['pos'][1], container['name'], 
                fontsize=10, ha='center', fontweight='bold', color=colors['docker_blue'])
        ax.text(container['pos'][0], container['pos'][1] - 0.2, f":{container['ports']}", 
                fontsize=8, ha='center', color=colors['text_secondary'])
    
    # Current Features
    features_box = FancyBboxPatch((1, 0.5), 16, 2, 
                                 boxstyle="round,pad=0.1", 
                                 facecolor=colors['success'], 
                                 edgecolor='white', 
                                 linewidth=2)
    ax.add_patch(features_box)
    ax.text(9, 2, '✅ Current Implemented Features', 
            fontsize=14, fontweight='bold', ha='center', color='white')
    
    current_features = [
        '🔐 User Authentication (Registration, Login, JWT)',
        '👨‍⚕️ Doctor Management (5 Specialists, Search, Filter)',
        '📅 Appointment System (Booking UI, Management, APIs)',
        '🏥 Healthcare Services (Cardiology, Neurology, Orthopedics, etc.)',
        '🐳 Docker Deployment (4 Containers, Health Monitoring)'
    ]
    
    for i, feature in enumerate(current_features):
        ax.text(9, 1.7 - (i * 0.2), feature, 
                fontsize=10, ha='center', color='white')
    
    # Add workflow arrows
    add_workflow_arrows(ax, colors)
    
    return fig

def add_workflow_arrows(ax, colors):
    """Add workflow arrows showing data flow."""
    
    # User to Frontend
    user_to_frontend = ConnectionPatch((9, 12.5), (4.5, 12), 
                                      "data", "data",
                                      arrowstyle="->", 
                                      shrinkA=5, shrinkB=5,
                                      mutation_scale=15, 
                                      fc=colors['user_purple'], 
                                      ec=colors['user_purple'],
                                      linewidth=2)
    ax.add_patch(user_to_frontend)
    ax.text(6.5, 12.3, 'HTTPS\nRequests', fontsize=8, ha='center', 
            bbox=dict(boxstyle="round,pad=0.2", facecolor='white', alpha=0.8))
    
    # Frontend to Backend
    frontend_to_backend = ConnectionPatch((8, 11), (10, 11), 
                                         "data", "data",
                                         arrowstyle="->", 
                                         shrinkA=5, shrinkB=5,
                                         mutation_scale=15, 
                                         fc=colors['api_orange'], 
                                         ec=colors['api_orange'],
                                         linewidth=2)
    ax.add_patch(frontend_to_backend)
    ax.text(9, 11.3, 'REST API\nCalls', fontsize=8, ha='center',
            bbox=dict(boxstyle="round,pad=0.2", facecolor='white', alpha=0.8))
    
    # Backend to Database
    backend_to_db = ConnectionPatch((13.5, 10), (9, 7.5), 
                                   "data", "data",
                                   arrowstyle="->", 
                                   shrinkA=5, shrinkB=5,
                                   mutation_scale=15, 
                                   fc=colors['postgres_blue'], 
                                   ec=colors['postgres_blue'],
                                   linewidth=2)
    ax.add_patch(backend_to_db)
    ax.text(11.5, 8.8, 'Prisma ORM\nSQL Queries', fontsize=8, ha='center',
            bbox=dict(boxstyle="round,pad=0.2", facecolor='white', alpha=0.8))

def save_diagram(fig):
    """Save the diagram in multiple formats."""
    
    # Ensure output directory exists
    output_dir = "/home/ubuntu/Projects/Health_Care_Management_System/Project-Docs/Images/App-Arch"
    os.makedirs(output_dir, exist_ok=True)
    
    # Save in multiple formats
    formats = [
        ('png', 300),  # High-resolution PNG
        ('pdf', None), # Vector PDF
        ('svg', None)  # Vector SVG
    ]
    
    for fmt, dpi in formats:
        filename = f"{output_dir}/current-application-architecture.{fmt}"
        if dpi:
            fig.savefig(filename, format=fmt, dpi=dpi, bbox_inches='tight', 
                       facecolor='white', edgecolor='none')
        else:
            fig.savefig(filename, format=fmt, bbox_inches='tight', 
                       facecolor='white', edgecolor='none')
        print(f"✅ Saved: {filename}")

def main():
    """Main function to generate the application architecture diagram."""
    
    print("🎨 Starting Current Application Architecture Diagram Generation...")
    print("=" * 80)
    
    # Create diagram
    fig = create_current_architecture_diagram()
    
    # Save diagram
    save_diagram(fig)
    
    print("=" * 80)
    print("🎉 Current Application Architecture Diagram Generated Successfully!")
    print("")
    print("📁 Generated files:")
    print("   • current-application-architecture.png (High-resolution)")
    print("   • current-application-architecture.pdf (Vector)")
    print("   • current-application-architecture.svg (Vector)")
    print("")
    print("📍 Location: /home/ubuntu/Projects/Health_Care_Management_System/Project-Docs/Images/App-Arch/")
    print("🎯 Features: Current implementation, actual features, Docker architecture")

if __name__ == "__main__":
    main()
