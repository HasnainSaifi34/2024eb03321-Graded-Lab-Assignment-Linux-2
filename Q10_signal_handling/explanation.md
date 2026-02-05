# Signal Handling - C Program

## Overview
This C program demonstrates signal handling in Linux by creating a parent process that runs indefinitely and handles two different signals (SIGTERM and SIGINT) sent by two child processes at different times. The program shows how to set up custom signal handlers and perform graceful shutdown.

## What are Signals?

**Signals** are software interrupts that provide a way to handle asynchronous events in Unix/Linux systems. They allow processes to communicate and respond to various events like user interrupts, termination requests, or custom events.

Common signals:
- **SIGTERM** (15): Termination signal - polite request to terminate
- **SIGINT** (2): Interrupt signal - typically sent by Ctrl+C
- **SIGKILL** (9): Kill signal - cannot be caught or ignored
- **SIGCHLD** (17): Child process terminated

## Code Explanation

### 1. **Header Files**
```c
#include <stdio.h>      // Standard I/O
#include <stdlib.h>     // exit(), EXIT_SUCCESS
#include <unistd.h>     // fork(), getpid(), sleep()
#include <signal.h>     // Signal handling functions
#include <sys/types.h>  // pid_t type
#include <sys/wait.h>   // waitpid()
#include <time.h>       // time functions
```

### 2. **Global Signal Flags**
```c
volatile sig_atomic_t sigterm_received = 0;
volatile sig_atomic_t sigint_received = 0;
```

**Why volatile sig_atomic_t?**
- **volatile**: Tells compiler the variable can change unexpectedly (by signal handlers)
- **sig_atomic_t**: Atomic type that can be safely accessed from signal handlers
- Prevents race conditions between signal handlers and main program

### 3. **Signal Handler Functions**

#### SIGTERM Handler
```c
void sigterm_handler(int signum) {
    printf("\n[PARENT] Received SIGTERM (signal %d)\n", signum);
    printf("[PARENT] Handling SIGTERM: Performing cleanup operations...\n");
    printf("[PARENT] Cleanup complete. Marking SIGTERM as received.\n");
    sigterm_received = 1;
}
```

**Purpose**: 
- Handles the SIGTERM signal (termination request)
- Performs cleanup operations
- Sets flag to indicate signal was received

#### SIGINT Handler
```c
void sigint_handler(int signum) {
    printf("\n[PARENT] Received SIGINT (signal %d)\n", signum);
    printf("[PARENT] Handling SIGINT: Saving state and preparing to exit...\n");
    printf("[PARENT] State saved. Marking SIGINT as received.\n");
    sigint_received = 1;
}
```

**Purpose**:
- Handles the SIGINT signal (interrupt)
- Saves state before exit
- Sets flag to indicate signal was received

### 4. **Setting Up Signal Handlers**

```c
struct sigaction sa_term, sa_int;

// Configure SIGTERM handler
sa_term.sa_handler = sigterm_handler;
sigemptyset(&sa_term.sa_mask);
sa_term.sa_flags = 0;

if (sigaction(SIGTERM, &sa_term, NULL) == -1) {
    perror("sigaction SIGTERM failed");
    exit(1);
}
```

**sigaction structure**:
- `sa_handler`: Pointer to the handler function
- `sa_mask`: Signals blocked during handler execution
- `sa_flags`: Special flags for handler behavior

**Why sigaction() instead of signal()?**
- More portable and reliable
- Provides better control over signal behavior
- Recommended modern approach

### 5. **Child Process 1 - SIGTERM Sender**

```c
child1_pid = fork();

if (child1_pid == 0) {
    // Child 1 process
    printf("[CHILD 1] PID: %d, Parent PID: %d\n", getpid(), getppid());
    printf("[CHILD 1] Will send SIGTERM to parent after 5 seconds\n");
    
    sleep(5);
    
    printf("[CHILD 1] Sending SIGTERM to parent (PID %d)...\n", parent_pid);
    
    if (kill(parent_pid, SIGTERM) == -1) {
        perror("[CHILD 1] Failed to send SIGTERM");
        exit(1);
    }
    
    printf("[CHILD 1] SIGTERM sent successfully. Exiting...\n");
    exit(0);
}
```

