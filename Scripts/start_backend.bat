@echo off
title YouTube Subtitle Downloader Backend
echo.
echo ==========================================
echo  YouTube Subtitle Downloader Backend
echo ==========================================
echo.
echo Starting server on http://localhost:5000
echo Press Ctrl+C to stop the server
echo.

:: Activate virtual environment
call USE\Scripts\activate.bat

:: Add FFmpeg to PATH (Windows specific)
set "FFMPEG_PATH=%LOCALAPPDATA%\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-7.1.1-full_build\bin"
if exist "%FFMPEG_PATH%" (
    set "PATH=%PATH%;%FFMPEG_PATH%"
    echo [INFO] FFmpeg added to PATH
)

:: Start the backend
cd Backend
python app.py

pause
