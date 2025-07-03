#!/bin/bash

# Define YouTube channels
declare -A channels=(
    ["Jamuna TV"]="https://www.youtube.com/watch?v=yDzvLqfQhyM"
    ["Somoy TV"]="https://www.youtube.com/watch?v=OJVLgmpnk4U"
    ["Ekattor TV"]="https://www.youtube.com/watch?v=Byw9GNvDz8A"
    ["Channel 24"]="https://www.youtube.com/watch?v=HjZ48tDFjZU"
    ["Independent TV"]="https://www.youtube.com/watch?v=wuUhC6jfqrY"
    ["Sky News"]="https://www.youtube.com/watch?v=YDvsBbKfLPA"
    ["Arirang TV"]="https://www.youtube.com/watch?v=CJVBX7KI5nU"
    ["YTN"]="https://www.youtube.com/watch?v=xfFa_kcPnCY"
    ["Aljazeera English"]="https://www.youtube.com/watch?v=gCNeDWCI0vo"
    ["ANN NEWS CH"]="https://www.youtube.com/watch?v=coYw-eVU0Ks"
    ["GEO News"]="https://www.youtube.com/watch?v=O3DPVlynUM0"
    ["Alquran Alkareem"]="https://www.youtube.com/watch?v=-BlZnoDjxmM"
)

PLAYLIST="/storage/emulated/0/r1d3x6/YOUTUBE/youtube_iptv.m3u"
echo "#EXTM3U" > "$PLAYLIST"

for channel in "${!channels[@]}"; do
    url="${channels[$channel]}"
    echo "Updating: $channel..."
    
    stream_url=$(yt-dlp -g --format "best[height<=720]" "$url" 2>/dev/null)
    
    if [ -n "$stream_url" ]; then
        echo "#EXTINF:-1 tvg-id=\"$channel\" tvg-logo=\"https://logo.clearbit.com/youtube.com\" group-title=\"YouTube\",$channel" >> "$PLAYLIST"
        echo "$stream_url" >> "$PLAYLIST"
    else
        echo "ERROR: Could not fetch $channel"
    fi
done

echo "Playlist updated: $PLAYLIST
