#!/bin/bash

echo "===== System Check for GPU & Development Tools ====="

# Function to check if a command exists and is executable
check_command() {
    type -P "$1" &>/dev/null
}

# Check for NVIDIA GPU
echo -n "Checking for NVIDIA GPU... "
if lspci | grep -i nvidia &>/dev/null; then
    echo "✅ Found"
else
    echo "❌ No NVIDIA GPU detected"
    exit 1
fi

# Check for NVIDIA drivers
echo -n "Checking for NVIDIA drivers... "
if check_command nvidia-smi; then
    echo "✅ Installed"
    nvidia-smi
else
    echo "❌ NVIDIA drivers NOT installed or not in PATH"
    exit 1
fi

# Check for CUDA installation
echo -n "Checking for CUDA... "
if check_command nvcc; then
    CUDA_VERSION=$(nvcc --version | grep -oP "release \K[0-9]+(\.[0-9]+)*" || true)
    
    # Fallback if `grep -oP` isn't available
    if [[ -z "$CUDA_VERSION" ]]; then
        CUDA_VERSION=$(nvcc --version | sed -n 's/.*release \([0-9]\+\(\.[0-9]\+\)*\).*/\1/p')
    fi

    CUDA_MAJOR=$(echo "$CUDA_VERSION" | cut -d. -f1)

    if [[ -n "$CUDA_MAJOR" && "$CUDA_MAJOR" -ge 11 ]]; then
        echo "✅ Installed (Version: $CUDA_VERSION)"
    else
        echo "❌ CUDA version is too old ($CUDA_VERSION). Require ≥ 11.0"
        exit 1
    fi
else
    echo "❌ CUDA is NOT installed"
    exit 1
fi

# Check Compute Capability
echo -n "Checking GPU Compute Capability (≥ 3.5)... "
if check_command nvidia-smi; then
    CC=$(nvidia-smi --query-gpu=compute_cap --format=csv,noheader | awk -F. '{ print $1$2 }' | head -n1)
    
    if [[ -n "$CC" && "$CC" -ge 35 ]]; then
        echo "✅ Compute Capability: $CC"
    else
        echo "❌ Compute Capability ($CC) is too low. Require ≥ 3.5"
        exit 1
    fi
else
    echo "❌ Unable to query Compute Capability"
    exit 1
fi

# Check CMake version
echo -n "Checking for CMake (≥ 3.18)... "
if check_command cmake; then
    CMAKE_VERSION=$(cmake --version | head -n1 | grep -oP "[0-9]+\.[0-9]+\.[0-9]+" || true)
    CMAKE_MAJOR=$(echo "$CMAKE_VERSION" | cut -d. -f1)
    CMAKE_MINOR=$(echo "$CMAKE_VERSION" | cut -d. -f2)

    if [[ -n "$CMAKE_MAJOR" && "$CMAKE_MAJOR" -gt 3 || ( "$CMAKE_MAJOR" -eq 3 && "$CMAKE_MINOR" -ge 18 ) ]]; then
        echo "✅ Installed (Version: $CMAKE_VERSION)"
    else
        echo "❌ CMake version ($CMAKE_VERSION) is too old. Require ≥ 3.18"
        exit 1
    fi
else
    echo "❌ CMake is NOT installed"
    exit 1
fi

# Check for GCC and make
echo -n "Checking for GCC (≥ 8.1)... "
if check_command gcc; then
    GCC_VERSION=$(gcc -dumpversion)
    GCC_MAJOR=$(echo "$GCC_VERSION" | cut -d. -f1)
    GCC_MINOR=$(echo "$GCC_VERSION" | cut -d. -f2)

    if [[ -n "$GCC_MAJOR" && ( "$GCC_MAJOR" -gt 8 || ( "$GCC_MAJOR" -eq 8 && "$GCC_MINOR" -ge 1 ) ) ]]; then
        echo "✅ Installed (Version: $GCC_VERSION)"
    else
        echo "❌ GCC version ($GCC_VERSION) is too old. Require ≥ 8.1"
        exit 1
    fi
else
    echo "❌ GCC is NOT installed"
    exit 1
fi

echo -n "Checking for make... "
if check_command make; then
    echo "✅ Installed"
else
    echo "❌ make is NOT installed"
    exit 1
fi

# Check for Python installation
echo -n "Checking for Python... "
if check_command python3 || check_command python; then
    PYTHON_CMD=$(type -P python3 || type -P python)
    PYTHON_VERSION=$("$PYTHON_CMD" --version 2>&1 | grep -oP "[0-9]+\.[0-9]+\.[0-9]+" || true)

    if [[ -n "$PYTHON_VERSION" ]]; then
        echo "✅ Installed (Version: $PYTHON_VERSION)"
    else
        echo "❌ Python version check failed"
        exit 1
    fi
else
    echo "❌ Python is NOT installed"
    exit 1
fi

echo "✅ All checks passed successfully!"
exit 0
