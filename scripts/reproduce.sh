#!/usr/bin/env bash
set -euo pipefail

echo "Reproducing experiment..."

ORIG_SERVICE="origin"
EXP_SERVICE="experiment"

if ! [[ -d "$ORIG_SERVICE" ]]; then
    echo "$ORIG_SERVICE directory not found"
    exit 1
fi

if ! [[ -d "$EXP_SERVICE" ]]; then
    echo "$EXP_SERVICE directory not found"
    exit 1
fi

echo "Ready to build"

make image
make setup-analyzer

run_build() {
    local service="$1"
    local run="$2"
    local build_dir="$service/build-release"

    echo "Building $service, run $run"


    rm -rf -- "$build_dir"

    make configure SERVICE="$service"
    make build SERVICE="$service"
}

run_analyze() {
    local service="$1"
    local run="$2"
    local build_dir="$service/build-release"
    local output="results/$service/run-$run"

    echo "Analyzing $service, run $run"

    make analyze OUTPUT="$output" TRACE_BUILD_DIR="$build_dir"
}

for i in 1 2 3; do
    run_build "$ORIG_SERVICE" "$i"
    run_analyze "$ORIG_SERVICE" "$i"

    run_build "$EXP_SERVICE" "$i"
    run_analyze "$EXP_SERVICE" "$i"
done