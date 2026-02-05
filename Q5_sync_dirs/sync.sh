#!/bin/bash

# sync.sh - Directory Comparison Script
# Compares two directories and reports differences without modifying files

# Check if both directory arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <dirA> <dirB>"
    echo "Example: $0 dirA dirB"
    exit 1
fi

DIRA="$1"
DIRB="$2"

# Check if both directories exist
if [ ! -d "$DIRA" ]; then
    echo "Error: Directory '$DIRA' does not exist!"
    exit 1
fi

if [ ! -d "$DIRB" ]; then
    echo "Error: Directory '$DIRB' does not exist!"
    exit 1
fi

echo "=========================================="
echo "Directory Synchronization Checker"
echo "=========================================="
echo "Comparing: $DIRA <-> $DIRB"
echo ""

# Create temporary files to store file lists
TEMP_DIRA=$(mktemp)
TEMP_DIRB=$(mktemp)

# Get list of files in each directory (only files, not subdirectories)
ls -1 "$DIRA" 2>/dev/null | sort > "$TEMP_DIRA"
ls -1 "$DIRB" 2>/dev/null | sort > "$TEMP_DIRB"

echo "=========================================="
echo "1. Files Present ONLY in $DIRA"
echo "=========================================="
ONLY_IN_A=$(comm -23 "$TEMP_DIRA" "$TEMP_DIRB")
if [ -z "$ONLY_IN_A" ]; then
    echo "  (No files unique to $DIRA)"
else
    echo "$ONLY_IN_A" | while read -r file; do
        echo "  - $file"
    done
fi
echo ""

echo "=========================================="
echo "2. Files Present ONLY in $DIRB"
echo "=========================================="
ONLY_IN_B=$(comm -13 "$TEMP_DIRA" "$TEMP_DIRB")
if [ -z "$ONLY_IN_B" ]; then
    echo "  (No files unique to $DIRB)"
else
    echo "$ONLY_IN_B" | while read -r file; do
        echo "  - $file"
    done
fi
echo ""

echo "=========================================="
echo "3. Common Files - Content Comparison"
echo "=========================================="
COMMON_FILES=$(comm -12 "$TEMP_DIRA" "$TEMP_DIRB")

if [ -z "$COMMON_FILES" ]; then
    echo "  (No common files found)"
else
    echo "$COMMON_FILES" | while read -r file; do
        FILE_A="$DIRA/$file"
        FILE_B="$DIRB/$file"
        
        # Skip if either is a directory
        if [ -d "$FILE_A" ] || [ -d "$FILE_B" ]; then
            continue
        fi
        
        # Compare files using cmp (byte-by-byte comparison)
        if cmp -s "$FILE_A" "$FILE_B"; then
            echo "  ✓ $file - IDENTICAL"
        else
            echo "  ✗ $file - DIFFERENT"
            # Show brief diff summary
            echo "    (Use 'diff $FILE_A $FILE_B' to see differences)"
        fi
    done
fi
echo ""

echo "=========================================="
echo "Summary Report"
echo "=========================================="
COUNT_ONLY_A=$(echo "$ONLY_IN_A" | grep -c "^" 2>/dev/null || echo 0)
COUNT_ONLY_B=$(echo "$ONLY_IN_B" | grep -c "^" 2>/dev/null || echo 0)
COUNT_COMMON=$(echo "$COMMON_FILES" | grep -c "^" 2>/dev/null || echo 0)

# Count identical and different files
IDENTICAL=0
DIFFERENT=0

if [ -n "$COMMON_FILES" ]; then
    echo "$COMMON_FILES" | while read -r file; do
        FILE_A="$DIRA/$file"
        FILE_B="$DIRB/$file"
        
        if [ -f "$FILE_A" ] && [ -f "$FILE_B" ]; then
            if cmp -s "$FILE_A" "$FILE_B"; then
                echo "IDENTICAL" >> /tmp/sync_identical_$$
            else
                echo "DIFFERENT" >> /tmp/sync_different_$$
            fi
        fi
    done
    
    IDENTICAL=$(wc -l < /tmp/sync_identical_$$ 2>/dev/null || echo 0)
    DIFFERENT=$(wc -l < /tmp/sync_different_$$ 2>/dev/null || echo 0)
    rm -f /tmp/sync_identical_$$ /tmp/sync_different_$$
fi

echo "Files only in $DIRA: $COUNT_ONLY_A"
echo "Files only in $DIRB: $COUNT_ONLY_B"
echo "Common files: $COUNT_COMMON"
echo "  - Identical: $IDENTICAL"
echo "  - Different: $DIFFERENT"
echo ""

# Cleanup temporary files
rm -f "$TEMP_DIRA" "$TEMP_DIRB"

echo "=========================================="
echo "Comparison Complete!"
echo "=========================================="
