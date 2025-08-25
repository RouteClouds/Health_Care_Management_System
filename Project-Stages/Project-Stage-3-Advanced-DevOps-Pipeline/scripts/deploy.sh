#!/usr/bin/env bash
set -euo pipefail

# Unified Stage-3 deploy helper
# Subcommands: build | push | deploy | verify

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
source "$ROOT_DIR/scripts/lib/common.sh"

usage() {
  cat <<EOF
Usage: $(basename "$0") <subcommand> [options]

Subcommands:
  build   Build Docker images for frontend/backend
  push    Push images to ECR (requires login)
  deploy  Deploy to Kubernetes via Helm or GitOps
  verify  Run post-deployment checks

Examples:
  $0 build
  $0 push
  $0 deploy --namespace healthcare-stage3-dev
  $0 verify
EOF
}

sub_build() {
  log_info "Building Stage-3 images (wrapper)"
  bash "$SCRIPT_DIR/deployment/build-and-push-images.sh" --no-push || {
    log_error "Build failed"; exit 1; }
  log_success "Build completed"
}

sub_push() {
  log_info "Pushing Stage-3 images (wrapper)"
  bash "$SCRIPT_DIR/deployment/build-and-push-images.sh" || {
    log_error "Push failed"; exit 1; }
  log_success "Push completed"
}

sub_deploy() {
  # Prefer GitOps/Helm already provided by project scripts.
  log_info "Deploying Helm release via existing script"
  if [[ -f "$SCRIPT_DIR/deploy-healthcare.sh" ]]; then
    bash "$SCRIPT_DIR/deploy-healthcare.sh"
  elif [[ -f "$SCRIPT_DIR/deployment/deploy-healthcare.sh" ]]; then
    bash "$SCRIPT_DIR/deployment/deploy-healthcare.sh"
  else
    log_error "No deploy-healthcare.sh found"
    exit 1
  fi
}

sub_verify() {
  log_info "Running connectivity tests"
  if [[ -f "$ROOT_DIR/scripts/test-frontend-backend-connectivity.sh" ]]; then
    bash "$ROOT_DIR/scripts/test-frontend-backend-connectivity.sh"
  else
    log_warn "Connectivity test script not found"
  fi
  log_success "Verification step completed"
}

main() {
  local cmd="${1:-}"; shift || true
  case "$cmd" in
    build) sub_build "$@" ;;
    push) sub_push "$@" ;;
    deploy) sub_deploy "$@" ;;
    verify) sub_verify "$@" ;;
    *) usage; exit 1 ;;
  esac
}

main "$@"

