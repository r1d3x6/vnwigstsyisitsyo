#!/bin/bash

# Debug information
echo "Starting script at $(date)"
echo "Current directory: $(pwd)"
echo "Files in directory:"
ls -la

# Configuration
PLAYLIST_FILE="youtube_iptv.m3u"
LOG_FILE="generator.log"
TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')

# Initialize files
echo "#EXTM3U" > "$PLAYLIST_FILE"
echo "# Generated: $TIMESTAMP" >> "$PLAYLIST_FILE"
echo "Playlist generation started at $TIMESTAMP" > "$LOG_FILE"

# Channel configuration
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

echo "Generating playlist..."

# Process each channel
for channel in "${!channels[@]}"; do
    IFS='|' read -r url logo_url <<< "${channels[$channel]}"
    
    echo "Processing: $channel" | tee -a "$LOG_FILE"
    echo "URL: $url" >> "$LOG_FILE"
    
    # Get stream URL with timeout
    stream_url=$(timeout 30 yt-dlp -g --format "best[height<=720]" "$url" 2>> "$LOG_FILE")
    
    if [ -n "$stream_url" ]; then
        # Use default logo if not specified
        [ -z "$logo_url" ] && logo_url="https://i.imgur.com/TV.png"
        
        echo "#EXTINF:-1 tvg-id=\"${channel// /-}\" tvg-logo=\"$logo_url\" group-title=\"YouTube\",$channel" >> "$PLAYLIST_FILE"
        echo "$stream_url" >> "$PLAYLIST_FILE"
        echo "Success: Added $channel" >> "$LOG_FILE"
    else
        echo "ERROR: Failed to fetch stream for $channel" >> "$LOG_FILE"
    fi
done

# Final status
total_channels=${#channels[@]}
success_count=$(grep -c "Success:" "$LOG_FILE")

echo "Generation completed at $(date)" | tee -a "$LOG_FILE"
echo "Total channels: $total_channels" | tee -a "$LOG_FILE"
echo "Successfully added: $success_count" | tee -a "$LOG_FILE"
echo "Failed: $((total_channels - success_count))" | tee -a "$LOG_FILE"

# Output the first few lines for verification
echo "Playlist preview:"
head -n 10 "$PLAYLIST_FILE"

# Exit with error if all channels failed
[ "$success_count" -eq 0 ] && exit 1
exit 0
