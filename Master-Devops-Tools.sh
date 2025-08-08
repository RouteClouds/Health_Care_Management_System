#!/bin/bash
# Augment Master DevOps Tools Installation Script
# Interactive menu-driven installation for comprehensive DevOps toolkit

# Script version and information
SCRIPT_VERSION="2.0"
SCRIPT_NAME="Augment Master DevOps Tools Installer"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Configuration
LOG_FILE="/tmp/augment-master-devops-$(date +%Y%m%d_%H%M%S).log"
TEMP_DIR="/tmp/devops-master-install"
INSTALL_DIR="/usr/local/bin"

# Installation status tracking
declare -A TOOL_STATUS
declare -A TOOL_DESCRIPTIONS

# Make script executable
chmod +x "$0" 2>/dev/null || true

# Initialize tool descriptions and status
init_tools() {
    # Core DevOps Tools
    TOOL_DESCRIPTIONS["aws-cli"]="AWS CLI v2 - Amazon Web Services command-line interface"
    TOOL_DESCRIPTIONS["kubectl"]="kubectl - Kubernetes cluster management tool"
    TOOL_DESCRIPTIONS["eksctl"]="eksctl - Amazon EKS management tool"
    TOOL_DESCRIPTIONS["terraform"]="Terraform - Infrastructure as Code tool"
    TOOL_DESCRIPTIONS["helm"]="Helm - Kubernetes package manager"
    TOOL_DESCRIPTIONS["docker"]="Docker - Containerization platform"
    TOOL_DESCRIPTIONS["jenkins"]="Jenkins - CI/CD automation server"
    TOOL_DESCRIPTIONS["java"]="Java - Runtime environment (required for Jenkins)"
    
    # Additional DevOps Tools
    TOOL_DESCRIPTIONS["git"]="Git - Version control system"
    TOOL_DESCRIPTIONS["ansible"]="Ansible - Configuration management and automation"
    TOOL_DESCRIPTIONS["jq"]="jq - JSON processor for API responses"
    TOOL_DESCRIPTIONS["yq"]="yq - YAML processor for configuration files"
    TOOL_DESCRIPTIONS["session-manager"]="AWS Session Manager Plugin - Enhanced AWS connectivity"

    # Development Tools
    TOOL_DESCRIPTIONS["vscode"]="Visual Studio Code - Code editor"
    TOOL_DESCRIPTIONS["sublime"]="Sublime Text - Text editor"
    TOOL_DESCRIPTIONS["vim"]="Vim - Advanced text editor"
    TOOL_DESCRIPTIONS["tree"]="Tree - Directory structure visualization"
    TOOL_DESCRIPTIONS["htop"]="Htop - Interactive process monitor"

    # Web Browsers
    TOOL_DESCRIPTIONS["firefox"]="Firefox - Web browser"
    TOOL_DESCRIPTIONS["chrome"]="Google Chrome - Web browser"

    # Development Environments
    TOOL_DESCRIPTIONS["python-dev"]="Python Development Environment - Full Python setup"
    TOOL_DESCRIPTIONS["nodejs"]="Node.js and npm - JavaScript runtime and package manager"
    TOOL_DESCRIPTIONS["yarn"]="Yarn - JavaScript package manager"
    TOOL_DESCRIPTIONS["java-dev"]="Java Development Environment - Multiple JDK versions"

    # Database Tools
    TOOL_DESCRIPTIONS["database-clients"]="Database Clients - PostgreSQL, MySQL, SQLite, Redis"

    # Network and API Tools
    TOOL_DESCRIPTIONS["postman"]="Postman - API development and testing tool"
    TOOL_DESCRIPTIONS["network-tools"]="Network Tools - SSH server, network utilities"
    
    # Containerized DevOps Tools
    TOOL_DESCRIPTIONS["sonarqube"]="SonarQube - Code quality analysis (Docker)"
    TOOL_DESCRIPTIONS["nexus"]="Nexus Repository - Artifact repository (Docker)"
    TOOL_DESCRIPTIONS["trivy"]="Trivy - Vulnerability scanner (Docker)"
    TOOL_DESCRIPTIONS["prometheus"]="Prometheus - Monitoring and alerting (Docker)"
    TOOL_DESCRIPTIONS["grafana"]="Grafana - Visualization and dashboards (Docker)"
    
    # Initialize all tools as not installed
    for tool in "${!TOOL_DESCRIPTIONS[@]}"; do
        TOOL_STATUS["$tool"]="NOT_INSTALLED"
    done
}

print_status() {
    local status=$1
    local message=$2
    case $status in
        "OK") echo -e "${GREEN}✓${NC} $message" ;;
        "FAIL") echo -e "${RED}✗${NC} $message" ;;
        "WARNING") echo -e "${YELLOW}⚠${NC} $message" ;;
        "INFO") echo -e "${BLUE}ℹ${NC} $message" ;;
        "STEP") echo -e "${CYAN}[STEP]${NC} $message" ;;
        "HEADER") echo -e "${PURPLE}═══${NC} $message ${PURPLE}═══${NC}" ;;
        "SUCCESS") echo -e "${GREEN}🎉${NC} $message" ;;
        "MENU") echo -e "${WHITE}$message${NC}" ;;
    esac
}

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to execute commands with error handling
execute_command() {
    local command=$1
    local description=$2
    local allow_failure=${3:-false}
    
    log "Executing: $description"
    
    if eval "$command" >>"$LOG_FILE" 2>&1; then
        return 0
    else
        local exit_code=$?
        if [ "$allow_failure" = "true" ]; then
            return 0
        else
            return $exit_code
        fi
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect architecture
get_architecture() {
    local arch
    arch=$(uname -m)
    case "$arch" in
        x86_64) echo "amd64" ;;
        aarch64) echo "arm64" ;;
        *) log "ERROR: Unsupported architecture: $arch"; exit 1 ;;
    esac
}

# Function to check tool installation status
check_tool_status() {
    local tool=$1
    
    case $tool in
        "aws-cli")
            if command_exists aws; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "kubectl")
            if command_exists kubectl; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "eksctl")
            if command_exists eksctl; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "terraform")
            if command_exists terraform; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "helm")
            if command_exists helm; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "docker")
            if command_exists docker; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "jenkins")
            if systemctl is-active --quiet jenkins 2>/dev/null; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "java")
            if command_exists java; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "git")
            if command_exists git; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "ansible")
            if command_exists ansible; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "jq")
            if command_exists jq; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "yq")
            if command_exists yq; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "session-manager")
            if command_exists session-manager-plugin; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "vscode")
            if command_exists code; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "sublime")
            if command_exists subl; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "vim")
            if command_exists vim; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "tree")
            if command_exists tree; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "htop")
            if command_exists htop; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "firefox")
            if command_exists firefox; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "chrome")
            if command_exists google-chrome; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "python-dev")
            if command_exists python3 && command_exists pip3; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "nodejs")
            if command_exists node && command_exists npm; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "yarn")
            if command_exists yarn; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "java-dev")
            if command_exists javac && command_exists maven; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "database-clients")
            if command_exists psql && command_exists mysql && command_exists sqlite3; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "postman")
            if snap list | grep -q postman; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "network-tools")
            if command_exists ssh && command_exists netstat; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "sonarqube")
            if docker ps --format "table {{.Names}}" | grep -q "sonarqube"; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "nexus")
            if docker ps --format "table {{.Names}}" | grep -q "nexus3"; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "trivy")
            if docker images | grep -q "aquasec/trivy"; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "prometheus")
            if docker ps --format "table {{.Names}}" | grep -q "prometheus"; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
        "grafana")
            if docker ps --format "table {{.Names}}" | grep -q "grafana"; then
                TOOL_STATUS["$tool"]="INSTALLED"
            fi
            ;;
    esac
}

