#!/bin/bash
# Install curl-impersonate to bypass Cloudflare on APKMirror
# Run this script if you're getting 403 errors from APKMirror

set -e

echo "[+] Installing curl-impersonate for Cloudflare bypass..."

# curl-impersonate version
VERSION="0.6.1"

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
        RELEASE_URL="https://github.com/lwthiker/curl-impersonate/releases/download/v${VERSION}/curl-impersonate-v${VERSION}.x86_64-linux-gnu.tar.gz"
    elif [ "$ARCH" = "aarch64" ]; then
        RELEASE_URL="https://github.com/lwthiker/curl-impersonate/releases/download/v${VERSION}/curl-impersonate-v${VERSION}.aarch64-linux-gnu.tar.gz"
    else
        echo "[-] Unsupported architecture: $ARCH"
        exit 1
    fi
    
    # Download and install
    echo "[+] Downloading from $RELEASE_URL"
    wget -q "$RELEASE_URL" -O /tmp/curl-impersonate.tar.gz
    
    echo "[+] Extracting..."
    cd /tmp
    tar -xzf curl-impersonate.tar.gz
    
    echo "[+] Installing to /usr/local/bin..."
    sudo cp curl-impersonate-chrome /usr/local/bin/
    sudo chmod +x /usr/local/bin/curl-impersonate-chrome
    
    # Install required libraries
    echo "[+] Installing libraries..."
    if [ -d lib ]; then
        sudo mkdir -p /usr/local/lib/curl-impersonate
        sudo cp -r lib/* /usr/local/lib/curl-impersonate/ || true
        # Update library path
        echo "/usr/local/lib/curl-impersonate" | sudo tee /etc/ld.so.conf.d/curl-impersonate.conf > /dev/null
        sudo ldconfig
    fi
    
    echo "[+] Cleaning up..."
    rm -f /tmp/curl-impersonate.tar.gz
    cd - > /dev/null
    
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