**Behavior**:
- Sleeps for 5 seconds
- Sends SIGTERM to parent using `kill()` system call
- Exits after sending signal

### 6. **Child Process 2 - SIGINT Sender**

```c
child2_pid = fork();

if (child2_pid == 0) {
    // Child 2 process
    printf("[CHILD 2] PID: %d, Parent PID: %d\n", getpid(), getppid());
    printf("[CHILD 2] Will send SIGINT to parent after 10 seconds\n");
    
    sleep(10);
    
    printf("[CHILD 2] Sending SIGINT to parent (PID %d)...\n", parent_pid);
    
    if (kill(parent_pid, SIGINT) == -1) {
        perror("[CHILD 2] Failed to send SIGINT");
        exit(1);
    }
    
    printf("[CHILD 2] SIGINT sent successfully. Exiting...\n");
    exit(0);
}
```

**Behavior**:
- Sleeps for 10 seconds
- Sends SIGINT to parent using `kill()` system call
- Exits after sending signal

### 7. **Parent Process - Infinite Loop**

```c
int counter = 0;
while (!sigterm_received || !sigint_received) {
    printf("[PARENT] Working... (iteration %d)\n", ++counter);
    sleep(2);
    
    if (sigterm_received && !sigint_received) {
        printf("[PARENT] SIGTERM received, but still waiting for SIGINT...\n");
    }
}
```

**Behavior**:
- Runs indefinitely until BOTH signals are received
- Performs work every 2 seconds
- Checks signal flags and provides status updates

### 8. **Graceful Exit and Cleanup**

```c
printf("\n[PARENT] Both signals (SIGTERM and SIGINT) received!\n");
printf("[PARENT] Preparing for graceful exit...\n");

// Clean up child processes
int status;
pid_t wpid;

wpid = waitpid(child1_pid, &status, WNOHANG);
if (wpid == child1_pid) {
    printf("[PARENT] Child 1 (PID %d) cleaned up\n", child1_pid);
}

wpid = waitpid(child2_pid, &status, WNOHANG);
if (wpid == child2_pid) {
    printf("[PARENT] Child 2 (PID %d) cleaned up\n", child2_pid);
}
```

**WNOHANG flag**: 
- Non-blocking wait
- Returns immediately if child hasn't terminated yet
- Returns child PID if child has terminated

### 9. **Key System Calls and Functions**

| Function/Call | Purpose | Return Value |
|---------------|---------|--------------|
| `sigaction()` | Install signal handler | 0 on success, -1 on error |
| `sigemptyset()` | Initialize empty signal set | 0 on success |
| `kill()` | Send signal to process | 0 on success, -1 on error |
| `fork()` | Create child process | PID in parent, 0 in child, -1 on error |
| `getpid()` | Get current process ID | Current PID |
| `getppid()` | Get parent process ID | Parent's PID |
| `waitpid()` | Wait for child process | PID of terminated child |
| `sleep()` | Suspend execution | 0 on completion |

## Compilation and Execution

### Compile the Program
```bash
gcc -o signal_handling signal_handling.c
```

### Run the Program
```bash
./signal_handling
```

## Expected Output