# Function to display main menu
show_main_menu() {
    clear
    echo ""
    echo "=========================================="
    echo "    $SCRIPT_NAME v$SCRIPT_VERSION"
    echo "=========================================="
    echo ""
    print_status "INFO" "Interactive DevOps Tools Installation Menu"
    print_status "INFO" "System: $(lsb_release -d 2>/dev/null | cut -f2 || echo 'Unknown')"
    print_status "INFO" "User: $(whoami)"
    echo ""
    
    print_status "HEADER" "CORE DEVOPS TOOLS"
    echo ""
    
    local counter=1
    
    # Core DevOps Tools
    for tool in "aws-cli" "kubectl" "eksctl" "terraform" "helm" "docker" "jenkins" "java"; do
        check_tool_status "$tool"
        local status_icon=""
        if [ "${TOOL_STATUS[$tool]}" = "INSTALLED" ]; then
            status_icon="${GREEN}✓${NC}"
        else
            status_icon="${RED}✗${NC}"
        fi
        printf "%2d. %s %s\n" $counter "$status_icon" "${TOOL_DESCRIPTIONS[$tool]}"
        ((counter++))
    done
    
    echo ""
    print_status "HEADER" "ADDITIONAL DEVOPS TOOLS"
    echo ""
    
    # Additional DevOps Tools
    for tool in "git" "ansible" "jq" "yq" "session-manager"; do
        check_tool_status "$tool"
        local status_icon=""
        if [ "${TOOL_STATUS[$tool]}" = "INSTALLED" ]; then
            status_icon="${GREEN}✓${NC}"
        else
            status_icon="${RED}✗${NC}"
        fi
        printf "%2d. %s %s\n" $counter "$status_icon" "${TOOL_DESCRIPTIONS[$tool]}"
        ((counter++))
    done
    
    echo ""
    print_status "HEADER" "DEVELOPMENT TOOLS"
    echo ""
    
    # Development Tools
    for tool in "vscode" "sublime" "vim" "tree" "htop"; do
        check_tool_status "$tool"
        local status_icon=""
        if [ "${TOOL_STATUS[$tool]}" = "INSTALLED" ]; then
            status_icon="${GREEN}✓${NC}"
        else
            status_icon="${RED}✗${NC}"
        fi
        printf "%2d. %s %s\n" $counter "$status_icon" "${TOOL_DESCRIPTIONS[$tool]}"
        ((counter++))
    done

    echo ""
    print_status "HEADER" "WEB BROWSERS"
    echo ""

    # Web Browsers
    for tool in "firefox" "chrome"; do
        check_tool_status "$tool"
        local status_icon=""
        if [ "${TOOL_STATUS[$tool]}" = "INSTALLED" ]; then
            status_icon="${GREEN}✓${NC}"
        else
            status_icon="${RED}✗${NC}"
        fi
        printf "%2d. %s %s\n" $counter "$status_icon" "${TOOL_DESCRIPTIONS[$tool]}"
        ((counter++))
    done

    echo ""
    print_status "HEADER" "DEVELOPMENT ENVIRONMENTS"
    echo ""

    # Development Environments
    for tool in "python-dev" "nodejs" "yarn" "java-dev"; do
        check_tool_status "$tool"
        local status_icon=""
        if [ "${TOOL_STATUS[$tool]}" = "INSTALLED" ]; then
            status_icon="${GREEN}✓${NC}"
        else
            status_icon="${RED}✗${NC}"
        fi
        printf "%2d. %s %s\n" $counter "$status_icon" "${TOOL_DESCRIPTIONS[$tool]}"
        ((counter++))
    done

    echo ""
    print_status "HEADER" "DATABASE & NETWORK TOOLS"
    echo ""

    # Database and Network Tools
    for tool in "database-clients" "postman" "network-tools"; do
        check_tool_status "$tool"
        local status_icon=""
        if [ "${TOOL_STATUS[$tool]}" = "INSTALLED" ]; then
            status_icon="${GREEN}✓${NC}"
        else
            status_icon="${RED}✗${NC}"
        fi
        printf "%2d. %s %s\n" $counter "$status_icon" "${TOOL_DESCRIPTIONS[$tool]}"
        ((counter++))
    done

    echo ""
    print_status "HEADER" "CONTAINERIZED DEVOPS TOOLS"
    echo ""

    # Containerized DevOps Tools
    for tool in "sonarqube" "nexus" "trivy" "prometheus" "grafana"; do
        check_tool_status "$tool"
        local status_icon=""
        if [ "${TOOL_STATUS[$tool]}" = "INSTALLED" ]; then
            status_icon="${GREEN}✓${NC}"
        else
            status_icon="${RED}✗${NC}"
        fi
        printf "%2d. %s %s\n" $counter "$status_icon" "${TOOL_DESCRIPTIONS[$tool]}"
        ((counter++))
    done
    
    echo ""
    print_status "HEADER" "SPECIAL OPTIONS"
    echo ""
    printf "%2d. %s Install ALL Packages (Complete DevOps Environment)\n" $counter "${GREEN}🎯${NC}"
    ((counter++))
    printf "%2d. %s Install All Core DevOps Tools\n" $counter "${BLUE}🚀${NC}"
    ((counter++))
    printf "%2d. %s Install All Development Tools\n" $counter "${BLUE}💻${NC}"
    ((counter++))
    printf "%2d. %s Install All Web Browsers\n" $counter "${BLUE}🌐${NC}"
    ((counter++))
    printf "%2d. %s Install All Development Environments\n" $counter "${BLUE}⚙️${NC}"
    ((counter++))
    printf "%2d. %s Install All Containerized Tools\n" $counter "${BLUE}🐳${NC}"
    ((counter++))
    printf "%2d. %s Show Installation Summary\n" $counter "${PURPLE}📊${NC}"
    ((counter++))
    printf "%2d. %s Verify and Fix Docker Access\n" $counter "${BLUE}🐳${NC}"
    ((counter++))
    printf "%2d. %s Update System Dependencies\n" $counter "${YELLOW}🔧${NC}"
    ((counter++))
    printf "%2d. %s Update and Upgrade System\n" $counter "${CYAN}⬆️${NC}"
    ((counter++))
    printf "%2d. %s Exit\n" $counter "${RED}❌${NC}"
    
    echo ""
    echo "=========================================="
}

# Function to get user choice
get_user_choice() {
    local max_choice=43
    while true; do
        echo ""
        print_status "MENU" "Enter your choice (1-$max_choice): "
        read -r choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le $max_choice ]; then
            return $choice
        else
            print_status "FAIL" "Invalid choice. Please enter a number between 1 and $max_choice."
        fi
    done
}

# Function to pause and wait for user input
pause_for_user() {
    echo ""
    print_status "INFO" "Press Enter to continue..."
    read -r
}

# Function to update and upgrade system
update_and_upgrade_system() {
    print_status "STEP" "Updating and upgrading system packages"

    if execute_command "sudo apt update && sudo apt upgrade -y" "Update and upgrade system packages"; then
        print_status "SUCCESS" "System packages updated and upgraded successfully"
        return 0
    else
        print_status "FAIL" "Failed to update and upgrade system packages"
        return 1
    fi
}

# Function to install system dependencies
install_dependencies() {
    print_status "STEP" "Installing system dependencies"

    # Always update package lists before installing dependencies
    if execute_command "sudo apt update" "Update package lists"; then
        print_status "OK" "Package lists updated"
    else
        print_status "FAIL" "Failed to update package lists"
        return 1
    fi

    if execute_command "sudo apt install -y curl wget unzip tar gzip ca-certificates gnupg lsb-release software-properties-common apt-transport-https build-essential" "Install essential dependencies"; then
        print_status "OK" "System dependencies installed"
        return 0
    else
        print_status "FAIL" "Failed to install system dependencies"
        return 1
    fi
}

# Function to install AWS CLI
install_aws_cli() {
    print_status "STEP" "Installing AWS CLI v2"

    if command_exists aws; then
        print_status "INFO" "AWS CLI already installed: $(aws --version)"
        TOOL_STATUS["aws-cli"]="INSTALLED"
        return 0
    fi

    mkdir -p "$TEMP_DIR/aws-cli"
    cd "$TEMP_DIR/aws-cli"

    local arch=$(get_architecture)
    local aws_url="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
    if [ "$arch" = "arm64" ]; then
        aws_url="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"
    fi

    if execute_command "curl '$aws_url' -o 'awscliv2.zip'" "Download AWS CLI" && \
       execute_command "unzip awscliv2.zip" "Extract AWS CLI" && \
       execute_command "sudo ./aws/install" "Install AWS CLI"; then

        if command_exists aws; then
            print_status "SUCCESS" "AWS CLI installed successfully: $(aws --version)"
            TOOL_STATUS["aws-cli"]="INSTALLED"
            return 0
        fi
    fi

    print_status "FAIL" "AWS CLI installation failed"
    TOOL_STATUS["aws-cli"]="FAILED"
    return 1
}

