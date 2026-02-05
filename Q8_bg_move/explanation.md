# bg_move.sh - Background File Movement Script

## Overview
This bash script accepts a directory path and moves all files in that directory to a `backup/` subdirectory. Each file move operation is performed in the background, and the script displays the PID of each background process before waiting for all processes to complete.

## Code Explanation

### 1. **Input Validation**
```bash
if [ $# -eq 0 ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

if [ ! -d "$DIR_PATH" ]; then
    echo "Error: Directory '$DIR_PATH' does not exist"
    exit 1
fi
```
- Checks if a directory path argument is provided
- Verifies that the specified directory exists

### 2. **Backup Directory Creation**
```bash
BACKUP_DIR="$DIR_PATH/backup"
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    echo "Created backup directory: $BACKUP_DIR"
fi
```
- Creates a `backup/` subdirectory within the specified directory if it doesn't exist
- Uses `mkdir -p` to create parent directories if needed

### 3. **Main Script PID Display**
```bash
echo "Main script PID: $$"
```
- `$$` is a special variable that contains the PID of the current shell script
- Displays the main script's process ID

### 4. **PID Array Initialization**
```bash
pids=()
```
- Creates an empty array to store PIDs of background processes
- Will be used later to track all background jobs

### 5. **File Processing Loop**
```bash
for file in "$DIR_PATH"/*; do
    if [ "$file" = "$BACKUP_DIR" ]; then
        continue
    fi
    
    if [ ! -f "$file" ]; then
        continue
    fi
    
    filename=$(basename "$file")
    
    # Background move operation
    (
        mv "$file" "$BACKUP_DIR/"
        echo "Moved: $filename (by process $BASHPID)"
    ) &
    
    pids+=($!)
    echo "Background process started: PID = $! for file '$filename'"
done
```

**Key Components:**
- **Loop through files**: Iterates over all items in the directory
- **Skip backup directory**: Prevents moving the backup directory itself
- **Skip non-files**: Only processes regular files (not subdirectories)
- **Background execution**: `( commands ) &` runs commands in a subshell in the background
- **$!**: Special variable containing the PID of the most recently started background process
- **pids+=($!)**: Appends the background process PID to the array

### 6. **Special Variables Used**

| Variable | Description | Usage in Script |
|----------|-------------|-----------------|
| `$$` | PID of the main script | Display main script process ID |
| `$!` | PID of last background process | Capture PID of each move operation |
| `&` | Background operator | Run move operations in background |
| `wait` | Wait for background processes | Wait for all moves to complete |
| `$BASHPID` | PID of current bash process | Show which process moved each file |

### 7. **Waiting for Completion**
```bash
wait
```
- The `wait` command (without arguments) waits for ALL background child processes to complete
- Ensures the script doesn't exit before all file moves are finished

## Usage

```bash
chmod +x bg_move.sh
./bg_move.sh /path/to/directory
```

## Expected Output

### Sample Directory Structure (Before)
```
test_dir/
├── file1.txt
├── file2.txt
├── file3.txt
└── document.pdf
```

### Console Output
```
Created backup directory: test_dir/backup
Starting file movement operations...
Main script PID: 12345

Background process started: PID = 12346 for file 'file1.txt'
Background process started: PID = 12347 for file 'file2.txt'
Background process started: PID = 12348 for file 'file3.txt'
Background process started: PID = 12349 for file 'document.pdf'

Waiting for all background processes to finish...
Total background processes: 4

Moved: file1.txt (by process 12346)
Moved: file2.txt (by process 12347)
Moved: file3.txt (by process 12348)
Moved: document.pdf (by process 12349)

All background processes completed!
All files have been moved to: test_dir/backup
```

### Directory Structure (After)
```
test_dir/
└── backup/
    ├── file1.txt
    ├── file2.txt
    ├── file3.txt
    └── document.pdf
```

## Key Features

1. **Background Processing**: Each file move runs as a separate background process
2. **PID Tracking**: Displays and tracks the PID of each background process
3. **Process Synchronization**: Uses `wait` to ensure all moves complete before script exits
4. **Safe Operation**: Skips the backup directory itself and non-file items
5. **Automatic Backup Creation**: Creates backup directory if it doesn't exist
6. **Process Identification**: Shows which process ID handled each file move

## Important Notes

- **Concurrent Execution**: All file moves happen simultaneously in the background
- **Directory Safety**: The backup directory itself is never moved
- **Subdirectories**: Only files are moved; subdirectories are skipped
- **PID Display**: Each background process PID is displayed immediately after spawning
- **Completion Guarantee**: Script waits for all background processes before exiting

## Practical Applications

- **Large File Operations**: Moving many files simultaneously saves time
- **Process Management**: Demonstrates background job control in bash
- **Backup Automation**: Automated file organization and backup
- **Parallel Processing**: Learning how to run multiple operations concurrently
