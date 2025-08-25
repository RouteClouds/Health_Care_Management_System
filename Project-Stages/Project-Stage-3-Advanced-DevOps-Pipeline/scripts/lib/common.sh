#!/usr/bin/env bash
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}ℹ️  $*${NC}"; }
log_warn()    { echo -e "${YELLOW}⚠️  $*${NC}"; }
log_error()   { echo -e "${RED}❌ $*${NC}"; }
log_success() { echo -e "${GREEN}✅ $*${NC}"; }

retry() {
  local -r max_attempts="$1"; shift
  local -r sleep_seconds="$1"; shift
  local attempt=1
  until "$@"; do
    if (( attempt >= max_attempts )); then
      log_error "Command failed after ${attempt} attempts: $*"
      return 1
    fi
    log_warn "Attempt ${attempt} failed. Retrying in ${sleep_seconds}s..."
    sleep "$sleep_seconds"
    ((attempt++))
  done
}

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || { log_error "Missing required command: $cmd"; return 1; }
}

ensure_dir() {
  mkdir -p "$1"
}