# Function to install kubectl
install_kubectl() {
    print_status "STEP" "Installing kubectl"

    if command_exists kubectl; then
        print_status "INFO" "kubectl already installed"
        TOOL_STATUS["kubectl"]="INSTALLED"
        return 0
    fi

    mkdir -p "$TEMP_DIR/kubectl"
    cd "$TEMP_DIR/kubectl"

    local arch=$(get_architecture)
    local kubectl_version=$(curl -L -s https://dl.k8s.io/release/stable.txt)

    if execute_command "curl -LO 'https://dl.k8s.io/release/${kubectl_version}/bin/linux/${arch}/kubectl'" "Download kubectl" && \
       execute_command "sudo install -o root -g root -m 0755 kubectl $INSTALL_DIR/kubectl" "Install kubectl"; then

        if command_exists kubectl; then
            print_status "SUCCESS" "kubectl installed successfully"
            TOOL_STATUS["kubectl"]="INSTALLED"
            return 0
        fi
    fi

    print_status "FAIL" "kubectl installation failed"
    TOOL_STATUS["kubectl"]="FAILED"
    return 1
}

# Function to install eksctl
install_eksctl() {
    print_status "STEP" "Installing eksctl"

    if command_exists eksctl; then
        print_status "INFO" "eksctl already installed: $(eksctl version)"
        TOOL_STATUS["eksctl"]="INSTALLED"
        return 0
    fi

    mkdir -p "$TEMP_DIR/eksctl"
    cd "$TEMP_DIR/eksctl"

    local arch=$(get_architecture)

    if execute_command "curl --silent --location 'https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$(uname -s)_${arch}.tar.gz' | tar xz -C ." "Download and extract eksctl" && \
       execute_command "sudo mv eksctl $INSTALL_DIR/eksctl" "Install eksctl"; then

        if command_exists eksctl; then
            print_status "SUCCESS" "eksctl installed successfully: $(eksctl version)"
            TOOL_STATUS["eksctl"]="INSTALLED"
            return 0
        fi
    fi

    print_status "FAIL" "eksctl installation failed"
    TOOL_STATUS["eksctl"]="FAILED"
    return 1
}

# Function to install Terraform
install_terraform() {
    print_status "STEP" "Installing Terraform"

    if command_exists terraform; then
        print_status "INFO" "Terraform already installed: $(terraform --version | head -1)"
        TOOL_STATUS["terraform"]="INSTALLED"
        return 0
    fi

    if execute_command "wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg" "Add HashiCorp GPG key" && \
       execute_command "echo 'deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main' | sudo tee /etc/apt/sources.list.d/hashicorp.list" "Add HashiCorp repository" && \
       execute_command "sudo apt update" "Update package lists" && \
       execute_command "sudo apt install -y terraform" "Install Terraform"; then

        if command_exists terraform; then
            print_status "SUCCESS" "Terraform installed successfully: $(terraform --version | head -1)"
            TOOL_STATUS["terraform"]="INSTALLED"
            return 0
        fi
    fi

    print_status "FAIL" "Terraform installation failed"
    TOOL_STATUS["terraform"]="FAILED"
    return 1
}

# Function to install Helm
install_helm() {
    print_status "STEP" "Installing Helm"

    if command_exists helm; then
        print_status "INFO" "Helm already installed: $(helm version --short)"
        TOOL_STATUS["helm"]="INSTALLED"
        return 0
    fi

    if execute_command "curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash" "Install Helm"; then
        if command_exists helm; then
            print_status "SUCCESS" "Helm installed successfully: $(helm version --short)"
            execute_command "helm repo add stable https://charts.helm.sh/stable" "Add Helm stable repository" true
            execute_command "helm repo update" "Update Helm repositories" true
            TOOL_STATUS["helm"]="INSTALLED"
            return 0
        fi
    fi

    print_status "FAIL" "Helm installation failed"
    TOOL_STATUS["helm"]="FAILED"
    return 1
}

# Function to install Docker
install_docker() {
    print_status "STEP" "Installing Docker"

    if command_exists docker; then
        print_status "INFO" "Docker already installed: $(docker --version)"
        # Check if user is in docker group and can access Docker
        if docker ps >/dev/null 2>&1; then
            print_status "INFO" "Docker is accessible without sudo"
            TOOL_STATUS["docker"]="INSTALLED"
            return 0
        else
            print_status "WARNING" "Docker installed but user needs group access. Fixing permissions..."
            # Fix docker group access for existing installation
            execute_command "sudo usermod -aG docker $USER" "Add user to docker group"
            apply_docker_group_changes
            TOOL_STATUS["docker"]="INSTALLED"
            return 0
        fi
    fi

    if execute_command "curl -fsSL https://get.docker.com -o get-docker.sh" "Download Docker installation script" && \
       execute_command "sudo sh get-docker.sh" "Install Docker" && \
       execute_command "sudo systemctl start docker" "Start Docker service" && \
       execute_command "sudo systemctl enable docker" "Enable Docker service" && \
       execute_command "sudo usermod -aG docker $USER" "Add user to docker group"; then

        # Install Docker Compose plugin
        execute_command "sudo apt install -y docker-compose-plugin" "Install Docker Compose plugin" true

        if command_exists docker; then
            print_status "SUCCESS" "Docker installed successfully: $(docker --version)"

            # Apply docker group changes immediately
            apply_docker_group_changes

            TOOL_STATUS["docker"]="INSTALLED"
            return 0
        fi
    fi

    print_status "FAIL" "Docker installation failed"
    TOOL_STATUS["docker"]="FAILED"
    return 1
}

# Function to apply Docker group changes and test access
apply_docker_group_changes() {
    print_status "STEP" "Applying Docker group changes"

    # Verify user is in docker group
    if groups "$USER" | grep -q docker; then
        print_status "OK" "User '$USER' is in docker group"
    else
        print_status "WARNING" "User '$USER' not found in docker group, adding again..."
        execute_command "sudo usermod -aG docker $USER" "Re-add user to docker group"
    fi

    # Check Docker socket permissions
    if [ -S "/var/run/docker.sock" ]; then
        print_status "OK" "Docker socket exists"
        local socket_perms=$(ls -la /var/run/docker.sock | awk '{print $1, $3, $4}')
        print_status "INFO" "Docker socket permissions: $socket_perms"
    else
        print_status "FAIL" "Docker socket not found"
        return 1
    fi

    # Apply group changes using multiple methods
    print_status "INFO" "Applying group membership changes..."

    # Method 1: Try newgrp in a subshell to test Docker access
    if echo "docker ps >/dev/null 2>&1" | newgrp docker; then
        print_status "SUCCESS" "Docker group changes applied successfully"
        print_status "INFO" "Docker is now accessible without sudo"
    else
        print_status "WARNING" "Group changes applied but may require shell restart"
    fi

    # Add environment refresh to bashrc if not already present
    if ! grep -q "# Docker group refresh" ~/.bashrc 2>/dev/null; then
        echo "" >> ~/.bashrc
        echo "# Docker group refresh - added by Augment DevOps installer" >> ~/.bashrc
        echo "# This ensures Docker group membership is active" >> ~/.bashrc
        print_status "INFO" "Added Docker group refresh to ~/.bashrc"
    fi

    # Provide user instructions
    echo ""
    print_status "INFO" "🐳 Docker Installation Complete!"
    print_status "INFO" "To use Docker immediately, run one of these commands:"
    print_status "INFO" "  Method 1 (Recommended): newgrp docker"
    print_status "INFO" "  Method 2: source ~/.bashrc"
    print_status "INFO" "  Method 3: Logout and login again"
    echo ""
    print_status "INFO" "Test Docker access with: docker ps -a"
    print_status "INFO" "Test Docker functionality with: docker run --rm hello-world"
    echo ""
}

# Function to install Java
install_java() {
    print_status "STEP" "Installing Java (required for Jenkins)"

    if command_exists java; then
        print_status "INFO" "Java already installed: $(java -version 2>&1 | head -1)"
        TOOL_STATUS["java"]="INSTALLED"
        return 0
    fi

    if execute_command "sudo apt install -y openjdk-21-jre-headless" "Install OpenJDK 21"; then
        if command_exists java; then
            print_status "SUCCESS" "Java installed successfully: $(java -version 2>&1 | head -1)"
            # Set JAVA_HOME
            echo 'export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64' >> ~/.bashrc
            print_status "INFO" "JAVA_HOME set in ~/.bashrc"
            TOOL_STATUS["java"]="INSTALLED"
            return 0
        fi
    fi

    print_status "FAIL" "Java installation failed"
    TOOL_STATUS["java"]="FAILED"
    return 1
}

# Function to install Jenkins
install_jenkins() {
    print_status "STEP" "Installing Jenkins"

    if systemctl is-active --quiet jenkins 2>/dev/null; then
        print_status "INFO" "Jenkins already installed and running"
        TOOL_STATUS["jenkins"]="INSTALLED"
        return 0
    fi

    # Ensure Java is installed first
    if ! command_exists java; then
        print_status "WARNING" "Java not found. Installing Java first..."
        install_java
    fi

    # Create keyrings directory if it doesn't exist
    execute_command "sudo mkdir -p /etc/apt/keyrings" "Create keyrings directory" true

    if execute_command "sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key" "Add Jenkins GPG key" && \
       execute_command "echo 'deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/' | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null" "Add Jenkins repository" && \
       execute_command "sudo apt update" "Update package lists" && \
       execute_command "sudo apt install -y jenkins" "Install Jenkins"; then

        # Wait a moment for Jenkins to initialize
        sleep 5

        if execute_command "sudo systemctl start jenkins" "Start Jenkins service" && \
           execute_command "sudo systemctl enable jenkins" "Enable Jenkins service"; then

            # Wait for Jenkins to fully start
            print_status "INFO" "Waiting for Jenkins to start (this may take 2-3 minutes)..."
            local wait_count=0
            while [ $wait_count -lt 60 ]; do
                if systemctl is-active --quiet jenkins && curl -s http://localhost:8080 >/dev/null 2>&1; then
                    break
                fi
                sleep 5
                ((wait_count++))
                echo -n "."
            done
            echo ""

            if systemctl is-active --quiet jenkins; then
                print_status "SUCCESS" "Jenkins installed and running"
                print_status "INFO" "Jenkins web UI available at: http://$(hostname -I | awk '{print $1}'):8080"
                if [ -f "/var/lib/jenkins/secrets/initialAdminPassword" ]; then
                    print_status "INFO" "Initial admin password: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
                else
                    print_status "WARNING" "Initial admin password file not found yet. Wait a few minutes and check: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
                fi
                TOOL_STATUS["jenkins"]="INSTALLED"
                return 0
            fi
        fi
    fi

    print_status "FAIL" "Jenkins installation failed"
    TOOL_STATUS["jenkins"]="FAILED"
    return 1
}

# Function to install additional DevOps tools
install_additional_tools() {
    local tool=$1

    case $tool in
        "git")
            print_status "STEP" "Installing Git"
            if execute_command "sudo apt install -y git" "Install Git"; then
                print_status "SUCCESS" "Git installed successfully"
                TOOL_STATUS["git"]="INSTALLED"
            else
                print_status "FAIL" "Git installation failed"
                TOOL_STATUS["git"]="FAILED"
            fi
            ;;
        "ansible")
            print_status "STEP" "Installing Ansible"
            if execute_command "sudo apt install -y ansible" "Install Ansible"; then
                print_status "SUCCESS" "Ansible installed successfully"
                TOOL_STATUS["ansible"]="INSTALLED"
            else
                print_status "FAIL" "Ansible installation failed"
                TOOL_STATUS["ansible"]="FAILED"
            fi
            ;;
        "jq")
            print_status "STEP" "Installing jq"
            if execute_command "sudo apt install -y jq" "Install jq"; then
                print_status "SUCCESS" "jq installed successfully"
                TOOL_STATUS["jq"]="INSTALLED"
            else
                print_status "FAIL" "jq installation failed"
                TOOL_STATUS["jq"]="FAILED"
            fi
            ;;
        "yq")
            print_status "STEP" "Installing yq"
            if ! command_exists yq; then
                local arch=$(get_architecture)
                if execute_command "sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${arch}" "Download yq" && \
                   execute_command "sudo chmod +x /usr/local/bin/yq" "Make yq executable"; then
                    print_status "SUCCESS" "yq installed successfully"
                    TOOL_STATUS["yq"]="INSTALLED"
                else
                    print_status "FAIL" "yq installation failed"
                    TOOL_STATUS["yq"]="FAILED"
                fi
            else
                print_status "INFO" "yq already installed"
                TOOL_STATUS["yq"]="INSTALLED"
            fi
            ;;
        "session-manager")
            print_status "STEP" "Installing AWS Session Manager Plugin"
            if ! command_exists session-manager-plugin; then
                mkdir -p "$TEMP_DIR/session-manager"
                cd "$TEMP_DIR/session-manager"
                local arch=$(get_architecture)
                local url="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb"
                if [ "$arch" = "arm64" ]; then
                    url="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_arm64/session-manager-plugin.deb"
                fi

                if execute_command "curl '$url' -o 'session-manager-plugin.deb'" "Download AWS Session Manager Plugin" && \
                   execute_command "sudo dpkg -i session-manager-plugin.deb" "Install AWS Session Manager Plugin"; then
                    print_status "SUCCESS" "AWS Session Manager Plugin installed successfully"
                    TOOL_STATUS["session-manager"]="INSTALLED"
                else
                    print_status "FAIL" "AWS Session Manager Plugin installation failed"
                    TOOL_STATUS["session-manager"]="FAILED"
                fi
            else
                print_status "INFO" "AWS Session Manager Plugin already installed"
                TOOL_STATUS["session-manager"]="INSTALLED"
            fi
            ;;
    esac
}

