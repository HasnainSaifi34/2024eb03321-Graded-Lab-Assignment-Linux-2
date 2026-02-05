#!/bin/bash

# metrics.sh - Text File Analysis Script
# Analyzes input.txt and displays word metrics

# Check if input.txt exists
if [ ! -f "input.txt" ]; then
    echo "Error: input.txt not found!"
    echo "Please create input.txt with some text content"
    exit 1
fi

echo "=========================================="
echo "Text File Metrics Analysis"
echo "=========================================="
echo "Analyzing file: input.txt"
echo ""

# Extract all words (convert to lowercase, one word per line)
# tr -cs removes non-alphabetic characters and splits into words
cat input.txt | tr -cs 'A-Za-z' '\n' | tr 'A-Z' 'a-z' | grep -v '^$' > /tmp/words_temp_$$.txt

# Check if any words were found
if [ ! -s /tmp/words_temp_$$.txt ]; then
    echo "Error: No words found in input.txt"
    rm -f /tmp/words_temp_$$.txt
    exit 1
fi

echo "=========================================="
echo "1. Longest Word"
echo "=========================================="
# Add length to each word, sort by length (descending), get first word
awk '{ print length, $0 }' /tmp/words_temp_$$.txt | sort -rn | head -1 | awk '{print $2 " (Length: " $1 " characters)"}'
echo ""

echo "=========================================="
echo "2. Shortest Word"
echo "=========================================="
# Add length to each word, sort by length (ascending), get first word
awk '{ print length, $0 }' /tmp/words_temp_$$.txt | sort -n | head -1 | awk '{print $2 " (Length: " $1 " characters)"}'
echo ""

echo "=========================================="
echo "3. Average Word Length"
echo "=========================================="
# Calculate total characters and total words, then divide
TOTAL_CHARS=$(awk '{ total += length } END { print total }' /tmp/words_temp_$$.txt)
TOTAL_WORDS=$(wc -l < /tmp/words_temp_$$.txt)
AVG_LENGTH=$(echo "scale=2; $TOTAL_CHARS / $TOTAL_WORDS" | bc)
echo "Average: $AVG_LENGTH characters"
echo "(Total characters: $TOTAL_CHARS / Total words: $TOTAL_WORDS)"
echo ""

echo "=========================================="
echo "4. Total Number of Unique Words"
echo "=========================================="
# Sort words and count unique ones
UNIQUE_COUNT=$(sort /tmp/words_temp_$$.txt | uniq | wc -l)
echo "Unique words: $UNIQUE_COUNT"
echo ""

# Additional statistics
echo "=========================================="
echo "Additional Statistics"
echo "=========================================="
echo "Total words (including duplicates): $TOTAL_WORDS"
echo "Duplicate words: $(($TOTAL_WORDS - $UNIQUE_COUNT))"
echo ""

# Show top 5 most frequent words
echo "Top 5 Most Frequent Words:"
sort /tmp/words_temp_$$.txt | uniq -c | sort -rn | head -5 | awk '{print "  " $2 " (" $1 " times)"}'
echo ""

# Cleanup temporary file
rm -f /tmp/words_temp_$$.txt

echo "=========================================="
echo "Analysis Complete!"
echo "=========================================="
