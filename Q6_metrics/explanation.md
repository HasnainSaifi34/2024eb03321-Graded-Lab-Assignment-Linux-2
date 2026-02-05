# metrics.sh - Text File Analysis Script Explanation

## Overview
The `metrics.sh` script analyzes a text file (`input.txt`) and calculates various word-based metrics including longest word, shortest word, average word length, and total unique words.

---

## Script Components Breakdown

### 1. File Existence Check
```bash
if [ ! -f "input.txt" ]; then
    echo "Error: input.txt not found!"
    exit 1
fi
```
**Explanation:** This validates that `input.txt` exists before processing. The `-f` test checks for a regular file, and if it doesn't exist, the script exits with an error message to prevent subsequent commands from failing.

---

### 2. Word Extraction Pipeline
```bash
cat input.txt | tr -cs 'A-Za-z' '\n' | tr 'A-Z' 'a-z' | grep -v '^$' > /tmp/words_temp_$$.txt
```
**Explanation:** This pipeline extracts and normalizes all words from the input file through several transformations.

**Step-by-step breakdown:**
1. `cat input.txt` - Reads the file content
2. `tr -cs 'A-Za-z' '\n'` - Converts non-alphabetic characters to newlines, creating one word per line
   - `-c` - Complement (everything NOT in A-Za-z)
   - `-s` - Squeeze repeats (multiple spaces become one newline)
3. `tr 'A-Z' 'a-z'` - Converts all uppercase letters to lowercase for consistent comparison
4. `grep -v '^$'` - Removes empty lines
5. `> /tmp/words_temp_$$.txt` - Saves to temporary file (using `$$` for unique process ID)

---

### 3. Finding the Longest Word
```bash
awk '{ print length, $0 }' /tmp/words_temp_$$.txt | sort -rn | head -1 | awk '{print $2 " (Length: " $1 " characters)"}'
```
**Explanation:** This pipeline calculates word lengths, sorts them, and extracts the longest word.

**Pipeline breakdown:**
1. `awk '{ print length, $0 }'` - Prepends each word with its character count (e.g., "5 hello")
2. `sort -rn` - Sorts numerically in reverse order (longest first)
   - `-r` - Reverse order
   - `-n` - Numeric sort
3. `head -1` - Takes the first line (longest word)
4. `awk '{print $2 " (Length: " $1 " characters)"}'` - Formats the output nicely

---

### 4. Finding the Shortest Word
```bash
awk '{ print length, $0 }' /tmp/words_temp_$$.txt | sort -n | head -1 | awk '{print $2 " (Length: " $1 " characters)"}'
```
**Explanation:** Similar to finding the longest word, but uses `sort -n` (ascending order) instead of `sort -rn` to get the shortest word first. This efficiently identifies the minimum length word in the file.

---

### 5. Calculating Average Word Length
```bash
TOTAL_CHARS=$(awk '{ total += length } END { print total }' /tmp/words_temp_$$.txt)
TOTAL_WORDS=$(wc -l < /tmp/words_temp_$$.txt)
AVG_LENGTH=$(echo "scale=2; $TOTAL_CHARS / $TOTAL_WORDS" | bc)
```
**Explanation:** This calculates the average by dividing total characters by total words.

**Component breakdown:**
1. `awk '{ total += length } END { print total }'` - Sums the length of all words
   - Accumulates length in `total` variable
   - `END` block prints the final sum
2. `wc -l < /tmp/words_temp_$$.txt` - Counts total words (lines in file)
3. `echo "scale=2; $TOTAL_CHARS / $TOTAL_WORDS" | bc` - Performs division with 2 decimal places
   - `scale=2` - Sets precision to 2 decimal places
   - `bc` - Command-line calculator for floating-point arithmetic

---

### 6. Counting Unique Words
```bash
UNIQUE_COUNT=$(sort /tmp/words_temp_$$.txt | uniq | wc -l)
```
**Explanation:** This pipeline sorts words alphabetically, removes consecutive duplicates, and counts the remaining unique words.

**Pipeline breakdown:**
1. `sort` - Sorts words alphabetically (brings duplicates together)
2. `uniq` - Removes consecutive duplicate lines (requires sorted input)
3. `wc -l` - Counts the number of unique words remaining

---

### 7. Top Frequent Words (Bonus)
```bash
sort /tmp/words_temp_$$.txt | uniq -c | sort -rn | head -5
```
**Explanation:** This identifies the most frequently occurring words in the text.

**Pipeline breakdown:**
1. `sort` - Groups identical words together
2. `uniq -c` - Counts occurrences of each unique word
   - `-c` - Prefix lines with count
3. `sort -rn` - Sorts by count (highest first)
4. `head -5` - Takes top 5 results

---

## Commands Used Summary

