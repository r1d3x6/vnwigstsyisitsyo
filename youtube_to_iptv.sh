#!/bin/bash

# YouTube to IPTV Playlist Generator with Logo Support
# Full working version with channel logos

# Configuration
PLAYLIST_FILE="youtube_iptv.m3u"
LOG_FILE="generator.log"
TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')

# Channel configuration with logos (Format: "Channel Name"="YouTube URL|Logo URL")
declare -A channels=(
    ["24/7 Mr bean"]="https://www.youtube.com/live/amzgpxDsJjQ|https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQRdE8B6TfR8VPk_FyFC98t97So4oPnEkYmJtH_gJHYiTeMT0A2KNmoIJI&s=10"
["Jamuna TV"]="https://wwe.youtube.com/watch?v=yDzvLqfQhyM|https://raw.githubusercontent.com/r1d3x6/tandjtales/refs/heads/Tom-and-Jerry-Tales/jamunatv.png"
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
    # Add more in format: ["Name"]="URL|LOGO"
    # Add more channels with logos in the same format
)

# Initialize files
echo "#EXTM3U x-tvg-url=\"https://example.com/epg.xml\"" > "$PLAYLIST_FILE"
echo "# Generated: $TIMESTAMP" >> "$PLAYLIST_FILE"
echo "=== Playlist Generation Started ===" > "$LOG_FILE"

# Function to get stream URL with retries
get_stream_url() {
    local url=$1
    local channel=$2
    
    echo "Fetching stream for $channel..." >> "$LOG_FILE"
    
    # Try with standard method first
    stream_url=$(yt-dlp -g --format "best" \
              --user-agent "Mozilla/5.0" \
              --no-check-certificate \
              "$url" 2>> "$LOG_FILE")
    
    # Fallback to browser cookies if needed
    [ -z "$stream_url" ] && stream_url=$(yt-dlp -g --format "best" \
              --cookies-from-browser chrome \
              "$url" 2>> "$LOG_FILE")
    
    if [[ "$stream_url" == http* ]]; then
        echo "$stream_url"
        return 0
    else
        echo "Failed to get stream for $channel" >> "$LOG_FILE"
        return 1
    fi
}

# Process channels
total=0
success=0

for channel in "${!channels[@]}"; do
    ((total++))
    IFS='|' read -r url logo_url <<< "${channels[$channel]}"
    
    echo "Processing: $channel" | tee -a "$LOG_FILE"
    
    if stream_url=$(get_stream_url "$url" "$channel"); then
        # Clean channel ID for tvg-id
        clean_id=$(echo "$channel" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
        
        # Write complete playlist entry with logo
        echo "#EXTINF:-1 tvg-id=\"$clean_id\" tvg-logo=\"$logo_url\" group-title=\"News\",$channel" >> "$PLAYLIST_FILE"
        echo "$stream_url" >> "$PLAYLIST_FILE"
        echo "" >> "$PLAYLIST_FILE"  # Blank line between entries
        
        ((success++))
        echo "SUCCESS: Added $channel with logo" | tee -a "$LOG_FILE"
    else
        echo "ERROR: Failed to process $channel" | tee -a "$LOG_FILE"
    fi
done

# Final output
{
    echo ""
    echo "=== Generation Summary ==="
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
