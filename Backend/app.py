from flask import Flask, request, jsonify, send_file
from yt_dlp import YoutubeDL
import os
import zipfile
import shutil
import time
import random
from flask_cors import CORS
import tempfile
import traceback

app = Flask(__name__)
CORS(app)

TEMP_DIR = "temp"
os.makedirs(TEMP_DIR, exist_ok=True)

def get_output_path(video_id, lang):
    return os.path.join(TEMP_DIR, f"{video_id}.{lang}.srt")

@app.route("/get_subtitles")
def get_subtitles():
    video_url = request.args.get("url")
    if not video_url:
        return jsonify({"error": "No URL provided"}), 400

    # Basic yt-dlp options with retry logic
    ydl_opts = {
        'skip_download': True,
        'writesubtitles': False,
        'writeautomaticsub': False,
        'quiet': False,  # Enable logging for debugging
        'no_warnings': False,
        'extract_flat': False,
    }

    try:
        print(f"Extracting info for: {video_url}")
        with YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(video_url, download=False)
            
        print(f"Successfully extracted info for video: {info.get('title', 'Unknown')}")
        
        subtitles = info.get('subtitles', {})
        auto_subs = info.get('automatic_captions', {})
        video_id = info.get('id')

        all_tracks = {**subtitles, **auto_subs}
        subtitle_list = []

        for lang in all_tracks:
            subtitle_list.append({
                "language": lang,
                "url": f"/download_subtitle?url={video_url}&lang={lang}"
            })

        print(f"Found {len(subtitle_list)} subtitle tracks")
        
        return jsonify({
            "video_id": video_id,
            "title": info.get('title'),
            "subtitles": subtitle_list,
            "download_all": f"/download_all_subtitles?url={video_url}"
        })
        
    except Exception as e:
        error_msg = str(e)
        print(f"Error in get_subtitles: {error_msg}")
        print(f"Traceback: {traceback.format_exc()}")
        
        # Handle specific YouTube errors
        if '429' in error_msg or 'Too Many Requests' in error_msg:
            return jsonify({"error": "YouTube rate limit exceeded. Please wait and try again."}), 429
        elif 'Private video' in error_msg:
            return jsonify({"error": "This video is private."}), 403
        elif 'Video unavailable' in error_msg:
            return jsonify({"error": "Video is unavailable or has been removed."}), 404
        else:
            return jsonify({"error": f"Failed to fetch subtitles: {error_msg}"}), 500

@app.route("/download_subtitle")
def download_subtitle():
    video_url = request.args.get("url")
    lang = request.args.get("lang")
    if not video_url or not lang:
        return jsonify({"error": "Missing URL or language"}), 400

    # Add delay to prevent rate limiting
    time.sleep(random.uniform(1, 3))

    try:
        ydl_opts = {
            'writesubtitles': True,
            'writeautomaticsub': True,
            'subtitleslangs': [lang],
            'subtitlesformat': 'srt',
            'skip_download': True,
            'outtmpl': os.path.join(TEMP_DIR, '%(id)s.%(ext)s'),
            'quiet': False,
            'no_warnings': False,
        }
        
        print(f"Downloading subtitle {lang} for: {video_url}")
        
        with YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(video_url, download=True)
            video_id = info.get('id')
            filepath = get_output_path(video_id, lang)

            if not os.path.exists(filepath):
                return jsonify({"error": f"Subtitle file not found for language: {lang}"}), 404

            print(f"Successfully downloaded subtitle: {filepath}")
            return send_file(filepath, as_attachment=True, download_name=f"{lang}.srt")
            
    except Exception as e:
        error_msg = str(e)
        print(f"Error downloading subtitle {lang}: {error_msg}")
        
        if '429' in error_msg or 'Too Many Requests' in error_msg:
            return jsonify({"error": "Rate limited. Please wait and try again."}), 429
        else:
            return jsonify({"error": f"Failed to download subtitle: {error_msg}"}), 500

@app.route('/download_all_subtitles')
def download_all_subtitles():
    url = request.args.get('url')

    if not url:
        return jsonify({'error': 'Missing URL parameter'}), 400

    temp_dir = tempfile.mkdtemp()
    zip_path = os.path.join(temp_dir, 'subtitles.zip')

    try:
        # Get all subtitle languages
        ydl_opts = {
            'quiet': False,
            'skip_download': True,
        }
        
        with YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            subtitles = info.get('subtitles', {})
            automatic_captions = info.get('automatic_captions', {})

        all_subs = {**automatic_captions, **subtitles}
        if not all_subs:
            return jsonify({'error': 'No subtitles found'}), 404

        downloaded_files = []
        failed_languages = []

        for i, lang in enumerate(all_subs.keys()):
            try:
                # Progressive delay to avoid rate limiting
                if i > 0:
                    delay = min(3 + i, 8)  # Increase delay, cap at 8 seconds
                    print(f"Waiting {delay} seconds before downloading {lang}...")
                    time.sleep(delay)
                
                output_template = os.path.join(temp_dir, f'%(title)s.{lang}.%(ext)s')

                ydl_opts = {
                    'quiet': False,
                    'skip_download': True,
                    'writesubtitles': True,
                    'writeautomaticsub': True,
                    'subtitleslangs': [lang],
                    'subtitlesformat': 'srt',
                    'outtmpl': output_template,
                }

                with YoutubeDL(ydl_opts) as ydl:
                    ydl.download([url])
                    
            except Exception as e:
                error_str = str(e)
                print(f"Failed to download {lang}: {error_str}")
                failed_languages.append(lang)
                
                # If rate limited, wait longer
                if '429' in error_str or 'Too Many Requests' in error_str:
                    print("Rate limited, waiting 15 seconds...")
                    time.sleep(15)

        # Create ZIP file
        with zipfile.ZipFile(zip_path, 'w') as zipf:
            for root, dirs, files in os.walk(temp_dir):
                for file in files:
                    if file.endswith('.srt'):
                        file_path = os.path.join(root, file)
                        zipf.write(file_path, file)
                        downloaded_files.append(file)

        if not downloaded_files:
            return jsonify({'error': 'No subtitles could be downloaded.'}), 500

        print(f"Successfully downloaded {len(downloaded_files)} subtitle files")
        if failed_languages:
            print(f"Failed languages: {failed_languages}")
            
        return send_file(zip_path, as_attachment=True, download_name='subtitles.zip')

    except Exception as e:
        print(f"Error in download_all_subtitles: {str(e)}")
        return jsonify({'error': str(e)}), 500
    finally:
        # Clean up
        try:
            shutil.rmtree(temp_dir)
        except:
            pass

if __name__ == "__main__":
    print("Starting YouTube Subtitle Downloader Backend...")
    print("FFmpeg status:", "Available" if shutil.which("ffmpeg") else "Not found")
    app.run(port=5000, debug=True)
