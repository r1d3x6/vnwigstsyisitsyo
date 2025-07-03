#!/bin/bash

# Configuration
REPO_URL="https://github.com/yourusername/your-repo.git"
WORK_DIR="/tmp/iptv_generator"
PLAYLIST_FILE="youtube_iptv.m3u"
COMMIT_MSG="Auto-update playlist $(date +'%Y-%m-%d %H:%M:%S')"

# Define channels (same as your original)
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

# Setup working directory
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR" || exit 1

# Clone the repository
git clone "$REPO_URL" .
git config user.name "GitHub Actions"
git config user.email "actions@github.com"

# Generate playlist
echo "#EXTM3U" > "$PLAYLIST_FILE"

for channel in "${!channels[@]}"; do
    IFS='|' read -r url logo_url <<< "${channels[$channel]}"
    echo "Updating: $channel..."
    
    stream_url=$(yt-dlp -g --format "best[height<=720]" "$url" 2>/dev/null)
    
    if [ -n "$stream_url" ]; then
        echo "#EXTINF:-1 tvg-id=\"$channel\" tvg-logo=\"$logo_url\" group-title=\"YouTube\",$channel" >> "$PLAYLIST_FILE"
        echo "$stream_url" >> "$PLAYLIST_FILE"
    else
        echo "ERROR: Could not fetch $channel" >> errors.log
    fi
done

# Commit and push changes
git add "$PLAYLIST_FILE"
git commit -m "$COMMIT_MSG"
git push origin main
