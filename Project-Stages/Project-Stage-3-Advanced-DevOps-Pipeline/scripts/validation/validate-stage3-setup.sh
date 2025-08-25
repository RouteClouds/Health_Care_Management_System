#!/usr/bin/env bash
set -euo pipefail

# Stage-3 Setup Validation (consolidated)
# - Tools and credentials
# - Repo/workflow sanity
# - Stage-3 path-based triggers
# - Terraform env readiness
# - Kubernetes connectivity

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
STAGE3_DIR="$ROOT_DIR"
SRC_DIR="$STAGE3_DIR/src-code"
TF_ENV_DIR="$STAGE3_DIR/terraform/environments/dev"

source "$ROOT_DIR/scripts/lib/common.sh" || { echo "Missing common.sh"; exit 1; }

print_header() {
  echo -e "\n=============================="
  echo -e "🔍 Stage-3 Setup Validation"
  echo -e "==============================\n"
}

check_tools() {
  log_info "Checking required tools..."
  for c in aws kubectl helm terraform jq git; do
    require_cmd "$c"
  done
  log_success "All required tools present"
}

check_repo_layout() {
  log_info "Validating repository layout..."
  [[ -d "$SRC_DIR" ]] || { log_error "Missing src-code directory"; return 1; }
  [[ -d "$TF_ENV_DIR" ]] || { log_error "Missing Terraform env directory"; return 1; }
  log_success "Repository layout OK"
}

check_ci_triggers() {
  log_info "Validating CI trigger policy..."
  local wf="$(git ls-files .github/workflows | tr '\n' ' ')"
  if grep -R "Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/src-code/**" .github/workflows >/dev/null 2>&1; then
    log_success "Pipeline triggers on Stage-3 src-code changes"
  else
    log_warn "Could not confirm Stage-3 path-based trigger; verify workflow config"
  fi
}

check_terraform_env() {
  log_info "Checking Terraform environment..."
  pushd "$TF_ENV_DIR" >/dev/null
  terraform -version | head -1
  log_info "Running terraform init -backend=false (dry check)"
  terraform init -backend=false >/dev/null
  log_success "Terraform environment looks sane"
  popd >/dev/null
}

check_k8s_access() {
  log_info "Checking kubectl context..."
  if kubectl config current-context >/dev/null 2>&1; then
    log_success "kubectl configured"
  else
    log_warn "kubectl context not configured yet (expected before first cluster creation)"
  fi
}

main() {
  print_header
  check_tools
  check_repo_layout
  check_ci_triggers
  check_terraform_env
  check_k8s_access
  log_success "Stage-3 validation complete"
}

main "$@"

