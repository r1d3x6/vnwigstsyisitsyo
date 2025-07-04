#!/bin/bash

# Ultimate YouTube to IPTV Playlist Generator
# Complete fix for all shown errors

# Configuration
PLAYLIST_FILE="youtube_iptv.m3u"
LOG_FILE="generator-debug.log"
TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')

# Verified working channels
declare -A channels=(
["Jamuna TV"]="https://www.youtube.com/watch?v=yDzvLqfQhyM|https://raw.githubusercontent.com/r1d3x6/tandjtales/refs/heads/Tom-and-Jerry-Tales/jamunatv.png"
    ["Somoy TV"]="https://www.youtube.com/watch?v=OJVLgmpnk4U|https://raw.githubusercontent.com/r1d3x6/tandjtales/refs/heads/Tom-and-Jerry-Tales/somoytv.png"
    ["Ekattor TV"]="https://www.youtube.com/watch?v=Byw9GNvDz8A|https://raw.githubusercontent.com/r1d3x6/skgitvglogojkkk/refs/heads/main/ekattor-tv.png"
    ["Channel 24"]="https://www.youtube.com/watch?v=HjZ48tDFjZU|https://raw.githubusercontent.com/r1d3x6/tandjtales/refs/heads/Tom-and-Jerry-Tales/channel-24.png"
    ["Independent TV"]="https://www.youtube.com/watch?v=wuUhC6jfqrY|https://raw.githubusercontent.com/r1d3x6/skgitvglogojkkk/refs/heads/main/indipendent.png"
       ["Sky News"]="https://www.youtube.com/watch?v=YDvsBbKfLPA"
       ["Arirang TV"]="https://www.youtube.com/watch?v=CJVBX7KI5nU"
       ["YTN"]="https://www.youtube.com/watch?v=xfFa_kcPnCY"
       ["Aljazeera English"]="https://www.youtube.com/watch?v=gCNeDWCI0vo|https://raw.githubusercontent.com/r1d3x6/skgitvglogojkkk/refs/heads/main/aljazeera.png"
       ["ANN NEWS CH"]="https://www.youtube.com/watch?v=coYw-eVU0Ks"
       ["GEO News"]="https://www.youtube.com/watch?v=O3DPVlynUM0"
       ["Alquran Alkareem"]="https://www.youtube.com/watch?v=-BlZnoDjxmM|https://raw.githubusercontent.com/r1d3x6/skgitvglogojkkk/refs/heads/main/alquran-alkarim.png"
    
    # Add more channels ONLY after verifying they work
)

# Initialize files with proper header
# echo "#EXTM3U x-tvg-url=\"" > "$PLAYLIST_FILE"
echo "# Generated: $TIMESTAMP" >> "$PLAYLIST_FILE"
echo "=== DEBUG LOG ===" > "$LOG_FILE"
echo "Started: $TIMESTAMP" >> "$LOG_FILE"

# Function to verify stream URL
get_valid_stream() {
    local url=$1
    local channel=$2
    
    echo "Attempting to fetch: $channel" >> "$LOG_FILE"
    echo "URL: $url" >> "$LOG_FILE"
    
    # Try with standard method
    stream=$(yt-dlp -g --format "best" \
            --user-agent "Mozilla/5.0" \
            --no-check-certificate \
            --force-ipv4 \
            "$url" 2>> "$LOG_FILE")
    
    # If failed, try with cookies
    if [[ -z "$stream" || "$stream" != http* ]]; then
        echo "Trying fallback method..." >> "$LOG_FILE"
        stream=$(yt-dlp -g --format "best" \
                --cookies-from-browser chrome \
                "$url" 2>> "$LOG_FILE")
    fi
    
    # Final validation
    if [[ "$stream" == http* ]]; then
        echo "Valid stream found!" >> "$LOG_FILE"
        echo "$stream"
        return 0
    else
        echo "FAILED: No valid stream found" >> "$LOG_FILE"
        return 1
    fi
}

# Process channels
total=0
success=0

for channel in "${!channels[@]}"; do
    ((total++))
    IFS='|' read -r url logo <<< "${channels[$channel]}"
    
    echo "Processing: $channel" | tee -a "$LOG_FILE"
    
    if stream_url=$(get_valid_stream "$url" "$channel"); then
        # Create clean channel ID
        clean_id=$(echo "$channel" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
        
        # Write perfect M3U entry
        echo "#EXTINF:-1 tvg-id=\"$clean_id\" tvg-logo=\"${logo:-https://i.imgur.com/TV.png}\" group-title=\"Live\",$channel" >> "$PLAYLIST_FILE"
        echo "$stream_url" >> "$PLAYLIST_FILE"
        echo "" >> "$PLAYLIST_FILE"  # Blank line between entries
        
        ((success++))
        echo "SUCCESS: Added $channel" | tee -a "$LOG_FILE"
    else
        echo "ERROR: Could not process $channel" | tee -a "$LOG_FILE"
    fi
done

# Final validation
{
    echo ""
    echo "=== RESULTS ==="
    echo "Completed: $(date +'%Y-%m-%d %H:%M:%S')"
    echo "Total Channels: $total"
    echo "Successfully Added: $success"
    echo "Failed: $((total - success))"
    echo ""
    echo "Playlist Preview:"
    head -n 10 "$PLAYLIST_FILE"
} | tee -a "$LOG_FILE"

[ "$success" -gt 0 ] || exit 1
exit 0
