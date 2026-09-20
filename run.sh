#!/bin/bash
# Build and launch ChemLab on this Mac.
#
#   ./run.sh                build (debug), then open the app
#   ./run.sh --clean        delete .build first (fixes stale-build errors)
#   ./run.sh --release      optimized build
#   ./run.sh --build-only   build, don't launch
#
# Logs go to .runlogs/. If the build fails, paste .runlogs/last-errors.txt.
#
# Works with only the Command Line Tools installed: it points Swift at the
# macOS 26 SDK, because the macOS 27 SDK's @State needs the SwiftUIMacros
# plugin, which the Command Line Tools don't include (see DESIGN.md).
# To use a different SDK, set SDKROOT yourself before running this.

set -o pipefail
cd "$(dirname "$0")" || exit 1

clean=0
config=debug
launch=1
for arg in "$@"; do
    case "$arg" in
        --clean) clean=1 ;;
        --release) config=release ;;
        --build-only) launch=0 ;;
        -h | --help) sed -n '2,13p' "$0"; exit 0 ;;
        *) echo "Unknown option: $arg (try --help)"; exit 2 ;;
    esac
done

if ! command -v swift >/dev/null 2>&1; then
    echo "swift not found. Install the Command Line Tools: xcode-select --install"
    exit 1
fi

# Pick the macOS 26 SDK when building with the Command Line Tools only.
if [ -z "$SDKROOT" ] && [ "$(xcode-select -p 2>/dev/null)" = "/Library/Developer/CommandLineTools" ]; then
    sdk_dir=/Library/Developer/CommandLineTools/SDKs
    if [ -d "$sdk_dir/MacOSX26.sdk" ]; then
        export SDKROOT="$sdk_dir/MacOSX26.sdk"
    else
        newest=$(ls -d "$sdk_dir"/MacOSX26.*.sdk 2>/dev/null | sort -V | tail -1)
        [ -n "$newest" ] && export SDKROOT="$newest"
    fi
    if [ -z "$SDKROOT" ]; then
        echo "Warning: no macOS 26 SDK found in $sdk_dir; the build will probably fail on @State."
    fi
fi
echo "SDKROOT: ${SDKROOT:-<default>}"

mkdir -p .runlogs
build_log=.runlogs/build.log
errors_file=.runlogs/last-errors.txt
warnings_file=.runlogs/last-warnings.txt

if [ "$clean" -eq 1 ]; then
    echo "Removing .build ..."
    rm -rf .build
fi

echo "Building ($config) ..."
swift build -c "$config" 2>&1 | tee "$build_log"
build_status=$?

grep -E "error:" "$build_log" | sort -u > "$errors_file"
grep -E "warning:" "$build_log" | sort -u > "$warnings_file"
error_count=$(wc -l < "$errors_file" | tr -d ' ')
warning_count=$(wc -l < "$warnings_file" | tr -d ' ')

if [ "$build_status" -ne 0 ]; then
    echo
    echo "BUILD FAILED: $error_count distinct error(s), $warning_count warning(s)."
    echo "  Errors:   $errors_file"
    echo "  Full log: $build_log"
    exit "$build_status"
fi

echo
echo "Build OK ($warning_count distinct warning(s); see $warnings_file)."

if [ "$launch" -eq 0 ]; then
    exit 0
fi

binary="$(swift build -c "$config" --show-bin-path)/ChemLab"
if [ ! -x "$binary" ]; then
    echo "Built, but couldn't find the executable at $binary"
    exit 1
fi

echo "Launching $binary (Ctrl-C or close the window to quit) ..."
"$binary" 2>&1 | tee .runlogs/app.log
