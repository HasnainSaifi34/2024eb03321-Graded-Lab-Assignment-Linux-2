# 2024eb03321-Graded-Lab-Assignment-Linux-2
Sem 2 - Term2 - Command Line Interfaces - SGA 2
1.
Question 1
Please read the following instructions carefully before submitting your Graded Lab Assignment (Modules 5-10).

1. Submission Format 
You must submit the URL of a GitHub repository containing your complete lab assignment.

The repository must be public. (IMPORTANT)  Private repositories will not be graded and such cases would be awarded 0.

Ensure that all required files, outputs, screenshots, and explanations (as described below) are present within the repository.

2. Repository Structure
Your GitHub repository should contain a Folder each for the 10 Questions (Total 10 Folders) containing:

The commands executed for each question

Corresponding outputs

Screenshots of each command execution/output

Any files created during the lab (e.g., user_info.txt, plan.txt, system_report.txt, etc.)

Explanation as described below

3. Explanation After Every Command (Very Important)
You must write 1-2 brief sentences explaining what you did and observed after each command or execution.

These explanations are mandatory and will be used to assess your conceptual understanding.

Submissions that only contain commands and outputs without explanations will be considered incomplete.


Once again, ensure the repository you submit is public.   Private repositories will not be graded and such cases would be awarded 0.



2.
Question 2
There are a total of 10 Question below. 


Question 1 [6 Points]

Create a shell script named analyze.sh that accepts exactly ONE command-line argument.
• If the argument is a file: – Display the number of lines, words, and characters in the file.
• If the argument is a directory: – Display the total number of files present. – Display the number of .txt files in the directory.
• If the argument count is invalid or the path does not exist: – Display an appropriate error message.

Question 2 [6 Points]

You are given a log file containing entries in the format:

YYYY-MM-DD HH:MM:SS LEVEL MESSAGE

Example:

2025-01-12 10:15:22 INFO System started

2025-01-12 10:16:01 ERROR Disk not found

2025-01-12 10:16:45 WARNING High memory usage

2025-01-12 10:17:10 ERROR Network timeout

Requirements:

1. The script must accept the log file name as a command-line argument.

2. Validate that the file exists and is readable.

3. Count and display:

  - Total number of log entries

  - Number of INFO, WARNING, and ERROR messages

4. Display the most recent ERROR message.

5. Generate a report file named logsummary_<date>.txt.

6. Handle errors gracefully with meaningful messages.

Question 3 [6 Points]

Write a shell script validate_results.sh that reads student data from marks.txt.Each line contains:RollNo, Name, Marks1,Marks2,Marks3Your script should:
• Print students who failed in exactly ONE subject
• Print students who passed in ALL subjects
• Print the count of students in each categoryPassing marks for each subject is 33.Use loops, conditionals, and arithmetic operations.

Question 4 [6 Points]

Create a shell script emailcleaner.sh that processes emails.txt.
• Extract all valid email addresses and store them in valid.txt
• Extract invalid email addresses and store them in invalid.txt
• Remove duplicate entries from valid.txtValid email format:<letters_and_digits>@<letters>.comUse grep, sort, uniq, and redirection.

Question 5 [6 Points]

Create a shell script sync.sh to compare two directories dirA and dirB.Your script should:
• List files present only in dirA
• List files present only in dirB
• For files with the same name in both directories, check whether their contents matchDo NOT copy or modify files.Use diff, cmp, or checksum techniques.

Question 6 [6 Points]

Create a shell script metrics.sh that analyzes a text file input.txt.The script should display:
• Longest word
• Shortest word
• Average word length
• Total number of unique wordsUse pipes and commands such as tr, sort, uniq, wc.

Question 7 [6 Points]

Write a shell script patterns.sh that reads a text file and:
• Writes words containing ONLY vowels into vowels.txt
• Writes words containing ONLY consonants into consonants.txt
• Writes words containing both vowels and consonants but starting with a consonant into mixed.txt, Case should be ignored while checking patterns.

Question 8 [6 Points]

Create a shell script bg_move.sh that accepts a directory path.
• Move each file in the directory into a subdirectory named backup/
• Perform each move operation in the background
• Display the PID of each background process
• Wait for all background processes to finishUse &, wait, $$, and $! variables.

Question 9 [6 Points]

Write a C program to demonstrate zombie process prevention.
• Create multiple child processes
• Ensure terminated child processes do not remain zombies
• Parent process should print the PID of each child it cleans upUse fork(), wait(), or waitpid().

Question 10 [6 Points]

Write a C program demonstrating signal handling.
• Parent process runs indefinitely
• Child process sends SIGTERM after 5 seconds
• Another child sends SIGINT after 10 seconds
• Parent handles each signal differently and exits gracefully