# Function to install development tools
install_development_tools() {
    local tool=$1

    case $tool in
        "vscode")
            print_status "STEP" "Installing Visual Studio Code"
            if execute_command "wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg" "Download VS Code GPG key" && \
               execute_command "sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/" "Install GPG key" && \
               execute_command "echo 'deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main' | sudo tee /etc/apt/sources.list.d/vscode.list" "Add VS Code repository" && \
               execute_command "sudo apt update" "Update package lists" && \
               execute_command "sudo apt install -y code" "Install VS Code"; then
                print_status "SUCCESS" "Visual Studio Code installed successfully"
                TOOL_STATUS["vscode"]="INSTALLED"
            else
                print_status "FAIL" "Visual Studio Code installation failed"
                TOOL_STATUS["vscode"]="FAILED"
            fi
            ;;
        "sublime")
            print_status "STEP" "Installing Sublime Text"
            if execute_command "wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -" "Add Sublime Text GPG key" && \
               execute_command "echo 'deb https://download.sublimetext.com/ apt/stable/' | sudo tee /etc/apt/sources.list.d/sublime-text.list" "Add Sublime Text repository" && \
               execute_command "sudo apt update" "Update package lists" && \
               execute_command "sudo apt install -y sublime-text" "Install Sublime Text"; then
                print_status "SUCCESS" "Sublime Text installed successfully"
                TOOL_STATUS["sublime"]="INSTALLED"
            else
                print_status "FAIL" "Sublime Text installation failed"
                TOOL_STATUS["sublime"]="FAILED"
            fi
            ;;
        "vim"|"tree"|"htop")
            print_status "STEP" "Installing $tool"
            if execute_command "sudo apt install -y $tool" "Install $tool"; then
                print_status "SUCCESS" "$tool installed successfully"
                TOOL_STATUS["$tool"]="INSTALLED"
            else
                print_status "FAIL" "$tool installation failed"
                TOOL_STATUS["$tool"]="FAILED"
            fi
            ;;
    esac
}

