#!/bin/bash

# Define channels with logos (Format: "Channel Name"="YouTube URL|Logo URL")
declare -A channels=(
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
       ["24/7 Mr bean"]="https://m.youtube.com/live/amzgpxDsJjQ|https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQRdE8B6TfR8VPk_FyFC98t97So4oPnEkYmJtH_gJHYiTeMT0A2KNmoIJI&s=10"
    # Add more channels with logos...
)

PLAYLIST="/storage/emulated/0/r1d3x6/YOUTUBE/youtube_iptv.m3u"
echo "#EXTM3U" > "$PLAYLIST"

for channel in "${!channels[@]}"; do
    IFS='|' read -r url logo_url <<< "${channels[$channel]}"
    echo "Updating: $channel..."
    
    stream_url=$(yt-dlp -g --format "best[height<=720]" "$url" 2>/dev/null)
    
    if [ -n "$stream_url" ]; then
        echo "#EXTINF:-1 tvg-id=\"$channel\" tvg-logo=\"$logo_url\" group-title=\"YouTube\",$channel" >> "$PLAYLIST"
        echo "$stream_url" >> "$PLAYLIST"
    else
        echo "ERROR: Could not fetch $channel"
    fi
done

echo "Playlist updated: $PLAYLIST"
