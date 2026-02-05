# sync.sh - Directory Comparison Script Explanation

## Overview
The `sync.sh` script compares two directories (`dirA` and `dirB`) and identifies files that are unique to each directory, as well as files that exist in both directories with content comparison.

---

## Script Components Breakdown

### 1. Argument Validation
```bash
if [ $# -ne 2 ]; then
    echo "Usage: $0 <dirA> <dirB>"
    exit 1
fi
```
**Explanation:** This checks if exactly 2 arguments (directory paths) are provided when running the script. The special variable `$#` holds the number of arguments passed, and if it's not equal to 2, the script displays usage instructions and exits with error code 1.

---

### 2. Directory Existence Check
```bash
if [ ! -d "$DIRA" ]; then
    echo "Error: Directory '$DIRA' does not exist!"
    exit 1
fi
```
**Explanation:** This verifies that both directories exist before attempting comparison using the `-d` test operator. If either directory doesn't exist, the script exits with an error message to prevent file operation errors.

---

### 3. File List Generation
```bash
TEMP_DIRA=$(mktemp)
TEMP_DIRB=$(mktemp)
ls -1 "$DIRA" 2>/dev/null | sort > "$TEMP_DIRA"
ls -1 "$DIRB" 2>/dev/null | sort > "$TEMP_DIRB"
```
**Explanation:** Creates temporary files using `mktemp` to store sorted lists of filenames from each directory. The `ls -1` command lists files one per line, piped to `sort` for alphabetical ordering, then redirected to temporary files for comparison. The `2>/dev/null` suppresses error messages.

---

### 4. Finding Files Only in dirA
```bash
ONLY_IN_A=$(comm -23 "$TEMP_DIRA" "$TEMP_DIRB")
```
**Explanation:** The `comm` command compares two sorted files line by line. The `-23` option suppresses columns 2 and 3, showing only lines unique to the first file (dirA). This identifies files present only in dirA.

**comm output columns:**
- Column 1: Lines only in file1
- Column 2: Lines only in file2  
- Column 3: Lines in both files

---

### 5. Finding Files Only in dirB
```bash
ONLY_IN_B=$(comm -13 "$TEMP_DIRA" "$TEMP_DIRB")
```
**Explanation:** Using `comm -13` suppresses columns 1 and 3, showing only lines unique to the second file (dirB). This identifies files present only in dirB, complementing the previous check.

---

### 6. Finding Common Files
```bash
COMMON_FILES=$(comm -12 "$TEMP_DIRA" "$TEMP_DIRB")
```
**Explanation:** Using `comm -12` suppresses columns 1 and 2, showing only column 3 which contains lines present in both files. This gives us the list of filenames that exist in both directories for content comparison.

---

### 7. Content Comparison Using cmp
```bash
if cmp -s "$FILE_A" "$FILE_B"; then
    echo "  ✓ $file - IDENTICAL"
else
    echo "  ✗ $file - DIFFERENT"
fi
```
**Explanation:** The `cmp` command performs byte-by-byte comparison of two files. The `-s` flag makes it silent (no output), returning exit code 0 if files are identical, non-zero if different. This is faster than `diff` for simple equality checks as it stops at the first difference.

---

## Commands Used Summary

| Command | Purpose | Options Used |
|---------|---------|--------------|
| `comm` | Compare sorted files line by line | `-12`, `-13`, `-23` (suppress columns) |
| `cmp` | Byte-by-byte file comparison | `-s` (silent mode) |
| `ls` | List directory contents | `-1` (one file per line) |
| `sort` | Sort lines alphabetically | None (default) |
| `mktemp` | Create temporary files | None (generates unique names) |
| `grep` | Count lines for summary | `-c` (count matches) |

---

## Testing Setup

### Step 1: Create Test Directories and Files

```bash
# Create directories
mkdir -p dirA dirB

# Files in both directories (identical content)
echo "Hello World" > dirA/common1.txt
echo "Hello World" > dirB/common1.txt

# Files in both directories (different content)
echo "Version A" > dirA/common2.txt
echo "Version B" > dirB/common2.txt

# Files only in dirA
echo "Only in A" > dirA/unique_a.txt
echo "Another A" > dirA/file_a.txt

# Files only in dirB
echo "Only in B" > dirB/unique_b.txt
echo "Another B" > dirB/file_b.txt
```

