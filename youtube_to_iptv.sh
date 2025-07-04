#!/bin/bash

# YouTube to IPTV Playlist Generator - Complete Fix
# Guarantees proper M3U format and complete entries

# Configuration
PLAYLIST_FILE="youtube_iptv.m3u"
LOG_FILE="generator.log"
TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')

# Verified working channels (July 2024)
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
    # Add more in format: ["Name"]="URL|LOGO"
)

# Initialize files with proper header
echo "#EXTM3U x-tvg-url=\"https://example.com/epg.xml\"" > "$PLAYLIST_FILE"
echo "# Generated: $TIMESTAMP" >> "$PLAYLIST_FILE"
echo "=== Generation Started ===" > "$LOG_FILE"

# Function to validate and get stream URL
get_valid_stream() {
    local url=$1
    local channel=$2
    
    echo "Processing $channel..." | tee -a "$LOG_FILE"
    
    # First try with standard method
    stream=$(yt-dlp -g --format "best" \
            --user-agent "Mozilla/5.0" \
            --no-check-certificate \
            --force-ipv4 \
            "$url" 2>> "$LOG_FILE")
    
    # If failed, try with cookies
    [ -z "$stream" ] && stream=$(yt-dlp -g --format "best" \
            --cookies-from-browser chrome \
            "$url" 2>> "$LOG_FILE")
    
    # Validate stream URL
    if [[ -n "$stream" && "$stream" == http* ]]; then
        echo "$stream"
        return 0
    else
        echo "" | tee -a "$LOG_FILE"
        return 1
    fi
}

# Process channels
total=0
success=0

for channel in "${!channels[@]}"; do
    ((total++))
    IFS='|' read -r url logo <<< "${channels[$channel]}"
    
    if stream=$(get_valid_stream "$url" "$channel"); then
        # Write complete playlist entry
        echo "#EXTINF:-1 tvg-id=\"${channel//[^a-zA-Z0-9-]/}\" tvg-logo=\"${logo:-https://i.imgur.com/TV.png}\",$channel" >> "$PLAYLIST_FILE"
        echo "$stream" >> "$PLAYLIST_FILE"
        echo "" >> "$PLAYLIST_FILE"  # Add blank line between entries
        ((success++))
    else
        echo "ERROR: Failed $channel" | tee -a "$LOG_FILE"
    fi
done

# Final validation
{
    echo ""
    echo "=== Validation ==="
    echo "Total Channels: $total"
    echo "Successful: $success"
    echo "Failed: $((total - success))"
    echo "Playlist Line Count: $(wc -l < "$PLAYLIST_FILE")"
    echo ""
    echo "First 5 entries:"
    head -n 10 "$PLAYLIST_FILE"
} | tee -a "$LOG_FILE"

[ "$success" -gt 0 ] || exit 1
exit 0
