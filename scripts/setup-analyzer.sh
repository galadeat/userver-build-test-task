set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

TOOLS_DIR="$ROOT_DIR/tools"
SOURCE_DIR="$TOOLS_DIR/ClangBuildAnalyzer"
BUILD_DIR="$SOURCE_DIR/build"
ANALYZER="$BUILD_DIR/ClangBuildAnalyzer"

ANALYZER_COMMIT="55447756ff8af2f87e4a315f2ba637b9380363ea"
VERSION_FILE="$BUILD_DIR/.analyzer-commit"

if [[ -x "$ANALYZER" ]]; then
    echo "Clang Build Analyzer is already installed"
    exit 0
fi

if [[ ! -d "$SOURCE_DIR/.git" ]]; then
    mkdir -p "$TOOLS_DIR"
    git clone https://github.com/aras-p/ClangBuildAnalyzer.git "$SOURCE_DIR"
fi

git -C "$SOURCE_DIR" checkout --detach "$ANALYZER_COMMIT"

if [[ -x "$ANALYZER" && -f "$VERSION_FILE" ]] &&
   [[ "$(cat "$VERSION_FILE")" == "$ANALYZER_COMMIT" ]]; then
    echo "Clang Build Analyzer is already installed"
    exit 0
fi

cmake -S "$SOURCE_DIR" \
      -B "$BUILD_DIR" \
      -DCMAKE_BUILD_TYPE=Release

cmake --build "$BUILD_DIR" --parallel 2

echo "Clang Build Analyzer installed: $ANALYZER"