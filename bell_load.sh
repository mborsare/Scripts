#!/bin/bash

# Bell Load Script - Opens URL in Arc browser
# Usage: bell_load.sh <URL>

URL="$1"

if [ -z "$URL" ]; then
    echo "Usage: $0 <URL>"
    exit 1
fi

# Open URL in Arc browser
open -a "Arc" "$URL"