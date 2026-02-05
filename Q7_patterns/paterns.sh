#!/bin/bash

# Clear output files if they exist
> vowels.txt
> consonants.txt
> mixed.txt

# Check if input file is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

# Check if input file exists
if [ ! -f "$1" ]; then
    echo "Error: File '$1' not found"
    exit 1
fi

# Read the input file word by word
while read -r line; do
    # Split line into words
    for word in $line; do
        # Remove punctuation and convert to lowercase for checking
        clean_word=$(echo "$word" | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]')
        
        # Skip empty words
        if [ -z "$clean_word" ]; then
            continue
        fi
        
        # Check if word contains only vowels (a, e, i, o, u)
        if echo "$clean_word" | grep -q '^[aeiou]\+$'; then
            echo "$word" >> vowels.txt
        # Check if word contains only consonants (not vowels)
        elif echo "$clean_word" | grep -q '^[b-df-hj-np-tv-z]\+$'; then
            echo "$word" >> consonants.txt
        # Check if word contains both vowels and consonants and starts with a consonant
        elif echo "$clean_word" | grep -q '^[b-df-hj-np-tv-z]' && \
             echo "$clean_word" | grep -q '[aeiou]' && \
             echo "$clean_word" | grep -q '[b-df-hj-np-tv-z]'; then
            echo "$word" >> mixed.txt
        fi
    done
done < "$1"

echo "Processing complete!"
echo "Results written to vowels.txt, consonants.txt, and mixed.txt"

# this is optional printing the vowels consonants and mixed
echo "|---Vowels---|"
cat vowels.txt

echo "|---consonants---|"
cat consonants.txt

echo "|---mixed---|"
cat mixed.txt

