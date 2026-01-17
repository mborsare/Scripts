#!/bin/bash

# Bell Show Script - Opens URL in Arc browser and brings it to front
# Usage: bell_show.sh <URL>

URL="$1"

if [ -z "$URL" ]; then
    echo "Usage: $0 <URL>"
    exit 1
fi

# Open URL in Arc browser and bring to front
open -a "Arc" "$URL"

# Bring Arc to front (may need to wait a moment for Arc to load)
sleep 2
osascript -e 'tell application "Arc" to activate'