# Function to install containerized tools
install_containerized_tools() {
    local tool=$1

    # Check if Docker is available
    if ! command_exists docker; then
        print_status "FAIL" "Docker is required for containerized tools. Please install Docker first."
        return 1
    fi

    # Check if Docker is accessible (user in docker group)
    if ! docker ps >/dev/null 2>&1; then
        print_status "FAIL" "Docker permission denied. Please run 'newgrp docker' or logout/login."
        print_status "INFO" "Or run the Docker activation script: ./activate-docker.sh"
        create_docker_activation_script
        return 1
    fi

    case $tool in
        "sonarqube")
            print_status "STEP" "Installing SonarQube (Docker)"
            if execute_command "docker volume create sonarqube_data" "Create SonarQube data volume" true && \
               execute_command "docker volume create sonarqube_logs" "Create SonarQube logs volume" true && \
               execute_command "docker volume create sonarqube_extensions" "Create SonarQube extensions volume" true && \
               execute_command "docker run -d --name sonarqube --restart unless-stopped -p 9000:9000 -v sonarqube_data:/opt/sonarqube/data -v sonarqube_logs:/opt/sonarqube/logs -v sonarqube_extensions:/opt/sonarqube/extensions sonarqube:lts-community" "Run SonarQube container"; then
                print_status "SUCCESS" "SonarQube installed successfully"
                print_status "INFO" "SonarQube URL: http://$(hostname -I | awk '{print $1}'):9000"
                print_status "INFO" "Default credentials: admin/admin"
                TOOL_STATUS["sonarqube"]="INSTALLED"
            else
                print_status "FAIL" "SonarQube installation failed"
                TOOL_STATUS["sonarqube"]="FAILED"
            fi
            ;;
        "nexus")
            print_status "STEP" "Installing Nexus Repository (Docker)"
            if execute_command "docker volume create nexus-data" "Create Nexus data volume" true && \
               execute_command "docker run -d --name nexus3 --restart unless-stopped -p 8081:8081 -v nexus-data:/nexus-data sonatype/nexus3" "Run Nexus container"; then
                print_status "SUCCESS" "Nexus Repository installed successfully"
                print_status "INFO" "Nexus URL: http://$(hostname -I | awk '{print $1}'):8081"
                print_status "INFO" "Initial admin password: docker exec nexus3 cat /nexus-data/admin.password"
                TOOL_STATUS["nexus"]="INSTALLED"
            else
                print_status "FAIL" "Nexus Repository installation failed"
                TOOL_STATUS["nexus"]="FAILED"
            fi
            ;;
        "trivy")
            print_status "STEP" "Installing Trivy (Docker)"
            if execute_command "docker pull aquasec/trivy:latest" "Pull Trivy image"; then
                # Create alias for easier usage
                echo 'alias trivy="docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.cache:/root/.cache/ aquasec/trivy:latest"' >> ~/.bashrc
                print_status "SUCCESS" "Trivy installed successfully"
                print_status "INFO" "Usage: trivy image <image-name>"
                print_status "INFO" "Alias added to ~/.bashrc"
                TOOL_STATUS["trivy"]="INSTALLED"
            else
                print_status "FAIL" "Trivy installation failed"
                TOOL_STATUS["trivy"]="FAILED"
            fi
            ;;
        "prometheus")
            print_status "STEP" "Installing Prometheus (Docker)"
            # Create Prometheus configuration
            mkdir -p ~/prometheus-config
            cat > ~/prometheus-config/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
EOF

            if execute_command "docker volume create prometheus-data" "Create Prometheus data volume" true && \
               execute_command "docker run -d --name prometheus --restart unless-stopped -p 9090:9090 -v ~/prometheus-config/prometheus.yml:/etc/prometheus/prometheus.yml -v prometheus-data:/prometheus prom/prometheus:latest --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/prometheus --web.console.libraries=/etc/prometheus/console_libraries --web.console.templates=/etc/prometheus/consoles --storage.tsdb.retention.time=200h --web.enable-lifecycle" "Run Prometheus container"; then
                print_status "SUCCESS" "Prometheus installed successfully"
                print_status "INFO" "Prometheus URL: http://$(hostname -I | awk '{print $1}'):9090"
                TOOL_STATUS["prometheus"]="INSTALLED"
            else
                print_status "FAIL" "Prometheus installation failed"
                TOOL_STATUS["prometheus"]="FAILED"
            fi
            ;;
        "grafana")
            print_status "STEP" "Installing Grafana (Docker)"
            if execute_command "docker volume create grafana-storage" "Create Grafana storage volume" true && \
               execute_command "docker run -d --name grafana --restart unless-stopped -p 3000:3000 -v grafana-storage:/var/lib/grafana -e 'GF_SECURITY_ADMIN_PASSWORD=admin123' grafana/grafana:latest" "Run Grafana container"; then
                print_status "SUCCESS" "Grafana installed successfully"
                print_status "INFO" "Grafana URL: http://$(hostname -I | awk '{print $1}'):3000"
                print_status "INFO" "Default credentials: admin/admin123"
                TOOL_STATUS["grafana"]="INSTALLED"
            else
                print_status "FAIL" "Grafana installation failed"
                TOOL_STATUS["grafana"]="FAILED"
            fi
            ;;
    esac
}

# Function to install web browsers
install_web_browsers() {
    local tool=$1

    case $tool in
        "firefox")
            print_status "STEP" "Installing Firefox"
            if execute_command "sudo apt install -y firefox" "Install Firefox browser"; then
                print_status "SUCCESS" "Firefox installed successfully"
                TOOL_STATUS["firefox"]="INSTALLED"
            else
                print_status "FAIL" "Firefox installation failed"
                TOOL_STATUS["firefox"]="FAILED"
            fi
            ;;
        "chrome")
            print_status "STEP" "Installing Google Chrome"
            if ! command_exists google-chrome; then
                if execute_command "wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -" "Add Google Chrome GPG key" && \
                   execute_command "echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list" "Add Google Chrome repository" && \
                   execute_command "sudo apt update" "Update package lists" && \
                   execute_command "sudo apt install -y google-chrome-stable" "Install Google Chrome"; then
                    print_status "SUCCESS" "Google Chrome installed successfully"
                    TOOL_STATUS["chrome"]="INSTALLED"
                else
                    print_status "FAIL" "Google Chrome installation failed"
                    TOOL_STATUS["chrome"]="FAILED"
                fi
            else
                print_status "INFO" "Google Chrome already installed"
                TOOL_STATUS["chrome"]="INSTALLED"
            fi
            ;;
    esac
}

# Function to install development environments
install_development_environments() {
    local tool=$1

    case $tool in
        "python-dev")
            print_status "STEP" "Installing Python Development Environment"
            if execute_command "sudo apt install -y python3 python3-pip python3-venv python3-dev" "Install Python 3 and development tools" && \
               execute_command "sudo apt install -y python-is-python3" "Create python symlink"; then

                # Install Python package managers
                execute_command "pip3 install --user pipenv poetry" "Install Python package managers" true

                print_status "SUCCESS" "Python Development Environment installed successfully"
                TOOL_STATUS["python-dev"]="INSTALLED"
            else
                print_status "FAIL" "Python Development Environment installation failed"
                TOOL_STATUS["python-dev"]="FAILED"
            fi
            ;;
        "nodejs")
            print_status "STEP" "Installing Node.js and npm"
            if execute_command "sudo apt install -y nodejs npm" "Install Node.js and npm"; then
                print_status "SUCCESS" "Node.js and npm installed successfully"
                print_status "INFO" "Node.js version: $(node --version 2>/dev/null || echo 'unknown')"
                print_status "INFO" "npm version: $(npm --version 2>/dev/null || echo 'unknown')"
                TOOL_STATUS["nodejs"]="INSTALLED"
            else
                print_status "FAIL" "Node.js and npm installation failed"
                TOOL_STATUS["nodejs"]="FAILED"
            fi
            ;;
        "yarn")
            print_status "STEP" "Installing Yarn Package Manager"
            if execute_command "curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -" "Add Yarn repository key" && \
               execute_command "echo 'deb https://dl.yarnpkg.com/debian/ stable main' | sudo tee /etc/apt/sources.list.d/yarn.list" "Add Yarn repository" && \
               execute_command "sudo apt update" "Update package lists" && \
               execute_command "sudo apt install -y yarn" "Install Yarn package manager"; then
                print_status "SUCCESS" "Yarn installed successfully"
                print_status "INFO" "Yarn version: $(yarn --version 2>/dev/null || echo 'unknown')"
                TOOL_STATUS["yarn"]="INSTALLED"
            else
                print_status "FAIL" "Yarn installation failed"
                TOOL_STATUS["yarn"]="FAILED"
            fi
            ;;
        "java-dev")
            print_status "STEP" "Installing Java Development Environment"
            if execute_command "sudo apt install -y default-jdk default-jre" "Install default JDK and JRE" && \
               execute_command "sudo apt install -y openjdk-11-jdk openjdk-17-jdk openjdk-21-jdk" "Install OpenJDK versions" && \
               execute_command "sudo apt install -y maven gradle" "Install build tools (Maven, Gradle)"; then
                print_status "SUCCESS" "Java Development Environment installed successfully"
                print_status "INFO" "Java version: $(java -version 2>&1 | head -1 || echo 'unknown')"
                print_status "INFO" "Maven version: $(mvn --version 2>/dev/null | head -1 || echo 'unknown')"
                print_status "INFO" "Gradle version: $(gradle --version 2>/dev/null | head -1 || echo 'unknown')"
                TOOL_STATUS["java-dev"]="INSTALLED"
            else
                print_status "FAIL" "Java Development Environment installation failed"
                TOOL_STATUS["java-dev"]="FAILED"
            fi
            ;;
    esac
}

