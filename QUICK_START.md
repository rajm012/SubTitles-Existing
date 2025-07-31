# 🚀 Quick Start Guide

Get up and running with YouTube Subtitle Downloader in 5 minutes!

## 🎯 Super Quick Setup (Windows)

1. **Download and extract** the project files
2. **Double-click** `setup.bat` to auto-install everything
3. **Run** `start_backend.bat` to start the server
4. **Open Chrome** → `chrome://extensions/` → Enable Developer mode
5. **Click "Load unpacked"** → Select the `Frontend` folder
6. **Done!** Click the extension icon to start downloading subtitles

## 🐧 Linux/macOS Quick Setup

```bash
# Make setup script executable and run it
chmod +x setup.sh
./setup.sh

# Start the backend
./start_backend.sh
```

Then follow steps 4-6 from Windows setup above.

## ✅ Verify Installation

1. **Backend running?** Visit http://localhost:5000 in your browser
2. **Extension loaded?** Look for the 📺 icon in Chrome toolbar
3. **FFmpeg working?** Check the backend console for "FFmpeg status: Available"

## 🎬 Download Your First Subtitles

1. Go to **any YouTube video**
2. **Click the extension icon** 📺
3. The URL should **auto-fill** (or paste manually)
4. Click **"Fetch Subtitles"**
5. Choose **individual downloads** or **"Download All (.zip)"**

## ❓ Need Help?

- **Blank popup?** → Restart Chrome and reload the extension
- **Can't connect?** → Make sure `start_backend.bat` is running
- **No subtitles found?** → Try a different video (some have no captions)
- **Rate limited?** → Wait 2-3 minutes and try again

## 🔗 Useful Links

- **Full Documentation**: See `README.md`
- **Troubleshooting**: Check the troubleshooting section in README
- **Issues**: Report problems on GitHub

---

**That's it! You're ready to download subtitles from any YouTube video! 🎉**
