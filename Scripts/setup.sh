#!/bin/bash
# YouTube Subtitle Downloader - Linux/macOS Setup Script
# This script automates the installation process

echo ""
echo "========================================="
echo " YouTube Subtitle Downloader Setup"
echo "========================================="
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "[ERROR] Python 3 is not installed"
    echo "Please install Python 3.7+ from https://python.org"
    echo "Or use your package manager:"
    echo "  Ubuntu/Debian: sudo apt install python3 python3-pip"
    echo "  CentOS/RHEL: sudo yum install python3 python3-pip"
    echo "  macOS: brew install python3"
    exit 1
fi

echo "[INFO] Python found:"
python3 --version

# Check if pip is available
if ! command -v pip3 &> /dev/null; then
    echo "[ERROR] pip3 is not available"
    echo "Please install pip3:"
    echo "  Ubuntu/Debian: sudo apt install python3-pip"
    echo "  CentOS/RHEL: sudo yum install python3-pip"
    echo "  macOS: pip3 should be included with Python"
    exit 1
fi

# Check/Install FFmpeg
echo ""
echo "[INFO] Checking FFmpeg..."
if ! command -v ffmpeg &> /dev/null; then
    echo "[INFO] FFmpeg not found. Attempting to install..."
    
    # Detect OS and install FFmpeg
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command -v apt &> /dev/null; then
            echo "[INFO] Installing FFmpeg via apt..."
            sudo apt update && sudo apt install -y ffmpeg
        elif command -v yum &> /dev/null; then
            echo "[INFO] Installing FFmpeg via yum..."
            sudo yum install -y ffmpeg
        elif command -v dnf &> /dev/null; then
            echo "[INFO] Installing FFmpeg via dnf..."
            sudo dnf install -y ffmpeg
        else
            echo "[WARNING] Unable to auto-install FFmpeg. Please install manually."
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            echo "[INFO] Installing FFmpeg via Homebrew..."
            brew install ffmpeg
        else
            echo "[WARNING] Homebrew not found. Please install FFmpeg manually:"
            echo "  1. Install Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            echo "  2. Install FFmpeg: brew install ffmpeg"
        fi
    fi
    
    # Verify installation
    if command -v ffmpeg &> /dev/null; then
        echo "[SUCCESS] FFmpeg installed successfully"
    else
        echo "[WARNING] FFmpeg installation failed. The app will work but with reduced functionality."
        echo "Please install FFmpeg manually from: https://ffmpeg.org/download.html"
    fi
else
    echo "[SUCCESS] FFmpeg is already installed"
fi

# Create virtual environment
echo ""
echo "[INFO] Creating virtual environment..."
if [ -d "USE" ]; then
    echo "[INFO] Virtual environment already exists"
else
    python3 -m venv USE
    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to create virtual environment"
        echo "Please ensure python3-venv is installed:"
        echo "  Ubuntu/Debian: sudo apt install python3-venv"
        exit 1
    fi
    echo "[SUCCESS] Virtual environment created"
fi

# Activate virtual environment and install dependencies
echo ""
echo "[INFO] Installing Python dependencies..."
source USE/bin/activate
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to install dependencies"
    exit 1
fi

echo "[SUCCESS] Dependencies installed successfully"

# Create startup script
echo ""
echo "[INFO] Creating startup script..."
cat > start_backend.sh << 'EOF'
#!/bin/bash
echo "Starting YouTube Subtitle Downloader Backend..."
source USE/bin/activate
cd Backend
python app.py
EOF

chmod +x start_backend.sh
echo "[SUCCESS] Startup script created: start_backend.sh"

# Final instructions
echo ""
echo "========================================="
echo " Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Run './start_backend.sh' to start the server"
echo "2. Open Chrome and go to chrome://extensions/"
echo "3. Enable 'Developer mode'"
echo "4. Click 'Load unpacked' and select the 'Frontend' folder"
echo "5. Start downloading subtitles!"
echo ""
echo "For detailed instructions, see README.md"
echo ""