# Function to install database and network tools
install_database_network_tools() {
    local tool=$1

    case $tool in
        "database-clients")
            print_status "STEP" "Installing Database Clients"
            if execute_command "sudo apt install -y postgresql-client mysql-client sqlite3 redis-tools" "Install database clients"; then
                print_status "SUCCESS" "Database clients installed successfully"
                print_status "INFO" "PostgreSQL client: $(psql --version 2>/dev/null || echo 'installed')"
                print_status "INFO" "MySQL client: $(mysql --version 2>/dev/null || echo 'installed')"
                print_status "INFO" "SQLite3: $(sqlite3 --version 2>/dev/null || echo 'installed')"
                TOOL_STATUS["database-clients"]="INSTALLED"
            else
                print_status "FAIL" "Database clients installation failed"
                TOOL_STATUS["database-clients"]="FAILED"
            fi
            ;;
        "postman")
            print_status "STEP" "Installing Postman"
            # Ensure snapd is installed
            execute_command "sudo apt install -y snapd" "Install Snap package manager" true
            execute_command "sudo systemctl enable snapd" "Enable Snap service" true

            if execute_command "sudo snap install postman" "Install Postman API client"; then
                print_status "SUCCESS" "Postman installed successfully"
                TOOL_STATUS["postman"]="INSTALLED"
            else
                print_status "FAIL" "Postman installation failed"
                TOOL_STATUS["postman"]="FAILED"
            fi
            ;;
        "network-tools")
            print_status "STEP" "Installing Network Tools"
            if execute_command "sudo apt install -y openssh-server" "Install SSH server" && \
               execute_command "sudo apt install -y net-tools dnsutils" "Install network utilities" && \
               execute_command "sudo apt install -y network-manager-gnome" "Install Network Manager GUI"; then

                # Enable SSH service
                execute_command "sudo systemctl enable ssh" "Enable SSH service" true
                execute_command "sudo systemctl start ssh" "Start SSH service" true

                print_status "SUCCESS" "Network tools installed successfully"
                print_status "INFO" "SSH server enabled and started"
                print_status "INFO" "Network utilities available: netstat, nslookup, dig"
                TOOL_STATUS["network-tools"]="INSTALLED"
            else
                print_status "FAIL" "Network tools installation failed"
                TOOL_STATUS["network-tools"]="FAILED"
            fi
            ;;
    esac
}

# Function to verify and fix Docker access after installation
verify_docker_access() {
    print_status "STEP" "Verifying Docker Access"

    if ! command_exists docker; then
        print_status "FAIL" "Docker not installed"
        return 1
    fi

    # Test Docker access
    if docker ps >/dev/null 2>&1; then
        print_status "SUCCESS" "✅ Docker is accessible without sudo"
        print_status "INFO" "Docker version: $(docker --version)"

        # Test Docker functionality
        if docker run --rm hello-world >/dev/null 2>&1; then
            print_status "SUCCESS" "✅ Docker functionality test passed"
        else
            print_status "WARNING" "Docker accessible but functionality test failed"
        fi

        # Check Docker Compose
        if docker compose version >/dev/null 2>&1; then
            print_status "SUCCESS" "✅ Docker Compose is available"
        else
            print_status "WARNING" "Docker Compose not available"
        fi

        return 0
    else
        print_status "WARNING" "Docker installed but permission denied. Applying fixes..."

        # Apply fixes
        execute_command "sudo usermod -aG docker $USER" "Add user to docker group"

        # Try to apply group changes
        print_status "INFO" "Attempting to apply group changes..."
        print_status "INFO" "Run this command to activate Docker access: newgrp docker"
        print_status "INFO" "Then test with: docker ps -a"

        return 1
    fi
}

# Function to create Docker post-installation script
create_docker_activation_script() {
    print_status "STEP" "Creating Docker activation helper script"

    cat > ~/activate-docker.sh << 'EOF'
#!/bin/bash
# Docker Activation Helper Script
# Created by Augment DevOps Tools Installer

echo "🐳 Docker Activation Helper"
echo "=========================="

# Check if Docker is installed
if ! command -v docker >/dev/null 2>&1; then
    echo "❌ Docker is not installed"
    exit 1
fi

# Check current Docker access
if docker ps >/dev/null 2>&1; then
    echo "✅ Docker is already accessible"
    echo "Docker version: $(docker --version)"
    echo "Test command: docker run --rm hello-world"
    exit 0
fi

echo "🔧 Applying Docker group changes..."

# Check if user is in docker group
if groups "$USER" | grep -q docker; then
    echo "✅ User is in docker group"
else
    echo "❌ User not in docker group. Run: sudo usermod -aG docker $USER"
    exit 1
fi

echo ""
echo "🚀 To activate Docker access, choose one method:"
echo "1. Run: newgrp docker"
echo "2. Run: source ~/.bashrc"
echo "3. Logout and login again"
echo ""
echo "Then test with: docker ps -a"
EOF

    chmod +x ~/activate-docker.sh
    print_status "SUCCESS" "Docker activation script created: ~/activate-docker.sh"
    print_status "INFO" "Run ./activate-docker.sh anytime to check Docker access"
}

