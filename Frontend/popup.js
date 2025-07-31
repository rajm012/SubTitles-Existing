console.log('Script loaded successfully');

document.addEventListener('DOMContentLoaded', function() {
  console.log('DOM loaded');
  
  const input = document.getElementById('ytLink');
  const button = document.getElementById('fetchSubs');
  const status = document.getElementById('status');
  const results = document.getElementById('results');
  const downloadAllSection = document.getElementById('downloadAllSection');
  const downloadAllBtn = document.getElementById('downloadAllBtn');
  const subtitleCount = document.getElementById('subtitleCount');
  
  // Auto-focus input
  if (input) {
    input.focus();
  }
  
  // Test if elements exist
  console.log('Elements found:', {
    input: !!input,
    button: !!button,
    status: !!status,
    results: !!results
  });
  
  function showStatus(message, type = 'error') {
    if (status) {
      status.textContent = message;
      status.className = `status ${type}`;
      status.style.display = 'block';
    }
    console.log('Status:', message);
  }
  
  function hideStatus() {
    if (status) {
      status.style.display = 'none';
    }
  }
  
  function isValidYouTubeUrl(url) {
    const youtubeRegex = /^(https?:\/\/)?(www\.)?(youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/|youtube\.com\/v\/)[a-zA-Z0-9_-]{11}/;
    return youtubeRegex.test(url);
  }
  
  function createSubtitleItem(subtitle, videoUrl) {
    const item = document.createElement('div');
    item.className = 'subtitle-item';
    
    // Get language code for flag
    const langCode = subtitle.language.split('-')[0].substring(0, 2).toUpperCase();
    
    item.innerHTML = `
      <div class="language-info">
        <div class="language-flag">${langCode}</div>
        <div class="language-name">${subtitle.language}</div>
      </div>
      <button class="download-btn" data-url="${videoUrl}" data-lang="${subtitle.language}">
        Download
      </button>
    `;
    
    // Add click event to download button
    const downloadBtn = item.querySelector('.download-btn');
    downloadBtn.addEventListener('click', function() {
      downloadSubtitle(videoUrl, subtitle.language);
    });
    
    return item;
  }
  
  function downloadSubtitle(videoUrl, language) {
    console.log('Downloading subtitle:', language);
    const downloadUrl = `http://localhost:5000/download_subtitle?url=${encodeURIComponent(videoUrl)}&lang=${encodeURIComponent(language)}`;
    window.open(downloadUrl, '_blank');
  }
  
  function downloadAllSubtitles(videoUrl) {
    console.log('Downloading all subtitles');
    const downloadUrl = `http://localhost:5000/download_all_subtitles?url=${encodeURIComponent(videoUrl)}`;
    window.open(downloadUrl, '_blank');
  }
  
  if (button) {
    button.addEventListener('click', async function() {
      console.log('Button clicked');
      const videoUrl = input.value.trim();
      
      if (!videoUrl) {
        showStatus('Please enter a YouTube video URL');
        return;
      }
      
      if (!isValidYouTubeUrl(videoUrl)) {
        showStatus('Please enter a valid YouTube URL');
        return;
      }
      
      button.disabled = true;
      button.textContent = 'Loading...';
      hideStatus();
      results.innerHTML = '';
      if (downloadAllSection) downloadAllSection.style.display = 'none';
      
      try {
        console.log('Fetching subtitles for:', videoUrl);
        const response = await fetch(`http://localhost:5000/get_subtitles?url=${encodeURIComponent(videoUrl)}`);
        
        if (!response.ok) {
          throw new Error(`Server error: ${response.status}`);
        }
        
        const data = await response.json();
        console.log('Response data:', data);
        
        if (data.error) {
          throw new Error(data.error);
        }
        
        const subtitles = data.subtitles || [];
        
        if (subtitleCount) {
          subtitleCount.textContent = subtitles.length;
        }
        
        if (subtitles.length === 0) {
          results.innerHTML = `
            <div class="empty-state">
              <h3>No Subtitles Found</h3>
              <p>This video doesn't have any available subtitles or captions.</p>
            </div>
          `;
        } else {
          showStatus(`Found ${subtitles.length} subtitle tracks`, 'success');
          
          // Show download all button
          if (downloadAllSection) {
            downloadAllSection.style.display = 'block';
            if (downloadAllBtn) {
              downloadAllBtn.onclick = () => downloadAllSubtitles(videoUrl);
            }
          }
          
          // Create subtitle items
          results.innerHTML = '';
          subtitles.forEach((subtitle, index) => {
            setTimeout(() => {
              const item = createSubtitleItem(subtitle, videoUrl);
              results.appendChild(item);
            }, index * 50); // Stagger animations
          });
        }
        
      } catch (error) {
        console.error('Error:', error);
        let errorMessage = 'Failed to fetch subtitles. Please try again.';
        
        if (error.message.includes('Failed to fetch')) {
          errorMessage = 'Cannot connect to backend server. Make sure it\'s running on localhost:5000.';
        } else if (error.message) {
          errorMessage = error.message;
        }
        
        showStatus(errorMessage);
        results.innerHTML = `
          <div class="empty-state">
            <h3>Error</h3>
            <p>${errorMessage}</p>
          </div>
        `;
        
      } finally {
        button.disabled = false;
        button.textContent = 'Fetch Subtitles';
      }
    });
  }
  
  // Handle Enter key
  if (input) {
    input.addEventListener('keypress', function(e) {
      if (e.key === 'Enter') {
        button.click();
      }
    });
  }
  
  // Auto-fill from current tab if possible
  if (typeof chrome !== 'undefined' && chrome.tabs) {
    chrome.tabs.query({ active: true, currentWindow: true }, function(tabs) {
      const currentTab = tabs[0];
      if (currentTab && currentTab.url && isValidYouTubeUrl(currentTab.url)) {
        input.value = currentTab.url;
        console.log('Auto-filled URL from current tab');
      }
    });
  }
});
