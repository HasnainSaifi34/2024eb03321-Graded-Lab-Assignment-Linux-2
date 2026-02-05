# Patterns.sh - Word Pattern Classification Script

## Overview
This bash script reads a text file and classifies words into three categories based on their vowel and consonant patterns, writing them to separate output files.

## Code Explanation

### 1. **Output File Initialization**
```bash
> vowels.txt
> consonants.txt
> mixed.txt
```
- Clears/creates the three output files to ensure they're empty before processing

### 2. **Input Validation**
```bash
if [ $# -eq 0 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Error: File '$1' not found"
    exit 1
fi
```
- Checks if an input file was provided as a command-line argument
- Verifies the input file exists

### 3. **Word Processing Loop**
```bash
while read -r line; do
    for word in $line; do
        # Processing logic
    done
done < "$1"
```
- Reads the input file line by line
- Iterates through each word in each line

### 4. **Word Cleaning**
```bash
clean_word=$(echo "$word" | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]')
```
- Removes punctuation marks from the word
- Converts the word to lowercase for pattern matching (case-insensitive checking)
- The original word (with original case) is written to output files

### 5. **Pattern Classification**

#### Only Vowels
```bash
if echo "$clean_word" | grep -q '^[aeiou]\+$'; then
    echo "$word" >> vowels.txt
```
- Matches words containing ONLY vowels (a, e, i, o, u)
- Examples: "a", "I", "eye", "aaa"

#### Only Consonants
```bash
elif echo "$clean_word" | grep -q '^[b-df-hj-np-tv-z]\+$'; then
    echo "$word" >> consonants.txt
```
- Matches words containing ONLY consonants (all letters except vowels)
- Examples: "by", "cry", "fly", "gym"

#### Mixed (Starts with Consonant)
```bash
elif echo "$clean_word" | grep -q '^[b-df-hj-np-tv-z]' && \
     echo "$clean_word" | grep -q '[aeiou]' && \
     echo "$clean_word" | grep -q '[b-df-hj-np-tv-z]'; then
    echo "$word" >> mixed.txt
```
- Matches words that:
  - Start with a consonant
  - Contain at least one vowel
  - Contain at least one consonant
- Examples: "hello", "World", "Script", "bash"

## Usage

```bash
chmod +x patterns.sh
./patterns.sh input.txt
```

## Expected Output

### Sample Input File (input.txt)
```
Hello World I love Bash scripting
A eye fly by the sky
Try my script
```

### Expected Output Files

**vowels.txt:**
```
I
A
eye
```

**consonants.txt:**
```
fly
by
Try
my
```

**mixed.txt:**
```
Hello
World
love
Bash
scripting
the
sky
script
```

## Key Features

1. **Case Insensitive**: Pattern matching ignores case (Hello and HELLO are treated the same)
2. **Preserves Original Format**: Output files contain words in their original case
3. **Punctuation Handling**: Punctuation is removed for pattern checking
4. **Three Categories**: Words are categorized into vowels-only, consonants-only, or mixed
5. **Consonant-First Rule**: Mixed words must start with a consonant

## Notes

- Words that start with vowels but contain both vowels and consonants are NOT written to any file
- Words containing non-alphabetic characters (after punctuation removal) may not match any pattern
- Empty words or words that are only punctuation are skipped
