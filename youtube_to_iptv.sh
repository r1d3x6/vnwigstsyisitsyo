#!/bin/bash

# Enhanced YouTube to IPTV Playlist Generator
# With comprehensive error handling

# Configuration
PLAYLIST_FILE="youtube_iptv.m3u"
LOG_FILE="generator.log"
TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
MAX_RETRIES=3
RETRY_DELAY=2

# Initialize files
echo "#EXTM3U" > "$PLAYLIST_FILE"
echo "# Generated: $TIMESTAMP" >> "$PLAYLIST_FILE"
echo "=== Playlist Generation Log ===" > "$LOG_FILE"
echo "Start Time: $TIMESTAMP" >> "$LOG_FILE"

# Channel configuration with improved URL handling
declare -A channels=(
["24/7 Mr bean"]="https://m.youtube.com/live/amzgpxDsJjQ|https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQRdE8B6TfR8VPk_FyFC98t97So4oPnEkYmJtH_gJHYiTeMT0A2KNmoIJI&s=10"
       ["Jamuna TV"]="https://m.youtube.com/watch?v=yDzvLqfQhyM|https://raw.githubusercontent.com/r1d3x6/tandjtales/refs/heads/Tom-and-Jerry-Tales/jamunatv.png"
       ["Somoy TV"]="https://m.youtube.com/watch?v=OJVLgmpnk4U|https://raw.githubusercontent.com/r1d3x6/tandjtales/refs/heads/Tom-and-Jerry-Tales/somoytv.png"
       ["Ekattor TV"]="https://m.youtube.com/watch?v=Byw9GNvDz8A|https://raw.githubusercontent.com/r1d3x6/skgitvglogojkkk/refs/heads/main/ekattor-tv.png"
       ["Channel 24"]="https://m.youtube.com/watch?v=HjZ48tDFjZU|https://raw.githubusercontent.com/r1d3x6/tandjtales/refs/heads/Tom-and-Jerry-Tales/channel-24.png"
       ["Independent TV"]="https://m.youtube.com/watch?v=wuUhC6jfqrY|https://raw.githubusercontent.com/r1d3x6/skgitvglogojkkk/refs/heads/main/indipendent.png"
       ["Sky News"]="https://m.youtube.com/watch?v=YDvsBbKfLPA"
       ["Arirang TV"]="https://m.youtube.com/watch?v=CJVBX7KI5nU"
       ["YTN"]="https://m.youtube.com/watch?v=xfFa_kcPnCY"
       ["Aljazeera English"]="https://m.youtube.com/watch?v=gCNeDWCI0vo|https://raw.githubusercontent.com/r1d3x6/skgitvglogojkkk/refs/heads/main/aljazeera.png"
       ["ANN NEWS CH"]="https://m.youtube.com/watch?v=coYw-eVU0Ks"
       ["GEO News"]="https://m.youtube.com/watch?v=O3DPVlynUM0"
       ["Alquran Alkareem"]="https://m.youtube.com/watch?v=-BlZnoDjxmM|https://raw.githubusercontent.com/r1d3x6/skgitvglogojkkk/refs/heads/main/alquran-alkarim.png"

)

# Install yt-dlp if missing
if ! command -v yt-dlp &> /dev/null; then
    echo "Installing yt-dlp..." | tee -a "$LOG_FILE"
    pip install yt-dlp || {
        echo "Failed to install yt-dlp" | tee -a "$LOG_FILE"
        exit 1
    }
fi

# Function to get stream URL with retries
get_stream_url() {
    local url=$1
    local attempt=0
    local stream_url=""
    
    while [ $attempt -lt $MAX_RETRIES ]; do
        echo "Attempt $((attempt+1)) for $url" >> "$LOG_FILE"
        stream_url=$(yt-dlp -g --format "best" "$url" 2>> "$LOG_FILE")
        
        if [ -n "$stream_url" ]; then
            echo "$stream_url"
            return 0
        fi
        
        sleep $RETRY_DELAY
        ((attempt++))
    done
    
    return 1
}

# Process channels
total_channels=0
success_count=0

echo "Processing channels..." | tee -a "$LOG_FILE"

for channel in "${!channels[@]}"; do
    ((total_channels++))
    IFS='|' read -r url logo_url <<< "${channels[$channel]}"
    
    echo "Processing: $channel" | tee -a "$LOG_FILE"
    echo "URL: $url" >> "$LOG_FILE"
    
    if stream_url=$(get_stream_url "$url"); then
        [ -z "$logo_url" ] && logo_url="https://i.imgur.com/TV.png"
        
        echo "#EXTINF:-1 tvg-id=\"${channel// /-}\" tvg-logo=\"$logo_url\",$channel" >> "$PLAYLIST_FILE"
        echo "$stream_url" >> "$PLAYLIST_FILE"
        
        echo "Success: Added $channel" | tee -a "$LOG_FILE"
        ((success_count++))
    else
        echo "ERROR: Failed after $MAX_RETRIES attempts for $channel" | tee -a "$LOG_FILE"
    fi
done

# Final status
{
    echo ""
    echo "=== Generation Summary ==="
    echo "End Time: $(date +'%Y-%m-%d %H:%M:%S')"
    echo "Total Channels: $total_channels"
    echo "Successfully Added: $success_count"
    echo "Failed: $((total_channels - success_count))"
    echo "Playlist Lines: $(wc -l < "$PLAYLIST_FILE")"
} | tee -a "$LOG_FILE"

# Verify playlist content
echo "" | tee -a "$LOG_FILE"
echo "Playlist Content:" | tee -a "$LOG_FILE"
head -n 10 "$PLAYLIST_FILE" | tee -a "$LOG_FILE"

# Exit with error if all failed
[ "$success_count" -eq 0 ] && exit 1
exit 0
