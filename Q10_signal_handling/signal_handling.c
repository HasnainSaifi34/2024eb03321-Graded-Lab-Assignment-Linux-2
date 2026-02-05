#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>

// Global variable to track if signals are received
volatile sig_atomic_t sigterm_received = 0;
volatile sig_atomic_t sigint_received = 0;

// Signal handler for SIGTERM
void sigterm_handler(int signum) {
    printf("\n[PARENT] Received SIGTERM (signal %d)\n", signum);
    printf("[PARENT] Handling SIGTERM: Performing cleanup operations...\n");
    printf("[PARENT] Cleanup complete. Marking SIGTERM as received.\n");
    sigterm_received = 1;
}

// Signal handler for SIGINT
void sigint_handler(int signum) {
    printf("\n[PARENT] Received SIGINT (signal %d)\n", signum);
    printf("[PARENT] Handling SIGINT: Saving state and preparing to exit...\n");
    printf("[PARENT] State saved. Marking SIGINT as received.\n");
    sigint_received = 1;
}

int main() {
    pid_t child1_pid, child2_pid;
    pid_t parent_pid = getpid();
    
    printf("=== Signal Handling Demonstration ===\n");
    printf("Parent Process PID: %d\n\n", parent_pid);
    
    // Set up signal handlers in parent
    struct sigaction sa_term, sa_int;
    
    // Configure SIGTERM handler
    sa_term.sa_handler = sigterm_handler;
    sigemptyset(&sa_term.sa_mask);
    sa_term.sa_flags = 0;
    
    if (sigaction(SIGTERM, &sa_term, NULL) == -1) {
        perror("sigaction SIGTERM failed");
        exit(1);
    }
    
    // Configure SIGINT handler
    sa_int.sa_handler = sigint_handler;
    sigemptyset(&sa_int.sa_mask);
    sa_int.sa_flags = 0;
    
    if (sigaction(SIGINT, &sa_int, NULL) == -1) {
        perror("sigaction SIGINT failed");
        exit(1);
    }
    
    printf("Signal handlers installed:\n");
    printf("  - SIGTERM handler: Custom cleanup handler\n");
    printf("  - SIGINT handler: Custom exit preparation handler\n\n");
    fflush(stdout);  // Flush before forking
    
    // Create first child process (sends SIGTERM after 5 seconds)
    child1_pid = fork();
    
    if (child1_pid < 0) {
        perror("Fork failed for child 1");
        exit(1);
    }
    else if (child1_pid == 0) {
        // Child 1 process
        printf("[CHILD 1] PID: %d, Parent PID: %d\n", getpid(), getppid());
        printf("[CHILD 1] Will send SIGTERM to parent after 5 seconds\n");
        fflush(stdout);
        
        sleep(5);
        
        printf("[CHILD 1] Sending SIGTERM to parent (PID %d)...\n", parent_pid);
        fflush(stdout);
        
        if (kill(parent_pid, SIGTERM) == -1) {
            perror("[CHILD 1] Failed to send SIGTERM");
            exit(1);
        }
        
        printf("[CHILD 1] SIGTERM sent successfully. Exiting...\n");
        fflush(stdout);
        exit(0);
    }
    
    // Create second child process (sends SIGINT after 10 seconds)
    fflush(stdout);  // Flush before second fork
    child2_pid = fork();
    
    if (child2_pid < 0) {
        perror("Fork failed for child 2");
        exit(1);
    }
    else if (child2_pid == 0) {
        // Child 2 process
        printf("[CHILD 2] PID: %d, Parent PID: %d\n", getpid(), getppid());
        printf("[CHILD 2] Will send SIGINT to parent after 10 seconds\n");
        fflush(stdout);
        
        sleep(10);
        
        printf("[CHILD 2] Sending SIGINT to parent (PID %d)...\n", parent_pid);
        fflush(stdout);
        
        if (kill(parent_pid, SIGINT) == -1) {
            perror("[CHILD 2] Failed to send SIGINT");
            exit(1);
        }
        
        printf("[CHILD 2] SIGINT sent successfully. Exiting...\n");
        fflush(stdout);
        exit(0);
    }
    
    // Parent process continues here
    printf("\n[PARENT] Created Child 1 (PID %d) - Will send SIGTERM in 5s\n", child1_pid);
    printf("[PARENT] Created Child 2 (PID %d) - Will send SIGINT in 10s\n", child2_pid);
    printf("\n[PARENT] Running indefinitely... waiting for signals\n");
    printf("[PARENT] Press Ctrl+C or wait for child signals\n\n");
    
    // Parent runs indefinitely until both signals are received
    int counter = 0;
    while (!sigterm_received || !sigint_received) {
        printf("[PARENT] Working... (iteration %d)\n", ++counter);
        sleep(2);
        
        // Check if only SIGTERM received
        if (sigterm_received && !sigint_received) {
            printf("[PARENT] SIGTERM received, but still waiting for SIGINT...\n");
        }
    }
    
    // Both signals received
    printf("\n[PARENT] Both signals (SIGTERM and SIGINT) received!\n");
    printf("[PARENT] Preparing for graceful exit...\n");
    
    // Clean up child processes
    printf("[PARENT] Cleaning up child processes...\n");
    
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
    
    printf("\n[PARENT] Graceful exit complete. Goodbye!\n");
    printf("=== Program terminated successfully ===\n");
    
    return 0;
}
