#!/usr/bin/env bash
# last_verified: 2026-10-14 · Jenkins shared library scaffold
# Test runner script for the Docker test harness

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

function log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

function log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

function run_tests_with_docker() {
    log_info "Building test harness image..."
    docker build -t jenkins-shared-lib-test:latest -f "$SCRIPT_DIR/Dockerfile" "$PROJECT_ROOT"

    log_info "Running tests..."
    docker run --rm jenkins-shared-lib-test:latest
}

function run_tests_with_compose() {
    log_info "Running tests with docker-compose..."
    docker-compose -f "$SCRIPT_DIR/docker-compose.yml" up --build --abort-on-container-exit test-harness
}

function run_tests_locally() {
    log_info "Running tests locally (requires groovy and JenkinsPipelineUnit)..."
    
    # Check if groovy is installed
    if ! command -v groovy &> /dev/null; then
        log_error "groovy not found. Please install groovy or use Docker."
        exit 1
    fi

    # Download JenkinsPipelineUnit if not present
    local unit_dir="$PROJECT_ROOT/.jenkins-pipeline-unit"
    if [[ ! -d "$unit_dir" ]]; then
        log_info "Downloading JenkinsPipelineUnit..."
        mkdir -p "$unit_dir"
        curl -L -o /tmp/JenkinsPipelineUnit.zip \
            "https://github.com/jenkinsci/JenkinsPipelineUnit/releases/download/2.8/JenkinsPipelineUnit-2.8.zip"
        unzip -q /tmp/JenkinsPipelineUnit.zip -d "$unit_dir"
        rm /tmp/JenkinsPipelineUnit.zip
    fi

    log_info "Running tests..."
    groovy -cp "$unit_dir/lib/*:$PROJECT_ROOT/src" "$PROJECT_ROOT/tests/runAllTests.groovy"
}

function show_help() {
    cat <<EOF
Usage: $0 [OPTION]

Run Jenkins shared library tests.

Options:
  -d, --docker      Run tests using Docker (default)
  -c, --compose     Run tests using docker-compose
  -l, --local       Run tests locally (requires groovy)
  -h, --help        Show this help message

Examples:
  $0                # Run with Docker
  $0 --compose      # Run with docker-compose
  $0 --local        # Run locally
EOF
}

# Parse arguments
MODE="docker"
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--docker)
            MODE="docker"
            shift
            ;;
        -c|--compose)
            MODE="compose"
            shift
            ;;
        -l|--local)
            MODE="local"
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run tests based on mode
case $MODE in
    docker)
        run_tests_with_docker
        ;;
    compose)
        run_tests_with_compose
        ;;
    local)
        run_tests_locally
        ;;
esac

log_info "Tests completed successfully!"