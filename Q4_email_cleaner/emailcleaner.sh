#!/bin/bash

# emailcleaner.sh - Email Address Processor
# This script extracts valid and invalid email addresses from emails.txt

# Check if emails.txt exists
if [ ! -f "emails.txt" ]; then
    echo "Error: emails.txt not found!"
    echo "Please create emails.txt with email addresses (one per line)"
    exit 1
fi

# Define valid email pattern: <letters_and_digits>@<letters>.com
VALID_PATTERN='^[a-zA-Z0-9]+@[a-zA-Z]+\.com$'

echo "=========================================="
echo "Email Cleaner Script - Starting..."
echo "=========================================="
echo ""

# Step 1: Extract valid email addresses
echo "Step 1: Extracting valid email addresses..."
grep -E "${VALID_PATTERN}" emails.txt > valid_temp.txt
echo "Valid emails found: $(wc -l < valid_temp.txt)"
echo ""

# Step 2: Remove duplicates from valid emails and save to valid.txt
echo "Step 2: Removing duplicates from valid emails..."
sort valid_temp.txt | uniq > valid.txt
echo "Unique valid emails: $(wc -l < valid.txt)"
echo ""

# Step 3: Extract invalid email addresses
echo "Step 3: Extracting invalid email addresses..."
grep -v -E "${VALID_PATTERN}" emails.txt > invalid.txt
echo "Invalid emails found: $(wc -l < invalid.txt)"
echo ""

# Clean up temporary file
rm -f valid_temp.txt

# Display results
echo "=========================================="
echo "Processing Complete!"
echo "=========================================="
echo ""
echo "Results:"
echo "--------"
echo "Valid emails (duplicates removed): $(wc -l < valid.txt)"
echo "Invalid emails: $(wc -l < invalid.txt)"
echo ""
echo "Output files created:"
echo "  - valid.txt   (valid unique email addresses)"
echo "  - invalid.txt (invalid email addresses)"
echo ""

# Optional: Display sample outputs
if [ -s valid.txt ]; then
    echo "Sample valid emails (first 5):"
    head -5 valid.txt
    echo ""
fi

if [ -s invalid.txt ]; then
    echo "Sample invalid emails (first 5):"
    head -5 invalid.txt
    echo ""
fi

echo "=========================================="