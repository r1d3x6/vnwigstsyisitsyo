#!/bin/bash

# YouTube to IPTV Playlist Generator - Single Attempt Version
# Only tries each channel once (faster but less reliable)

# Configuration
PLAYLIST_FILE="youtube_iptv.m3u"
LOG_FILE="generator.log"
TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')

# Channel list with verified URLs
declare -A channels=(
    ["Jamuna TV"]="https://www.youtube.com/@jamunatvonline/live|https://i.imgur.com/JAMUNA.png"
    ["Somoy TV"]="https://www.youtube.com/@SomoyTVNews/live|https://i.imgur.com/SOMOY.png"
    ["Sky News"]="https://www.youtube.com/@skynews/live"
    # Add other channels as needed
)

# Initialize files
echo "#EXTM3U" > "$PLAYLIST_FILE"
echo "# Generated: $TIMESTAMP" >> "$PLAYLIST_FILE"
echo "=== Generation Started ===" > "$LOG_FILE"

# Install yt-dlp if missing
if ! command -v yt-dlp &> /dev/null; then
    pip install yt-dlp >> "$LOG_FILE" 2>&1 || {
        echo "ERROR: Failed to install yt-dlp" | tee -a "$LOG_FILE"
        exit 1
    }
fi

# Process channels (single attempt each)
total=0
success=0

for channel in "${!channels[@]}"; do
    ((total++))
    IFS='|' read -r url logo <<< "${channels[$channel]}"
    
    echo "Processing $channel..." | tee -a "$LOG_FILE"
    
    # Single attempt only
    stream_url=$(yt-dlp -g --format "best" \
               --user-agent "Mozilla/5.0" \
               --no-check-certificate \
               "$url" 2>> "$LOG_FILE")
    
    if [ -n "$stream_url" ]; then
        echo "#EXTINF:-1 tvg-id=\"${channel// /-}\" tvg-logo=\"${logo:-https://i.imgur.com/TV.png}\",$channel" >> "$PLAYLIST_FILE"
        echo "$stream_url" >> "$PLAYLIST_FILE"
        echo "SUCCESS: Added $channel" | tee -a "$LOG_FILE"
        ((success++))
    else
        echo "ERROR: Failed to fetch $channel" | tee -a "$LOG_FILE"
    fi
done

# Results summary
{
    echo ""
    echo "=== Results ==="
    echo "Time: $(date +'%Y-%m-%d %H:%M:%S')"
    echo "Total: $total"
    echo "Success: $success"
    echo "Failed: $((total - success))"
} | tee -a "$LOG_FILE"

[ "$success" -gt 0 ] || exit 1
exit 0
