#!/bin/bash

# analyze.sh - Script to analyze files and directories
# Accepts exactly ONE command-line argument

# Check if exactly one argument is provided
if [ $# -ne 1 ]; then
    echo "Error: Invalid number of arguments."
    echo "Usage: $0 <file_or_directory_path>"
    exit 1
fi

# Store the argument
path="$1"

# Check if the path exists
if [ ! -e "$path" ]; then
    echo "Error: Path '$path' does not exist."
    exit 1
fi

# Check if the argument is a file
if [ -f "$path" ]; then
    echo "Analyzing file: $path"
    echo "-----------------------------------"
    
    # Display number of lines, words, and characters
    lines=$(wc -l < "$path")
    words=$(wc -w < "$path")
    chars=$(wc -m < "$path")
    
    echo "Number of lines: $lines"
    echo "Number of words: $words"
    echo "Number of characters: $chars"
    
# Check if the argument is a directory
elif [ -d "$path" ]; then
    echo "Analyzing directory: $path"
    echo "-----------------------------------"
    
    # Count total number of files (excluding directories)
    total_files=$(find "$path" -type f | wc -l)
    
    # Count number of .txt files
    txt_files=$(find "$path" -type f -name "*.txt" | wc -l)
    
    echo "Total number of files: $total_files"
    echo "Number of .txt files: $txt_files"
    
else
    echo "Error: '$path' is neither a regular file nor a directory."
    exit 1
fi

exit 0
