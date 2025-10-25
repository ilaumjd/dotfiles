#!/bin/bash

# Specify the folder path (use . for current directory)
folder_path="."

# Counter for numbering
counter=1

# Loop through files in the folder, sorted alphabetically
for file in $(ls "$folder_path" | sort); do
    # Skip if it's a directory or .sh file
    if [ -d "$file" ] || [[ "$file" == *.sh ]]; then
        continue
    fi
    
    # Get file extension
    extension="${file##*.}"
    
    # Create new filename with padding zeros (01, 02, etc.)
    new_filename=$(printf "%02d.%s" $counter "$extension")
    
    # Rename file
    mv "$file" "$new_filename"
    echo "Renamed '$file' to '$new_filename'"
    
    # Increment counter
    ((counter++))
done

echo "Renaming complete!"
