#!/bin/bash

# validate_results.sh - Script to validate student results
# Reads student data from marks.txt and categorizes based on pass/fail status
# Passing marks: 33 in each subject

# Check if marks.txt exists
if [ ! -f "marks.txt" ]; then
    echo "Error: marks.txt file not found!"
    echo "Please create marks.txt with student data in the format:"
    echo "RollNo,Name,Marks1,Marks2,Marks3"
    exit 1
fi

# Check if file is readable
if [ ! -r "marks.txt" ]; then
    echo "Error: marks.txt is not readable."
    echo "Please check file permissions."
    exit 1
fi

# Define passing marks
PASSING_MARKS=33

# Initialize arrays to store student data
declare -a failed_one_subject
declare -a passed_all_subjects

# Initialize counters
count_failed_one=0
count_passed_all=0

echo "=========================================="
echo "Student Results Validation"
echo "=========================================="
echo "Passing Marks: $PASSING_MARKS in each subject"
echo ""

# Read the file line by line
while IFS=',' read -r roll_no name marks1 marks2 marks3; do
    # Skip empty lines
    if [ -z "$roll_no" ]; then
        continue
    fi
    
    # Trim whitespace from variables
    roll_no=$(echo "$roll_no" | xargs)
    name=$(echo "$name" | xargs)
    marks1=$(echo "$marks1" | xargs)
    marks2=$(echo "$marks2" | xargs)
    marks3=$(echo "$marks3" | xargs)
    
    # Validate that marks are numeric
    if ! [[ "$marks1" =~ ^[0-9]+$ ]] || ! [[ "$marks2" =~ ^[0-9]+$ ]] || ! [[ "$marks3" =~ ^[0-9]+$ ]]; then
        echo "Warning: Invalid marks for $name (Roll No: $roll_no). Skipping..."
        continue
    fi
    
    # Count failed subjects
    failed_count=0
    
    if [ "$marks1" -lt "$PASSING_MARKS" ]; then
        ((failed_count++))
    fi
    
    if [ "$marks2" -lt "$PASSING_MARKS" ]; then
        ((failed_count++))
    fi
    
    if [ "$marks3" -lt "$PASSING_MARKS" ]; then
        ((failed_count++))
    fi
    
    # Categorize students based on failed count
    if [ "$failed_count" -eq 1 ]; then
        # Failed in exactly ONE subject
        failed_one_subject+=("$roll_no,$name,$marks1,$marks2,$marks3")
        ((count_failed_one++))
    elif [ "$failed_count" -eq 0 ]; then
        # Passed in ALL subjects
        passed_all_subjects+=("$roll_no,$name,$marks1,$marks2,$marks3")
        ((count_passed_all++))
    fi
    
done < marks.txt

# Display results
echo "=========================================="
echo "Students Who Failed in Exactly ONE Subject"
echo "=========================================="
if [ "$count_failed_one" -gt 0 ]; then
    printf "%-10s %-20s %-8s %-8s %-8s\n" "Roll No" "Name" "Marks1" "Marks2" "Marks3"
    printf "%-10s %-20s %-8s %-8s %-8s\n" "-------" "----" "------" "------" "------"
    
    for student in "${failed_one_subject[@]}"; do
        IFS=',' read -r roll_no name marks1 marks2 marks3 <<< "$student"
        printf "%-10s %-20s %-8s %-8s %-8s\n" "$roll_no" "$name" "$marks1" "$marks2" "$marks3"
    done
else
    echo "No students failed in exactly one subject."
fi
echo ""

echo "=========================================="
echo "Students Who Passed in ALL Subjects"
echo "=========================================="
if [ "$count_passed_all" -gt 0 ]; then
    printf "%-10s %-20s %-8s %-8s %-8s\n" "Roll No" "Name" "Marks1" "Marks2" "Marks3"
    printf "%-10s %-20s %-8s %-8s %-8s\n" "-------" "----" "------" "------" "------"
    
    for student in "${passed_all_subjects[@]}"; do
        IFS=',' read -r roll_no name marks1 marks2 marks3 <<< "$student"
        printf "%-10s %-20s %-8s %-8s %-8s\n" "$roll_no" "$name" "$marks1" "$marks2" "$marks3"
    done
else
    echo "No students passed in all subjects."
fi
echo ""

echo "=========================================="
echo "Summary Statistics"
echo "=========================================="
echo "Total students who failed in exactly ONE subject: $count_failed_one"
echo "Total students who passed in ALL subjects: $count_passed_all"
echo ""

echo "=========================================="
echo "Validation Completed Successfully"
echo "=========================================="

exit 0
