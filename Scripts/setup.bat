@echo off
:: YouTube Subtitle Downloader - Windows Setup Script
:: This script automates the installation process

echo.
echo =========================================
echo  YouTube Subtitle Downloader Setup
echo =========================================
echo.

:: Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed or not in PATH
    echo Please install Python 3.7+ from https://python.org
    pause
    exit /b 1
)

echo [INFO] Python found: 
python --version

:: Check if pip is available
pip --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] pip is not available
    echo Please ensure pip is installed with Python
    pause
    exit /b 1
)

:: Install FFmpeg if not present
echo.
echo [INFO] Checking FFmpeg...
ffmpeg -version >nul 2>&1
if errorlevel 1 (
    echo [INFO] FFmpeg not found. Installing via winget...
    winget install FFmpeg
    if errorlevel 1 (
        echo [WARNING] FFmpeg installation failed. Please install manually.
        echo Download from: https://ffmpeg.org/download.html
    ) else (
        echo [SUCCESS] FFmpeg installed successfully
    )
) else (
    echo [SUCCESS] FFmpeg is already installed
)

:: Create virtual environment
echo.
echo [INFO] Creating virtual environment...
if exist "USE" (
    echo [INFO] Virtual environment already exists
) else (
    python -m venv USE
    if errorlevel 1 (
        echo [ERROR] Failed to create virtual environment
        pause
        exit /b 1
    )
    echo [SUCCESS] Virtual environment created
)

:: Activate virtual environment and install dependencies
echo.
echo [INFO] Installing Python dependencies...
call USE\Scripts\activate.bat
pip install -r requirements.txt
if errorlevel 1 (
    echo [ERROR] Failed to install dependencies
    pause
    exit /b 1
)

echo [SUCCESS] Dependencies installed successfully

:: Create startup script
echo.
echo [INFO] Creating startup script...
echo @echo off > start_backend.bat
echo echo Starting YouTube Subtitle Downloader Backend... >> start_backend.bat
echo call USE\Scripts\activate.bat >> start_backend.bat
echo cd Backend >> start_backend.bat
echo python app.py >> start_backend.bat
echo pause >> start_backend.bat

echo [SUCCESS] Startup script created: start_backend.bat

:: Final instructions
echo.
echo =========================================
echo  Setup Complete!
echo =========================================
echo.
echo Next steps:
echo 1. Run 'start_backend.bat' to start the server
echo 2. Open Chrome and go to chrome://extensions/
echo 3. Enable 'Developer mode'
echo 4. Click 'Load unpacked' and select the 'Frontend' folder
echo 5. Start downloading subtitles!
echo.
echo For detailed instructions, see README.md
echo.
pause
