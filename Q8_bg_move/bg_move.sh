#!/bin/bash

# Check if directory path is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

# Store the directory path
DIR_PATH="$1"

# Check if directory exists
if [ ! -d "$DIR_PATH" ]; then
    echo "Error: Directory '$DIR_PATH' does not exist"
    exit 1
fi

#Directory before executing
echo "Directory Before Executing"
tree $DIR_PATH

# Create backup directory if it doesn't exist
BACKUP_DIR="$DIR_PATH/backup"
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    echo "Created backup directory: $BACKUP_DIR"
fi

echo "Starting file movement operations..."
echo "Main script PID: $$"
echo ""

# Array to store background process PIDs
pids=()

# Loop through all files in the directory (excluding backup directory)
for file in "$DIR_PATH"/*; do
    # Skip if it's the backup directory itself
    if [ "$file" = "$BACKUP_DIR" ]; then
        continue
    fi
    
    # Skip if it's not a file (e.g., subdirectories)
    if [ ! -f "$file" ]; then
        continue
    fi
    
    # Get the filename
    filename=$(basename "$file")
    
    # Move file in background
    (
        mv "$file" "$BACKUP_DIR/"
        echo "Moved: $filename (by process $BASHPID)"
    ) &
    
    # Store the PID of the background process
    pids+=($!)
    echo "Background process started: PID = $! for file '$filename'"
done

# Check if any files were processed
if [ ${#pids[@]} -eq 0 ]; then
    echo "No files found to move in directory: $DIR_PATH"
    exit 0
fi

echo ""
echo "Waiting for all background processes to finish..."
echo "Total background processes: ${#pids[@]}"
echo ""

# Wait for all background processes to complete
wait

echo ""
echo "All background processes completed!"
echo "All files have been moved to: $BACKUP_DIR"

# Directory after executing 
echo "Directory After Executing"
tree $DIR_PATH