```
=== Signal Handling Demonstration ===
Parent Process PID: 1234

Signal handlers installed:
  - SIGTERM handler: Custom cleanup handler
  - SIGINT handler: Custom exit preparation handler

[CHILD 1] PID: 1235, Parent PID: 1234
[CHILD 1] Will send SIGTERM to parent after 5 seconds
[CHILD 2] PID: 1236, Parent PID: 1234
[CHILD 2] Will send SIGINT to parent after 10 seconds

[PARENT] Created Child 1 (PID 1235) - Will send SIGTERM in 5s
[PARENT] Created Child 2 (PID 1236) - Will send SIGINT in 10s

[PARENT] Running indefinitely... waiting for signals
[PARENT] Press Ctrl+C or wait for child signals

[PARENT] Working... (iteration 1)
[PARENT] Working... (iteration 2)
[CHILD 1] Sending SIGTERM to parent (PID 1234)...
[CHILD 1] SIGTERM sent successfully. Exiting...

[PARENT] Received SIGTERM (signal 15)
[PARENT] Handling SIGTERM: Performing cleanup operations...
[PARENT] Cleanup complete. Marking SIGTERM as received.
[PARENT] Working... (iteration 3)
[PARENT] SIGTERM received, but still waiting for SIGINT...
[PARENT] Working... (iteration 4)
[PARENT] SIGTERM received, but still waiting for SIGINT...
[CHILD 2] Sending SIGINT to parent (PID 1234)...
[CHILD 2] SIGINT sent successfully. Exiting...

[PARENT] Received SIGINT (signal 2)
[PARENT] Handling SIGINT: Saving state and preparing to exit...
[PARENT] State saved. Marking SIGINT as received.

[PARENT] Both signals (SIGTERM and SIGINT) received!
[PARENT] Preparing for graceful exit...
[PARENT] Cleaning up child processes...
[PARENT] Child 1 (PID 1235) cleaned up
[PARENT] Child 2 (PID 1236) cleaned up

[PARENT] Graceful exit complete. Goodbye!
=== Program terminated successfully ===
```

## Program Flow Timeline

```
Time    Event
----    -----
0s      Parent starts, installs signal handlers
0s      Child 1 created (will send SIGTERM at 5s)
0s      Child 2 created (will send SIGINT at 10s)
0-5s    Parent working, printing iterations
5s      Child 1 sends SIGTERM to parent
5s      Parent handles SIGTERM, continues working
5-10s   Parent working, waiting for SIGINT
10s     Child 2 sends SIGINT to parent
10s     Parent handles SIGINT, both signals received
10s     Parent performs cleanup, exits gracefully
```

## Key Concepts Demonstrated

1. **Custom Signal Handlers**: Installing handlers for SIGTERM and SIGINT
2. **Signal-Safe Programming**: Using volatile sig_atomic_t for flags
3. **Inter-Process Communication**: Children sending signals to parent
4. **Graceful Shutdown**: Handling signals properly before exit
5. **Process Synchronization**: Parent waiting for specific signals
6. **Different Signal Responses**: Each signal handled differently

## Important Notes

### Signal Handler Safety
- **Keep handlers simple**: Avoid complex operations in signal handlers
- **Use async-signal-safe functions**: Not all functions are safe in handlers
- **Avoid printf()**: Technically not async-signal-safe (but commonly used for demo)
- **Use atomic types**: For variables accessed by both handler and main code

### Alternative Approaches

#### Using signal() instead of sigaction()
```c
signal(SIGTERM, sigterm_handler);
signal(SIGINT, sigint_handler);
```
Note: sigaction() is preferred for portability

#### Blocking signals temporarily
```c
sigset_t mask;
sigemptyset(&mask);
sigaddset(&mask, SIGTERM);
sigprocmask(SIG_BLOCK, &mask, NULL);  // Block SIGTERM
// Critical section
sigprocmask(SIG_UNBLOCK, &mask, NULL); // Unblock
```

## Practical Applications

- **Server programs**: Graceful shutdown on SIGTERM
- **Daemon processes**: Reloading configuration on SIGHUP
- **User interrupts**: Handling Ctrl+C cleanly
- **Resource cleanup**: Ensuring proper cleanup before exit
- **State saving**: Checkpointing before termination
- **Process control**: Parent-child communication

## Common Signals Reference

| Signal | Number | Default Action | Description |
|--------|--------|----------------|-------------|
| SIGHUP | 1 | Terminate | Hangup detected |
| SIGINT | 2 | Terminate | Interrupt from keyboard (Ctrl+C) |
| SIGQUIT | 3 | Core dump | Quit from keyboard (Ctrl+\) |
| SIGKILL | 9 | Terminate | Cannot be caught or ignored |
| SIGTERM | 15 | Terminate | Termination signal |
| SIGCHLD | 17 | Ignore | Child stopped or terminated |
| SIGCONT | 18 | Continue | Continue if stopped |
| SIGSTOP | 19 | Stop | Stop process (cannot be caught) |