| Command | Purpose | Options Used |
|---------|---------|--------------|
| `tr` | Translate or delete characters | `-c` (complement), `-s` (squeeze) |
| `sort` | Sort lines of text | `-n` (numeric), `-r` (reverse) |
| `uniq` | Remove duplicate adjacent lines | `-c` (count occurrences) |
| `wc` | Count words, lines, characters | `-l` (count lines) |
| `awk` | Text processing and pattern matching | `length`, `print`, `END` |
| `grep` | Search for patterns | `-v` (invert match) |
| `bc` | Command-line calculator | Used via pipe |
| `head` | Output first part of files | `-1`, `-5` (first N lines) |

---

## Testing Setup

### Step 1: Create Sample input.txt

```bash
cat > input.txt << 'EOF'
The quick brown fox jumps over the lazy dog.
This is a simple test file to demonstrate the text analysis script.
The word "the" appears multiple times in this text.
Programming is fun and challenging. Programming requires practice.
Short words: a, I, to, it, is.
Longer words: demonstration, extraordinary, implementation.
EOF
```

### Step 2: Make Script Executable
```bash
chmod +x metrics.sh
```

### Step 3: Run the Script
```bash
./metrics.sh
```

---

## Expected Output

```
==========================================
Text File Metrics Analysis
==========================================
Analyzing file: input.txt

==========================================
1. Longest Word
==========================================
implementation (Length: 14 characters)

==========================================
2. Shortest Word
==========================================
a (Length: 1 characters)

==========================================
3. Average Word Length
==========================================
Average: 4.82 characters
(Total characters: 241 / Total words: 50)

==========================================
4. Total Number of Unique Words
==========================================
Unique words: 38

==========================================
Additional Statistics
==========================================
Total words (including duplicates): 50
Duplicate words: 12

Top 5 Most Frequent Words:
  the (5 times)
  is (3 times)
  to (2 times)
  this (2 times)
  text (2 times)

==========================================
Analysis Complete!
==========================================
```

---

## Pipeline Techniques Demonstrated

### 1. Character Transformation
```bash
tr -cs 'A-Za-z' '\n'
```
- Converts all non-letter characters to newlines
- Effectively splits text into words

### 2. Case Normalization
```bash
tr 'A-Z' 'a-z'
```
- Ensures "The" and "the" are counted as the same word

### 3. Filtering Empty Lines
```bash
grep -v '^$'
```
- Removes blank lines that might interfere with counting
- `^$` matches lines with nothing between start and end

### 4. Length Calculation with awk
```bash
awk '{ print length, $0 }'
```
- `length` function returns character count
- `$0` represents the entire line

### 5. Numerical Sorting
```bash
sort -rn
```
- Critical for finding max/min values
- `-n` treats numbers as numbers, not strings

---

## Use Cases

1. **Content Analysis**: Analyze writing complexity by word length
2. **SEO Optimization**: Find keyword frequency in web content
3. **Academic Writing**: Check vocabulary diversity (unique word ratio)
4. **Data Cleaning**: Identify most common terms in datasets
5. **Language Learning**: Analyze text difficulty based on word statistics

---

## Alternative Approaches

### Using grep for word extraction
```bash
grep -oE '\w+' input.txt | tr 'A-Z' 'a-z'
```
- `-o` - Print only matched parts
- `-E` - Extended regex
- `\w+` - One or more word characters

### Using sed for preprocessing
```bash
sed 's/[^a-zA-Z]/\n/g' input.txt | tr 'A-Z' 'a-z'
```
- Replaces non-letters with newlines

### Using perl for complex analysis
```bash
perl -ne 'print lc($_) =~ /(\w+)/g' input.txt
```
- More powerful for complex text processing

---

## Troubleshooting

**Problem**: "bc: command not found"
- **Solution**: Install bc calculator: `sudo apt-get install bc`

**Problem**: No words detected
- **Solution**: Check that input.txt contains actual text, not just numbers/symbols

**Problem**: Incorrect average calculation
- **Solution**: Ensure bc is installed for floating-point division

**Problem**: Special characters in words
- **Solution**: Adjust the `tr -cs 'A-Za-z'` to include characters like apostrophes if needed

---

## Enhancements

### Add Word Length Distribution
```bash
awk '{ print length }' /tmp/words_temp_$$.txt | sort -n | uniq -c
```
Shows how many words of each length exist

### Filter by Minimum Length
```bash
awk 'length >= 5' /tmp/words_temp_$$.txt
```
Only analyze words 5+ characters long

### Case-Sensitive Analysis
```bash
cat input.txt | tr -cs 'A-Za-z' '\n' | grep -v '^$'
```
Remove the lowercase conversion to keep original case

---

## Summary

This script demonstrates essential Linux text processing skills:
1. **tr** - Character translation and deletion for text normalization
2. **sort** - Organizing data for further processing
3. **uniq** - Identifying and counting duplicates
4. **wc** - Counting lines, words, and characters
5. **awk** - Pattern matching and arithmetic operations
6. **Pipes** - Chaining commands for efficient data flow

The combination of these tools creates a powerful text analysis pipeline that can process files of any size efficiently.
