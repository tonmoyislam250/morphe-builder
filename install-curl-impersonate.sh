#!/bin/bash
# Install curl-impersonate to bypass Cloudflare on APKMirror
# Run this script if you're getting 403 errors from APKMirror

set -e

echo "[+] Installing curl-impersonate for Cloudflare bypass..."

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
        ARCH="x86_64"
    elif [ "$ARCH" = "aarch64" ]; then
        ARCH="aarch64"
    else
        echo "[-] Unsupported architecture: $ARCH"
        exit 1
    fi
    
    # Download and install
    RELEASE_URL="https://github.com/lwthiker/curl-impersonate/releases/latest/download/curl-impersonate-chrome-linux-$ARCH.tar.gz"
    
    echo "[+] Downloading from $RELEASE_URL"
    wget -q "$RELEASE_URL" -O /tmp/curl-impersonate.tar.gz
    
    echo "[+] Extracting..."
    tar -xzf /tmp/curl-impersonate.tar.gz -C /tmp
    
    echo "[+] Installing to /usr/local/bin..."
    sudo install -m755 /tmp/curl-impersonate-chrome /usr/local/bin/
    
    # Install required libraries
    if [ -d /tmp/lib ]; then
        sudo cp -r /tmp/lib/* /usr/local/lib/ 2>/dev/null || true
    fi
    
    echo "[+] Cleaning up..."
    rm -f /tmp/curl-impersonate.tar.gz
    
    echo "[✓] curl-impersonate installed successfully!"
    echo "[+] Testing installation..."
    curl-impersonate-chrome --version 2>/dev/null || echo "    Binary installed at /usr/local/bin/curl-impersonate-chrome"
    
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if command -v brew &> /dev/null; then
        echo "[+] Installing via Homebrew..."
        brew install curl-impersonate
        echo "[✓] curl-impersonate installed successfully!"
    else
        echo "[-] Homebrew not found. Please install Homebrew first:"
        echo "    /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
else
    echo "[-] Unsupported OS: $OSTYPE"
    exit 1
fi

echo ""
echo "Now you can run ./build.sh and it will automatically use curl-impersonate for APKMirror"
