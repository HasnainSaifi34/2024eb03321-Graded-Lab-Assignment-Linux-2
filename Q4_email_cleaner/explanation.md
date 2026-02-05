# Email Cleaner Script - Explanation

## Overview
The `emailcleaner.sh` script processes email addresses from `emails.txt`, separates valid from invalid emails, and removes duplicates from valid emails.

---

## Valid Email Format
According to the requirements, a valid email must match:
- **Format**: `<letters_and_digits>@<letters>.com`
- **Examples**:
  - ✅ Valid: `john123@gmail.com`, `alice@yahoo.com`, `test99@outlook.com`
  - ❌ Invalid: `john@gmail.net`, `alice@123.com`, `test@domain`, `@invalid.com`

---

## Script Breakdown

### 1. File Existence Check
```bash
if [ ! -f "emails.txt" ]; then
    echo "Error: emails.txt not found!"
    exit 1
fi
```
**Explanation:** This checks if `emails.txt` exists before processing. If the file is not found, the script displays an error message and exits with code 1 to prevent errors in subsequent commands.

---

### 2. Define Valid Email Pattern
```bash
VALID_PATTERN='^[a-zA-Z0-9]\+@[a-zA-Z]\+\.com$'
```
**Explanation:** This regular expression pattern defines what constitutes a valid email address according to the requirements.

**Pattern Components:**
- `^` - Start of line
- `[a-zA-Z0-9]\+` - One or more letters (uppercase/lowercase) or digits
- `@` - Literal @ symbol
- `[a-zA-Z]\+` - One or more letters only (domain name)
- `\.com` - Literal `.com` (backslash escapes the dot)
- `$` - End of line

---

### 3. Extract Valid Email Addresses
```bash
grep -E "$VALID_PATTERN" emails.txt > valid_temp.txt
```
**Explanation:** The `grep -E` command searches for lines matching the valid email pattern using extended regular expressions. All matching valid emails are redirected to a temporary file `valid_temp.txt` for further processing.

**Options Used:**
- `-E` - Use extended regular expressions (allows `+` without escaping)

---

### 4. Remove Duplicates from Valid Emails
```bash
sort valid_temp.txt | uniq > valid.txt
```
**Explanation:** This pipeline sorts the valid emails alphabetically using `sort`, then passes them to `uniq` which removes consecutive duplicate lines. The unique emails are saved to `valid.txt` using output redirection.

**Why sort first?** The `uniq` command only removes consecutive duplicates, so sorting ensures all identical emails are adjacent before deduplication.

---

### 5. Extract Invalid Email Addresses
```bash
grep -v -E "$VALID_PATTERN" emails.txt > invalid.txt
```
**Explanation:** The `grep -v` command inverts the match, selecting only lines that do NOT match the valid email pattern. These invalid emails are redirected to `invalid.txt` for separate storage and review.

**Options Used:**
- `-v` - Invert match (select non-matching lines)
- `-E` - Use extended regular expressions

---

### 6. Cleanup Temporary Files
```bash
rm -f valid_temp.txt
```
**Explanation:** This removes the temporary file created during processing to keep the directory clean. The `-f` flag forces removal without prompting, even if the file doesn't exist.

---

### 7. Display Results
```bash
echo "Valid emails (duplicates removed): $(wc -l < valid.txt)"
echo "Invalid emails: $(wc -l < invalid.txt)"
```
**Explanation:** These commands count and display the number of lines in each output file using `wc -l` (word count with line option). The command substitution `$(...)` executes the count and embeds the result in the echo statement.

---

## Commands Used Summary

| Command | Purpose | Options Used |
|---------|---------|--------------|
| `grep` | Search for patterns in text | `-E` (extended regex), `-v` (invert match) |
| `sort` | Sort lines alphabetically | None (default alphabetical) |
| `uniq` | Remove consecutive duplicate lines | None (default behavior) |
| `>` | Redirect output to file (overwrite) | N/A (redirection operator) |
| `\|` | Pipe output to next command | N/A (pipeline operator) |

---

## Usage Instructions

### Step 1: Create Sample emails.txt
```bash
cat > emails.txt << EOF
john@gmail.com
alice@yahoo.com
john@gmail.com
bob123@outlook.com
invalid@domain
test@123.com
sarah@hotmail.com
alice@yahoo.com
admin@.com
mike99@company.com
EOF
```

### Step 2: Make Script Executable
```bash
chmod +x emailcleaner.sh
```

### Step 3: Run the Script
```bash
./emailcleaner.sh
```

---

## Expected Output Files

### valid.txt
Contains unique valid email addresses (alphabetically sorted):
```
alice@yahoo.com
bob123@outlook.com
john@gmail.com
mike99@company.com
sarah@hotmail.com
```

### invalid.txt
Contains all invalid email addresses:
```
invalid@domain
test@123.com
admin@.com
```

---

## Key Learning Points

1. **Regular Expressions**: Pattern matching for email validation
2. **grep**: Searching and filtering text based on patterns
3. **sort**: Organizing data alphabetically
4. **uniq**: Removing duplicate entries (requires sorted input)
5. **Redirection**: Using `>` to save command output to files
6. **Pipelines**: Chaining commands with `|` for efficient data processing
7. **Command Substitution**: Using `$(command)` to embed command output

---

## Testing the Script

### Test Case 1: Valid Emails
```
user@domain.com     ✅ Valid
test123@site.com    ✅ Valid
admin99@mail.com    ✅ Valid
```

### Test Case 2: Invalid Emails
```
user@domain.net     ❌ Invalid (not .com)
user@123.com        ❌ Invalid (domain has digits)
@domain.com         ❌ Invalid (no username)
user@.com           ❌ Invalid (no domain name)
user.name@site.com  ❌ Invalid (dot in username)
user@domain         ❌ Invalid (no .com)
```

### Test Case 3: Duplicates
```
Input:
user@test.com
user@test.com
user@test.com

Output in valid.txt:
user@test.com       (only one entry)
```

---

## Troubleshooting

**Problem**: Script says "emails.txt not found"
- **Solution**: Create `emails.txt` in the same directory as the script

**Problem**: No emails in valid.txt
- **Solution**: Check if your emails match the exact format `<letters_and_digits>@<letters>.com`

**Problem**: Permission denied
- **Solution**: Run `chmod +x emailcleaner.sh` to make the script executable

**Problem**: Pattern doesn't match emails
- **Solution**: Ensure emails follow the strict format - only letters in domain, must end with `.com`

---

## Summary

This script demonstrates fundamental Linux text processing skills by:
1. Using `grep` with regex to validate and filter email addresses
2. Implementing `sort` and `uniq` to remove duplicates efficiently
3. Applying output redirection to organize results into separate files
4. Combining multiple commands with pipes for streamlined data processing

The modular approach makes the script easy to understand, maintain, and extend for additional email validation rules.