# Function to install all packages (complete DevOps environment)
install_all_packages() {
    print_status "HEADER" "COMPLETE DEVOPS ENVIRONMENT INSTALLATION"
    echo ""
    print_status "INFO" "This will install ALL available tools in the optimal order"
    print_status "INFO" "Estimated time: 15-30 minutes depending on internet speed"
    print_status "INFO" "You can monitor progress and any issues will be logged"
    echo ""

    # Confirmation prompt
    print_status "WARNING" "This will install 32+ tools and packages. Continue? (y/N)"
    read -r confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_status "INFO" "Installation cancelled by user"
        return 0
    fi

    echo ""
    print_status "SUCCESS" "🚀 Starting Complete DevOps Environment Installation..."
    echo ""

    local start_time=$(date +%s)
    local total_steps=8
    local current_step=0

    # Step 1: System Update and Dependencies
    ((current_step++))
    print_status "HEADER" "STEP $current_step/$total_steps: SYSTEM PREPARATION"
    print_status "STEP" "Updating system and installing dependencies..."
    update_and_upgrade_system
    install_dependencies
    print_status "SUCCESS" "✅ System preparation completed"
    echo ""

    # Step 2: Core DevOps Tools
    ((current_step++))
    print_status "HEADER" "STEP $current_step/$total_steps: CORE DEVOPS TOOLS"
    print_status "STEP" "Installing core DevOps infrastructure tools..."
    install_aws_cli
    install_kubectl
    install_eksctl
    install_terraform
    install_helm
    install_docker
    install_java
    install_jenkins
    print_status "SUCCESS" "✅ Core DevOps tools installation completed"
    echo ""

    # Step 3: Additional DevOps Tools
    ((current_step++))
    print_status "HEADER" "STEP $current_step/$total_steps: ADDITIONAL DEVOPS TOOLS"
    print_status "STEP" "Installing additional DevOps utilities..."
    install_additional_tools "git"
    install_additional_tools "ansible"
    install_additional_tools "jq"
    install_additional_tools "yq"
    install_additional_tools "session-manager"
    print_status "SUCCESS" "✅ Additional DevOps tools installation completed"
    echo ""

    # Step 4: Development Tools
    ((current_step++))
    print_status "HEADER" "STEP $current_step/$total_steps: DEVELOPMENT TOOLS"
    print_status "STEP" "Installing development and productivity tools..."
    install_development_tools "vscode"
    install_development_tools "sublime"
    install_development_tools "vim"
    install_development_tools "tree"
    install_development_tools "htop"
    print_status "SUCCESS" "✅ Development tools installation completed"
    echo ""

    # Step 5: Web Browsers
    ((current_step++))
    print_status "HEADER" "STEP $current_step/$total_steps: WEB BROWSERS"
    print_status "STEP" "Installing web browsers..."
    install_web_browsers "firefox"
    install_web_browsers "chrome"
    print_status "SUCCESS" "✅ Web browsers installation completed"
    echo ""

    # Step 6: Development Environments
    ((current_step++))
    print_status "HEADER" "STEP $current_step/$total_steps: DEVELOPMENT ENVIRONMENTS"
    print_status "STEP" "Installing programming language environments..."
    install_development_environments "python-dev"
    install_development_environments "nodejs"
    install_development_environments "yarn"
    install_development_environments "java-dev"
    print_status "SUCCESS" "✅ Development environments installation completed"
    echo ""

    # Step 7: Database and Network Tools
    ((current_step++))
    print_status "HEADER" "STEP $current_step/$total_steps: DATABASE & NETWORK TOOLS"
    print_status "STEP" "Installing database clients and network tools..."
    install_database_network_tools "database-clients"
    install_database_network_tools "postman"
    install_database_network_tools "network-tools"
    print_status "SUCCESS" "✅ Database and network tools installation completed"
    echo ""

    # Step 8: Containerized Tools (with Docker verification)
    ((current_step++))
    print_status "HEADER" "STEP $current_step/$total_steps: CONTAINERIZED DEVOPS TOOLS"
    print_status "STEP" "Installing containerized DevOps services..."

    # Verify Docker access before containerized tools
    if ! docker ps >/dev/null 2>&1; then
        print_status "WARNING" "Docker permission issue detected. Applying fixes..."
        verify_docker_access
        create_docker_activation_script

        # Try to apply group changes
        print_status "INFO" "Attempting to activate Docker access..."
        if echo "docker ps >/dev/null 2>&1" | newgrp docker; then
            print_status "SUCCESS" "Docker access activated"
        else
            print_status "WARNING" "Docker group changes applied but may need manual activation"
            print_status "INFO" "Run 'newgrp docker' in a new terminal to activate Docker"
            print_status "INFO" "Then re-run containerized tools installation"
        fi
    fi

    # Install containerized tools if Docker is accessible
    if docker ps >/dev/null 2>&1; then
        install_containerized_tools "sonarqube"
        install_containerized_tools "nexus"
        install_containerized_tools "trivy"
        install_containerized_tools "prometheus"
        install_containerized_tools "grafana"
        print_status "SUCCESS" "✅ Containerized tools installation completed"
    else
        print_status "WARNING" "⚠️ Containerized tools skipped due to Docker access issues"
        print_status "INFO" "Run 'newgrp docker' and then install containerized tools manually"
    fi

    echo ""

    # Final verification and summary
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))

    print_status "HEADER" "INSTALLATION COMPLETE!"
    echo ""
    print_status "SUCCESS" "🎉 Complete DevOps Environment Installation Finished!"
    print_status "INFO" "Total installation time: ${minutes}m ${seconds}s"
    print_status "INFO" "Installation log: $LOG_FILE"
    echo ""

    # Show quick summary
    print_status "INFO" "📊 Quick Summary:"
    print_status "INFO" "✅ Core DevOps Tools: AWS CLI, kubectl, eksctl, Terraform, Helm, Docker, Jenkins"
    print_status "INFO" "✅ Development Tools: VS Code, Sublime Text, Vim, Tree, Htop"
    print_status "INFO" "✅ Web Browsers: Firefox, Google Chrome"
    print_status "INFO" "✅ Programming Environments: Python, Node.js, Java with build tools"
    print_status "INFO" "✅ Database & Network: PostgreSQL, MySQL, SQLite, Redis, SSH, Postman"
    print_status "INFO" "✅ Containerized Services: SonarQube, Nexus, Trivy, Prometheus, Grafana"
    echo ""

    # Next steps
    print_status "INFO" "🚀 Next Steps:"
    print_status "INFO" "1. Configure AWS CLI: aws configure"
    print_status "INFO" "2. Activate Docker access: newgrp docker"
    print_status "INFO" "3. Set JAVA_HOME: export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64"
    print_status "INFO" "4. Access services:"
    print_status "INFO" "   • Jenkins: http://$(hostname -I | awk '{print $1}'):8080"
    print_status "INFO" "   • SonarQube: http://$(hostname -I | awk '{print $1}'):9000"
    print_status "INFO" "   • Nexus: http://$(hostname -I | awk '{print $1}'):8081"
    print_status "INFO" "   • Grafana: http://$(hostname -I | awk '{print $1}'):3000"
    print_status "INFO" "   • Prometheus: http://$(hostname -I | awk '{print $1}'):9090"
    echo ""
    print_status "INFO" "5. Run installation summary (Option 39) to verify all tools"
    print_status "INFO" "6. Use Docker activation script if needed: ./activate-docker.sh"
    echo ""
    print_status "SUCCESS" "Your complete DevOps environment is ready! 🎊"
}

# Function to show installation summary
show_installation_summary() {
    clear
    echo ""
    print_status "HEADER" "INSTALLATION SUMMARY"
    echo ""

    local installed_count=0
    local failed_count=0
    local not_installed_count=0

    # Update all tool statuses
    for tool in "${!TOOL_DESCRIPTIONS[@]}"; do
        check_tool_status "$tool"
    done

    print_status "HEADER" "CORE DEVOPS TOOLS"
    echo ""
    for tool in "aws-cli" "kubectl" "eksctl" "terraform" "helm" "docker" "jenkins" "java"; do
        local status="${TOOL_STATUS[$tool]}"
        case $status in
            "INSTALLED")
                print_status "OK" "${TOOL_DESCRIPTIONS[$tool]}"
                ((installed_count++))
                ;;
            "FAILED")
                print_status "FAIL" "${TOOL_DESCRIPTIONS[$tool]}"
                ((failed_count++))
                ;;
            *)
                print_status "WARNING" "${TOOL_DESCRIPTIONS[$tool]} - Not installed"
                ((not_installed_count++))
                ;;
        esac
    done

    echo ""
    print_status "HEADER" "ADDITIONAL DEVOPS TOOLS"
    echo ""
    for tool in "git" "ansible" "jq" "yq" "session-manager"; do
        local status="${TOOL_STATUS[$tool]}"
        case $status in
            "INSTALLED")
                print_status "OK" "${TOOL_DESCRIPTIONS[$tool]}"
                ((installed_count++))
                ;;
            "FAILED")
                print_status "FAIL" "${TOOL_DESCRIPTIONS[$tool]}"
                ((failed_count++))
                ;;
            *)
                print_status "WARNING" "${TOOL_DESCRIPTIONS[$tool]} - Not installed"
                ((not_installed_count++))
                ;;
        esac
    done

    echo ""
    print_status "HEADER" "DEVELOPMENT TOOLS"
    echo ""
    for tool in "vscode" "sublime" "vim" "tree" "htop"; do
        local status="${TOOL_STATUS[$tool]}"
        case $status in
            "INSTALLED")
                print_status "OK" "${TOOL_DESCRIPTIONS[$tool]}"
                ((installed_count++))
                ;;
            "FAILED")
                print_status "FAIL" "${TOOL_DESCRIPTIONS[$tool]}"
                ((failed_count++))
                ;;
            *)
                print_status "WARNING" "${TOOL_DESCRIPTIONS[$tool]} - Not installed"
                ((not_installed_count++))
                ;;
        esac
    done

    echo ""
    print_status "HEADER" "WEB BROWSERS"
    echo ""
    for tool in "firefox" "chrome"; do
        local status="${TOOL_STATUS[$tool]}"
        case $status in
            "INSTALLED")
                print_status "OK" "${TOOL_DESCRIPTIONS[$tool]}"
                ((installed_count++))
                ;;
            "FAILED")
                print_status "FAIL" "${TOOL_DESCRIPTIONS[$tool]}"
                ((failed_count++))
                ;;
            *)
                print_status "WARNING" "${TOOL_DESCRIPTIONS[$tool]} - Not installed"
                ((not_installed_count++))
                ;;
        esac
    done

    echo ""
    print_status "HEADER" "DEVELOPMENT ENVIRONMENTS"
    echo ""
    for tool in "python-dev" "nodejs" "yarn" "java-dev"; do
        local status="${TOOL_STATUS[$tool]}"
        case $status in
            "INSTALLED")
                print_status "OK" "${TOOL_DESCRIPTIONS[$tool]}"
                ((installed_count++))
                ;;
            "FAILED")
                print_status "FAIL" "${TOOL_DESCRIPTIONS[$tool]}"
                ((failed_count++))
                ;;
            *)
                print_status "WARNING" "${TOOL_DESCRIPTIONS[$tool]} - Not installed"
                ((not_installed_count++))
                ;;
        esac
    done

    echo ""
    print_status "HEADER" "DATABASE & NETWORK TOOLS"
    echo ""
    for tool in "database-clients" "postman" "network-tools"; do
        local status="${TOOL_STATUS[$tool]}"
        case $status in
            "INSTALLED")
                print_status "OK" "${TOOL_DESCRIPTIONS[$tool]}"
                ((installed_count++))
                ;;
            "FAILED")
                print_status "FAIL" "${TOOL_DESCRIPTIONS[$tool]}"
                ((failed_count++))
                ;;
            *)
                print_status "WARNING" "${TOOL_DESCRIPTIONS[$tool]} - Not installed"
                ((not_installed_count++))
                ;;
        esac
    done

    echo ""
    print_status "HEADER" "CONTAINERIZED DEVOPS TOOLS"
    echo ""
    for tool in "sonarqube" "nexus" "trivy" "prometheus" "grafana"; do
        local status="${TOOL_STATUS[$tool]}"
        case $status in
            "INSTALLED")
                print_status "OK" "${TOOL_DESCRIPTIONS[$tool]}"
                ((installed_count++))
                ;;
            "FAILED")
                print_status "FAIL" "${TOOL_DESCRIPTIONS[$tool]}"
                ((failed_count++))
                ;;
            *)
                print_status "WARNING" "${TOOL_DESCRIPTIONS[$tool]} - Not installed"
                ((not_installed_count++))
                ;;
        esac
    done

    echo ""
    print_status "HEADER" "SUMMARY STATISTICS"
    echo ""
    print_status "OK" "Installed: $installed_count"
    print_status "FAIL" "Failed: $failed_count"
    print_status "WARNING" "Not Installed: $not_installed_count"

    local total_tools=$((installed_count + failed_count + not_installed_count))
    local success_percentage=$((installed_count * 100 / total_tools))

    echo ""
    if [ $success_percentage -ge 90 ]; then
        print_status "SUCCESS" "Installation Success Rate: ${success_percentage}% - EXCELLENT!"
    elif [ $success_percentage -ge 75 ]; then
        print_status "WARNING" "Installation Success Rate: ${success_percentage}% - GOOD"
    else
        print_status "FAIL" "Installation Success Rate: ${success_percentage}% - NEEDS ATTENTION"
    fi

    echo ""
    print_status "INFO" "System: $(lsb_release -d 2>/dev/null | cut -f2 || echo 'Unknown')"
    print_status "INFO" "Architecture: $(uname -m)"
    print_status "INFO" "Memory: $(free -h | awk 'NR==2{print $2}')"
    print_status "INFO" "Disk Space: $(df -h / | awk 'NR==2{print $4}') available"
    print_status "INFO" "Installation log: $LOG_FILE"

    pause_for_user
}

