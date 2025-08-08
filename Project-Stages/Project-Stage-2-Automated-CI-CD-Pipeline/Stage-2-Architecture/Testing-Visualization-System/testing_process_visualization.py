#!/usr/bin/env python3
"""
Testing Process Visualization - Diagram as Code
Healthcare Management System - Stage 2

This script creates comprehensive diagrams showing:
1. Testing Architecture Overview
2. Test Execution Flow
3. Unit vs Integration vs E2E Testing
4. CI/CD Testing Pipeline
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.programming.framework import React
from diagrams.programming.language import JavaScript, Python
from diagrams.onprem.ci import Jenkins
from diagrams.onprem.database import PostgreSQL
from diagrams.onprem.client import Client
from diagrams.aws.compute import EKS
from diagrams.aws.storage import S3
from diagrams.generic.device import Mobile, Tablet
from diagrams.generic.network import Firewall
from diagrams.generic.storage import Storage
from diagrams.generic.compute import Rack
from diagrams.onprem.monitoring import Grafana
from diagrams.onprem.network import Nginx
from diagrams.generic.blank import Blank
import os

# Set output directory
output_dir = "testing-diagrams"
os.makedirs(output_dir, exist_ok=True)

def create_testing_architecture():
    """Create comprehensive testing architecture diagram"""
    
    with Diagram("Healthcare Testing Architecture", 
                 filename=f"{output_dir}/01_testing_architecture",
                 show=False, direction="TB"):
        
        # Developer Environment
        with Cluster("👨‍💻 Developer Environment"):
            dev_machine = Client("Developer\nMachine")
            vscode = Storage("VS Code\nIDE")
            
        # Testing Framework Layer
        with Cluster("🧪 Testing Framework Layer"):
            jest = JavaScript("Jest 30.0.4\nTest Runner")
            react_testing = React("React Testing\nLibrary")
            selenium = Rack("Selenium\nWebDriver")
            
        # Test Types
        with Cluster("📋 Test Categories"):
            with Cluster("Unit Tests"):
                unit_basic = JavaScript("Basic Function\nTests")
                unit_env = JavaScript("Environment\nVariable Tests")
                unit_dom = JavaScript("DOM Matcher\nTests")
                
            with Cluster("Integration Tests"):
                int_api = JavaScript("API Integration\nTests")
                int_db = JavaScript("Database\nConnection Tests")
                int_components = JavaScript("Component\nInteraction Tests")
                
            with Cluster("E2E Tests"):
                e2e_user = JavaScript("User Journey\nTests")
                e2e_browser = JavaScript("Browser\nAutomation Tests")
                e2e_workflow = JavaScript("Complete Workflow\nTests")
        
        # Application Under Test
        with Cluster("🏥 Healthcare Application"):
            frontend = React("Frontend\nReact App")
            backend = JavaScript("Backend\nNode.js API")
            database = PostgreSQL("PostgreSQL\nDatabase")
            
        # Test Environments
        with Cluster("🌍 Test Environments"):
            local_env = Storage("Local\nEnvironment")
            staging_env = EKS("Staging\nEKS Cluster")
            prod_env = EKS("Production\nEKS Cluster")
        
        # Connections
        dev_machine >> vscode
        vscode >> jest

        jest >> unit_basic
        jest >> unit_env
        jest >> unit_dom

        react_testing >> int_api
        react_testing >> int_db
        react_testing >> int_components

        selenium >> e2e_user
        selenium >> e2e_browser
        selenium >> e2e_workflow

        # Test targets
        unit_basic >> frontend
        unit_env >> frontend
        unit_dom >> frontend

        int_api >> backend
        int_db >> database
        int_components >> frontend

        e2e_user >> frontend
        e2e_browser >> backend
        e2e_workflow >> database

        # Environment connections
        unit_basic >> local_env
        int_api >> staging_env
        e2e_user >> prod_env

def create_test_execution_flow():
    """Create test execution flow diagram"""
    
    with Diagram("Test Execution Flow Process", 
                 filename=f"{output_dir}/02_test_execution_flow",
                 show=False, direction="LR"):
        
        # Start
        start = Storage("Code\nCommit")
        
        # Pre-test Setup
        with Cluster("🔧 Pre-Test Setup"):
            node_check = JavaScript("Node.js 20+\nVersion Check")
            deps_install = Storage("Dependencies\nInstallation")
            config_setup = Storage("Jest & Babel\nConfiguration")
            
        # Test Execution Phases
        with Cluster("🧪 Test Execution"):
            with Cluster("Phase 1: Unit Tests"):
                unit_start = JavaScript("Jest\nInitialization")
                unit_basic = JavaScript("Basic Tests\n(1+1=2)")
                unit_env = JavaScript("Environment\nVariables")
                unit_dom = JavaScript("DOM\nMatchers")
                unit_result = Storage("Unit Test\nResults")

            with Cluster("Phase 2: Integration Tests"):
                int_start = JavaScript("Integration\nSetup")
                int_api = JavaScript("API\nTests")
                int_db = JavaScript("Database\nTests")
                int_result = Storage("Integration\nResults")
                
            with Cluster("Phase 3: E2E Tests"):
                e2e_start = Rack("Selenium\nWebDriver")
                e2e_browser = Client("Chrome\nBrowser")
                e2e_app = React("Running\nApplication")
                e2e_result = Storage("E2E Test\nResults")
        
        # Results Processing
        with Cluster("📊 Results Processing"):
            coverage = Grafana("Coverage\nReport")
            summary = Storage("Test\nSummary")
            
        # Flow connections
        start >> node_check >> deps_install >> config_setup
        
        config_setup >> unit_start
        unit_start >> unit_basic >> unit_env >> unit_dom >> unit_result
        
        unit_result >> int_start
        int_start >> int_api >> int_db >> int_result
        
        int_result >> e2e_start
        e2e_start >> e2e_browser >> e2e_app >> e2e_result

        unit_result >> coverage
        int_result >> coverage
        e2e_result >> coverage
        coverage >> summary

def create_testing_pyramid():
    """Create testing pyramid visualization"""
    
    with Diagram("Testing Pyramid - Healthcare System", 
                 filename=f"{output_dir}/03_testing_pyramid",
                 show=False, direction="TB"):
        
        # E2E Tests (Top - Few, Slow, Expensive)
        with Cluster("🔺 E2E Tests - Few, Slow, Expensive"):
            e2e_login = Client("User Login\nJourney")
            e2e_search = Mobile("Doctor Search\nWorkflow")
            e2e_booking = Tablet("Appointment\nBooking Flow")
            e2e_note = Storage("❌ Failing\n(No App Running)")

        # Integration Tests (Middle - Some, Medium Speed)
        with Cluster("🔷 Integration Tests - Some, Medium Speed"):
            int_auth = Firewall("Authentication\nAPI Integration")
            int_db_conn = PostgreSQL("Database\nConnection Tests")
            int_api_endpoints = Nginx("API Endpoint\nIntegration")
            int_note = Storage("🔄 Ready to\nImplement")

        # Unit Tests (Bottom - Many, Fast, Cheap)
        with Cluster("🔹 Unit Tests - Many, Fast, Cheap"):
            unit_functions = JavaScript("Pure Function\nTests")
            unit_components = React("Component\nLogic Tests")
            unit_utilities = JavaScript("Utility Function\nTests")
            unit_note = Storage("✅ Passing\n(3/3 Success)")
            
        # Test Characteristics
        with Cluster("📊 Test Characteristics"):
            speed = Grafana("Speed:\nUnit(ms)\nIntegration(s)\nE2E(min)")
            cost = Storage("Cost:\nUnit(Low)\nIntegration(Med)\nE2E(High)")
            confidence = Rack("Confidence:\nUnit(Component)\nIntegration(System)\nE2E(User)")
        
        # Pyramid structure (visual flow)
        e2e_login >> int_auth >> unit_functions
        e2e_search >> int_db_conn >> unit_components
        e2e_booking >> int_api_endpoints >> unit_utilities

        # Characteristics connections
        unit_note >> speed
        int_note >> cost
        e2e_note >> confidence

def create_cicd_testing_pipeline():
    """Create CI/CD testing pipeline diagram"""
    
    with Diagram("CI/CD Testing Pipeline", 
                 filename=f"{output_dir}/04_cicd_testing_pipeline",
                 show=False, direction="LR"):
        
        # Developer Actions
        with Cluster("👨‍💻 Developer"):
            code_change = Storage("Code\nChanges")
            git_push = Storage("Git Push\nto GitHub")
            
        # GitHub Actions Pipeline
        with Cluster("🚀 GitHub Actions Pipeline"):
            trigger = Jenkins("Workflow\nTrigger")
            
            with Cluster("Stage 1: Setup"):
                checkout = Storage("Checkout\nCode")
                setup_node = JavaScript("Setup Node.js\n20.19.4")
                install_deps = Storage("Install\nDependencies")
                
            with Cluster("Stage 2: Testing"):
                run_unit = JavaScript("Run Unit\nTests")
                run_integration = JavaScript("Run Integration\nTests")
                run_e2e = Rack("Run E2E\nTests")
                
            with Cluster("Stage 3: Quality Gates"):
                coverage_check = Grafana("Coverage\nCheck (80%)")
                sonar_scan = Storage("SonarQube\nCode Quality")
                security_scan = Firewall("Trivy\nSecurity Scan")
                
            with Cluster("Stage 4: Deployment"):
                build_images = Storage("Build Docker\nImages")
                deploy_staging = EKS("Deploy to\nStaging")
                deploy_prod = EKS("Deploy to\nProduction")
        
        # Results and Notifications
        with Cluster("📊 Results"):
            test_report = Storage("Test\nReport")
            slack_notify = Mobile("Slack\nNotification")
            email_notify = Tablet("Email\nNotification")
        
        # Pipeline flow
        code_change >> git_push >> trigger
        trigger >> checkout >> setup_node >> install_deps
        
        install_deps >> run_unit >> run_integration >> run_e2e

        run_unit >> coverage_check
        run_integration >> coverage_check
        run_e2e >> coverage_check
        coverage_check >> sonar_scan >> security_scan

        security_scan >> build_images >> deploy_staging >> deploy_prod

        # Results flow
        coverage_check >> test_report
        sonar_scan >> test_report
        security_scan >> test_report
        test_report >> slack_notify
        test_report >> email_notify

if __name__ == "__main__":
    print("🎨 Creating Testing Process Visualizations...")
    print("📊 Generating diagrams using Python Diagrams library...")
    
    # Create all diagrams
    create_testing_architecture()
    print("✅ 1/4 - Testing Architecture diagram created")
    
    create_test_execution_flow()
    print("✅ 2/4 - Test Execution Flow diagram created")
    
    create_testing_pyramid()
    print("✅ 3/4 - Testing Pyramid diagram created")
    
    create_cicd_testing_pipeline()
    print("✅ 4/4 - CI/CD Testing Pipeline diagram created")
    
    print(f"\n🎉 All diagrams created successfully!")
    print(f"📁 Output directory: {output_dir}/")
    print(f"📋 Files generated:")
    print(f"   - 01_testing_architecture.png")
    print(f"   - 02_test_execution_flow.png") 
    print(f"   - 03_testing_pyramid.png")
    print(f"   - 04_cicd_testing_pipeline.png")
    print(f"\n💡 These diagrams visualize:")
    print(f"   🏗️  Overall testing architecture")
    print(f"   🔄 Step-by-step test execution")
    print(f"   🔺 Testing pyramid (Unit → Integration → E2E)")
    print(f"   🚀 Complete CI/CD pipeline with testing")