### Step 2: Make Script Executable
```bash
chmod +x sync.sh
```

### Step 3: Run the Script
```bash
./sync.sh dirA dirB
```

---

## Expected Output

```
==========================================
Directory Synchronization Checker
==========================================
Comparing: dirA <-> dirB

==========================================
1. Files Present ONLY in dirA
==========================================
  - file_a.txt
  - unique_a.txt

==========================================
2. Files Present ONLY in dirB
==========================================
  - file_b.txt
  - unique_b.txt

==========================================
3. Common Files - Content Comparison
==========================================
  ✓ common1.txt - IDENTICAL
  ✗ common2.txt - DIFFERENT
    (Use 'diff dirA/common2.txt dirB/common2.txt' to see differences)

==========================================
Summary Report
==========================================
Files only in dirA: 2
Files only in dirB: 2
Common files: 2
  - Identical: 1
  - Different: 1

==========================================
Comparison Complete!
==========================================
```

---

## Key Features

### 1. **Non-Destructive**
- Only reads and compares files
- Does NOT copy, move, or modify any files
- Safe to run on production directories

### 2. **Efficient Comparison**
- Uses `comm` for quick filename comparison
- Uses `cmp` for fast byte-level content comparison
- Temporary files cleaned up automatically

### 3. **Clear Reporting**
- Visual indicators (✓ for identical, ✗ for different)
- Organized sections for each type of difference
- Summary statistics at the end

### 4. **Error Handling**
- Validates directory existence
- Checks argument count
- Skips subdirectories in comparison

---

## Alternative Comparison Methods

### Method 1: Using diff
```bash
diff "$FILE_A" "$FILE_B" > /dev/null 2>&1
```
- Shows what changed (useful for text files)
- Slower than `cmp` for binary files
- Good for detailed change analysis

### Method 2: Using Checksums (md5sum)
```bash
MD5_A=$(md5sum "$FILE_A" | cut -d' ' -f1)
MD5_B=$(md5sum "$FILE_B" | cut -d' ' -f1)
if [ "$MD5_A" = "$MD5_B" ]; then
    echo "IDENTICAL"
fi
```
- Creates hash of file contents
- Can compare files without reading entire content
- Useful for large files or network comparisons

### Method 3: Using sha256sum
```bash
SHA_A=$(sha256sum "$FILE_A" | cut -d' ' -f1)
SHA_B=$(sha256sum "$FILE_B" | cut -d' ' -f1)
```
- More secure hash algorithm than MD5
- Better for cryptographic verification
- Slightly slower but more collision-resistant

---

## Use Cases

1. **Backup Verification**: Check if backup directory matches source
2. **Code Deployment**: Verify files deployed to server match local files
3. **Version Control**: Compare working directory with repository
4. **Data Migration**: Ensure all files transferred correctly
5. **Configuration Management**: Track changes between environments

---

## Troubleshooting

**Problem**: "Permission denied" errors
- **Solution**: Ensure you have read permissions on both directories
- **Command**: `chmod +r dirA/* dirB/*`

**Problem**: Subdirectories cause issues
- **Solution**: Script already skips directories, compares only files
- **Enhancement**: Use `find` command for recursive comparison

**Problem**: Special characters in filenames
- **Solution**: Script uses quotes around variables to handle spaces

**Problem**: Large number of files slow
- **Solution**: Script uses efficient `comm` and `cmp` commands
- **Alternative**: Add progress indicators for large directories

---

## Summary

This script demonstrates:
1. **File comparison techniques** using `comm` and `cmp`
2. **Temporary file management** with `mktemp`
3. **Conditional logic** for different comparison scenarios
4. **Error handling** for invalid inputs
5. **Output formatting** for clear results presentation

The modular design makes it easy to extend with additional features like recursive directory comparison, file size comparison, or timestamp checking.