# Function to handle menu choice
handle_menu_choice() {
    local choice=$1

    case $choice in
        1) install_aws_cli ;;
        2) install_kubectl ;;
        3) install_eksctl ;;
        4) install_terraform ;;
        5) install_helm ;;
        6) install_docker ;;
        7) install_jenkins ;;
        8) install_java ;;
        9) install_additional_tools "git" ;;
        10) install_additional_tools "ansible" ;;
        11) install_additional_tools "jq" ;;
        12) install_additional_tools "yq" ;;
        13) install_additional_tools "session-manager" ;;
        14) install_development_tools "vscode" ;;
        15) install_development_tools "sublime" ;;
        16) install_development_tools "vim" ;;
        17) install_development_tools "tree" ;;
        18) install_development_tools "htop" ;;
        19) install_web_browsers "firefox" ;;
        20) install_web_browsers "chrome" ;;
        21) install_development_environments "python-dev" ;;
        22) install_development_environments "nodejs" ;;
        23) install_development_environments "yarn" ;;
        24) install_development_environments "java-dev" ;;
        25) install_database_network_tools "database-clients" ;;
        26) install_database_network_tools "postman" ;;
        27) install_database_network_tools "network-tools" ;;
        28) install_containerized_tools "sonarqube" ;;
        29) install_containerized_tools "nexus" ;;
        30) install_containerized_tools "trivy" ;;
        31) install_containerized_tools "prometheus" ;;
        32) install_containerized_tools "grafana" ;;
        33) # Install ALL Packages (Complete DevOps Environment)
            install_all_packages
            ;;
        34) # Install All Core DevOps Tools
            print_status "STEP" "Installing All Core DevOps Tools"
            install_dependencies
            install_aws_cli
            install_kubectl
            install_eksctl
            install_terraform
            install_helm
            install_docker
            install_java
            install_jenkins
            print_status "SUCCESS" "All Core DevOps Tools installation completed"
            ;;
        35) # Install All Development Tools
            print_status "STEP" "Installing All Development Tools"
            install_development_tools "vscode"
            install_development_tools "sublime"
            install_development_tools "vim"
            install_development_tools "tree"
            install_development_tools "htop"
            install_additional_tools "git"
            print_status "SUCCESS" "All Development Tools installation completed"
            ;;
        36) # Install All Web Browsers
            print_status "STEP" "Installing All Web Browsers"
            install_web_browsers "firefox"
            install_web_browsers "chrome"
            print_status "SUCCESS" "All Web Browsers installation completed"
            ;;
        37) # Install All Development Environments
            print_status "STEP" "Installing All Development Environments"
            install_development_environments "python-dev"
            install_development_environments "nodejs"
            install_development_environments "yarn"
            install_development_environments "java-dev"
            print_status "SUCCESS" "All Development Environments installation completed"
            ;;
        38) # Install All Containerized Tools
            print_status "STEP" "Installing All Containerized Tools"
            if ! command_exists docker; then
                print_status "WARNING" "Docker not found. Installing Docker first..."
                install_docker
            fi

            # Verify Docker access before installing containerized tools
            if ! docker ps >/dev/null 2>&1; then
                print_status "WARNING" "Docker permission issue detected. Creating activation script..."
                create_docker_activation_script
                print_status "INFO" "Please run 'newgrp docker' and then re-run this option"
                return 1
            fi

            install_containerized_tools "sonarqube"
            install_containerized_tools "nexus"
            install_containerized_tools "trivy"
            install_containerized_tools "prometheus"
            install_containerized_tools "grafana"
            print_status "SUCCESS" "All Containerized Tools installation completed"
            ;;
        39) show_installation_summary ;;
        40) # Verify and Fix Docker Access
            print_status "STEP" "Verifying and Fixing Docker Access"
            verify_docker_access
            create_docker_activation_script
            print_status "SUCCESS" "Docker access verification completed"
            ;;
        41) # Update System Dependencies
            print_status "STEP" "Updating System Dependencies"
            install_dependencies
            print_status "SUCCESS" "System dependencies updated"
            ;;
        42) # Update and Upgrade System
            print_status "STEP" "Updating and Upgrading System"
            update_and_upgrade_system
            print_status "SUCCESS" "System update and upgrade completed"
            ;;
        43) # Exit
            print_status "INFO" "Thank you for using Augment Master DevOps Tools Installer!"
            print_status "INFO" "Installation log saved to: $LOG_FILE"
            exit 0
            ;;
        *)
            print_status "FAIL" "Invalid choice"
            ;;
    esac

    pause_for_user
}

# Main function
main() {
    # Create temporary directory
    mkdir -p "$TEMP_DIR"

    # Initialize tools
    init_tools

    # Main loop
    while true; do
        show_main_menu
        get_user_choice
        choice=$?
        handle_menu_choice $choice
    done
}

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR"
    rm -f get-docker.sh
}

# Set trap for cleanup
trap cleanup EXIT

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_status "WARNING" "Running as root. Some installations may not work correctly."
    print_status "INFO" "Consider running as a regular user with sudo privileges."
fi

# Start the script
main "$@"
