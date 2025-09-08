#!/bin/bash
# find_media_files.sh
# Scans for image and video files, logs inaccessible directories

DIR_TO_SCAN="${1:-$HOME}"

OUTPUT_IMAGES="$HOME/image_files_list.txt"
OUTPUT_VIDEOS="$HOME/video_files_list.txt"
OUTPUT_SKIPPED="$HOME/skipped_dirs.txt"

echo "Scanning directory: $DIR_TO_SCAN"

# Clear previous output files
> "$OUTPUT_IMAGES"
> "$OUTPUT_VIDEOS"
> "$OUTPUT_SKIPPED"

# Function to scan directories safely
scan_dir() {
    local dir="$1"

    # Try to read the directory
    if [[ ! -r "$dir" ]]; then
        echo "$dir" >> "$OUTPUT_SKIPPED"
        return
    fi

    # Find images
    find "$dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.bmp' \) 2>/dev/null >> "$OUTPUT_IMAGES"

    # Find videos
    find "$dir" -type f \( -iname '*.mp4' -o -iname '*.mkv' -o -iname '*.avi' -o -iname '*.mov' -o -iname '*.webm' \) 2>/dev/null >> "$OUTPUT_VIDEOS"
}

# Recursively walk directories safely
while IFS= read -r -d '' subdir; do
    scan_dir "$subdir"
done < <(find "$DIR_TO_SCAN" -type d -print0 2>/dev/null)

echo "Scan complete."
echo "Images: $OUTPUT_IMAGES"
echo "Videos: $OUTPUT_VIDEOS"
echo "Skipped directories: $OUTPUT_SKIPPED"
