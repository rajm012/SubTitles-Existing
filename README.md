# 🎬 YouTube Subtitle Downloader

A modern Chrome extension that allows you to download existing subtitles from any YouTube video with just one click. Features a beautiful interface, rate limiting protection, and supports downloading individual subtitles or all available languages as a ZIP file.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Chrome Extension](https://img.shields.io/badge/Chrome-Extension-yellow.svg)

## ✨ Features

- 🎯 **One-Click Download**: Simply paste a YouTube URL and get all available subtitles
- 🌍 **Multi-Language Support**: Download subtitles in 160+ languages
- 📦 **Bulk Download**: Download all subtitles as a convenient ZIP file
- 🎨 **Modern UI**: Beautiful, responsive interface with smooth animations
- 🛡️ **Rate Limiting Protection**: Smart delays prevent YouTube API blocks
- 🔄 **Auto-Retry Logic**: Automatically handles temporary failures
- 📱 **Browser Integration**: Works seamlessly as a Chrome extension
- 🚀 **Fast & Reliable**: Optimized for speed and stability

## 🖼️ Screenshots

### Extension Popup
The clean, modern interface makes downloading subtitles effortless:

```
┌─────────────────────────────────┐
│ 🎬 Subtitle Downloader    v1.0 │
├─────────────────────────────────┤
│ [Paste YouTube URL here...    ] │
│ [     Fetch Subtitles        ] │
├─────────────────────────────────┤
│ ✅ Found 160 subtitle tracks    │
│ [📥 Download All (.zip)      ] │
├─────────────────────────────────┤
│ 🇺🇸 en          [Download]     │
│ 🇪🇸 es          [Download]     │
│ 🇫🇷 fr          [Download]     │
│ 🇩🇪 de          [Download]     │
│ ...                             │
└─────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- **Python 3.7+** (with pip)
- **Google Chrome** browser
- **FFmpeg** (for optimal video processing)

### 1. Install FFmpeg

#### Windows
```bash
winget install FFmpeg
```

#### macOS
```bash
brew install ffmpeg
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install ffmpeg
```

### 2. Setup Backend

1. **Clone the repository:**
   ```bash
   git clone SubTitles-Existing
   cd SubTitles-Existing
   ```

2. **Create virtual environment:**
   ```bash
   python -m venv USE
   ```

3. **Activate virtual environment:**
   ```bash
   # Windows
   USE\Scripts\activate
   
   # macOS/Linux
   source USE/bin/activate
   ```

4. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

5. **Start the backend server:**
   ```bash
   cd Backend
   python app.py
   ```

   You should see:
   ```
   Starting YouTube Subtitle Downloader Backend...
   FFmpeg status: Available
   * Running on http://127.0.0.1:5000
   ```

### 3. Install Chrome Extension

1. **Open Chrome** and navigate to `chrome://extensions/`

2. **Enable Developer mode** (toggle in top-right corner)

3. **Click "Load unpacked"** and select the `Frontend` folder

4. **Pin the extension** to your toolbar for easy access

### 4. Start Downloading!

1. **Navigate to any YouTube video**
2. **Click the extension icon** 📺
3. **Paste the video URL** (auto-filled if on YouTube)
4. **Click "Fetch Subtitles"**
5. **Download individual languages** or **"Download All"** as ZIP

## 🏗️ Project Structure

```
UTubeTitles/
├── 📁 Backend/
│   ├── app.py              # Flask API server
│   ├── temp/               # Temporary subtitle files
│   └── requirements.txt    # Python dependencies
├── 📁 Frontend/
│   ├── manifest.json       # Chrome extension manifest
│   ├── popup.html          # Extension popup interface
│   ├── popup.js            # Frontend logic
│   ├── style.css           # Styling
│   └── 📁 icons/           # Extension icons
│       ├── icon16.png
│       ├── icon32.png
│       ├── icon48.png
│       └── icon128.png
├── 📁 USE/                 # Python virtual environment
├── requirements.txt        # Complete dependency list
└── README.md              # This file
```


## ⚙️ Configuration

### Backend Settings

The backend includes several configurable options in `app.py`:

```python
# Rate limiting settings
SLEEP_INTERVAL = 1          # Base delay between requests
MAX_SLEEP_INTERVAL = 8      # Maximum delay for bulk downloads
PROGRESSIVE_DELAY = True    # Enable progressive delays

# File settings
TEMP_DIR = "temp"          # Temporary file directory
DEBUG_MODE = True          # Enable debug logging
```

### Frontend Settings

Chrome extension permissions in `manifest.json`:

```json
{
  "permissions": ["activeTab"],
  "host_permissions": [
    "*://www.youtube.com/*",
    "*://youtu.be/*",
    "http://localhost:5000/*"
  ]
}
```

## 🛠️ Troubleshooting

### Common Issues

#### ❌ "Cannot connect to backend server"
**Solution:** Ensure the backend is running on `localhost:5000`
```bash
cd Backend
python app.py
```

#### ❌ "Rate limited by YouTube" 
**Solution:** Wait 2-3 minutes and try again. The backend will automatically retry with delays.

#### ❌ "FFmpeg not found"
**Solution:** Install FFmpeg and restart your terminal:
```bash
# Windows
winget install FFmpeg

# Restart your terminal/PowerShell
```

#### ❌ "Extension popup is blank"
**Solution:** Check Chrome Developer Console:
1. Right-click extension icon → "Inspect popup"
2. Check Console tab for errors
3. Reload the extension in `chrome://extensions/`

#### ❌ "Video is private/unavailable"
**Solution:** Ensure the YouTube video is public and accessible.

### Debug Mode

Enable debug logging by modifying `app.py`:
```python
app.run(port=5000, debug=True)
```

This provides detailed logging of all requests and errors.

## 🔒 Privacy & Security

- **No Data Storage**: Subtitles are temporarily downloaded and immediately deleted
- **Local Processing**: All processing happens on your machine
- **No Analytics**: No tracking or data collection
- **Open Source**: Full source code available for audit


## Building for Production

1. **Optimize backend for production:**
   ```python
   # Use production WSGI server
   pip install gunicorn
   gunicorn -w 4 -b 127.0.0.1:5000 app:app
   ```

2. **Package Chrome extension:**
   - Zip the `Frontend` folder
   - Upload to Chrome Web Store

### Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit changes: `git commit -am 'Add feature'`
4. Push to branch: `git push origin feature-name`
5. Submit a Pull Request

## 📝 Dependencies

### Backend (Python)
- **Flask 3.1.1** - Web framework
- **yt-dlp 2025.7.21** - YouTube download library
- **flask-cors 6.0.1** - Cross-origin resource sharing
- **requests 2.32.3** - HTTP library
- **FFmpeg** - Video/audio processing (system dependency)

### Frontend (JavaScript)
- **Vanilla JavaScript** - No external dependencies
- **Chrome Extension APIs** - Browser integration
- **CSS3** - Modern styling with animations

## 📊 Performance

- **Subtitle Fetching**: ~2-3 seconds per video
- **Individual Download**: ~1-2 seconds per subtitle
- **Bulk Download**: ~5-15 seconds depending on number of languages
- **Memory Usage**: <50MB typical
- **Storage**: Temporary files auto-deleted

## 🌟 Upcoming Features

- [ ] Firefox extension support
- [ ] Batch processing for multiple videos
- [ ] Custom subtitle format options (VTT, ASS, etc.)
- [ ] Dark/Light theme toggle
- [ ] Subtitle preview before download
- [ ] Integration with video downloaders

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Support

- **Issues**: Report bugs on GitHub Issues
- **Feature Requests**: Submit via GitHub Issues
- **Documentation**: Available in this README

## 🎉 Acknowledgments

- **yt-dlp** - Powerful YouTube download library
- **Flask** - Lightweight web framework
- **Chrome Extension APIs** - Browser integration
- **FFmpeg** - Media processing capabilities

---

<div align="center">

**Made with ❤️ for YouTube creators and subtitle enthusiasts**

[⭐ Star this repository](../../) if you found it helpful!

</div>
