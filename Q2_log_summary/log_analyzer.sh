#!/bin/bash

# log_analyzer.sh - Script to analyze log files
# Accepts log file name as command-line argument

# Check if exactly one argument is provided
if [ $# -ne 1 ]; then
    echo "Error: Invalid number of arguments."
    echo "Usage: $0 <log_file_name>"
    exit 1
fi

# Store the log file name
log_file="$1"

# Check if the file exists
if [ ! -e "$log_file" ]; then
    echo "Error: File '$log_file' does not exist."
    exit 1
fi

# Check if the path is a regular file
if [ ! -f "$log_file" ]; then
    echo "Error: '$log_file' is not a regular file."
    exit 1
fi

# Check if the file is readable
if [ ! -r "$log_file" ]; then
    echo "Error: File '$log_file' is not readable."
    echo "Please check file permissions."
    exit 1
fi

echo "=========================================="
echo "Log Analysis Started"
echo "=========================================="
echo "Analyzing log file: $log_file"
echo ""

# Count total number of log entries
total_entries=$(wc -l < "$log_file")

# Count INFO messages
info_count=$(grep -c "INFO" "$log_file")

# Count WARNING messages
warning_count=$(grep -c "WARNING" "$log_file")

# Count ERROR messages
error_count=$(grep -c "ERROR" "$log_file")

# Get the most recent ERROR message
most_recent_error=$(grep "ERROR" "$log_file" | tail -1)

# Display results
echo "=========================================="
echo "Log Summary"
echo "=========================================="
echo "Total number of log entries: $total_entries"
echo "Number of INFO messages: $info_count"
echo "Number of WARNING messages: $warning_count"
echo "Number of ERROR messages: $error_count"
echo ""
echo "Most recent ERROR message:"
if [ -n "$most_recent_error" ]; then
    echo "$most_recent_error"
else
    echo "No ERROR messages found in the log file."
fi
echo ""

# Generate report file name with current date
report_date=$(date +%Y-%m-%d)
report_file="log_summary_${report_date}.txt"

# Generate the report file
{
    echo "=========================================="
    echo "Log Analysis Report"
    echo "=========================================="
    echo "Report Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Log File Analyzed: $log_file"
    echo ""
    echo "=========================================="
    echo "Summary Statistics"
    echo "=========================================="
    echo "Total number of log entries: $total_entries"
    echo "Number of INFO messages: $info_count"
    echo "Number of WARNING messages: $warning_count"
    echo "Number of ERROR messages: $error_count"
    echo ""
    echo "=========================================="
    echo "Most Recent ERROR Message"
    echo "=========================================="
    if [ -n "$most_recent_error" ]; then
        echo "$most_recent_error"
    else
        echo "No ERROR messages found in the log file."
    fi
    echo ""
    echo "=========================================="
    echo "All ERROR Messages"
    echo "=========================================="
    grep "ERROR" "$log_file"
    echo ""
    echo "=========================================="
    echo "All WARNING Messages"
    echo "=========================================="
    grep "WARNING" "$log_file"
    echo ""
    echo "=========================================="
    echo "End of Report"
    echo "=========================================="
} > "$report_file"

echo "=========================================="
echo "Report Generation"
echo "=========================================="
echo "Report file generated: $report_file"
echo ""

# Display success message
echo "=========================================="
echo "Log Analysis Completed Successfully"
echo "=========================================="

exit 0
