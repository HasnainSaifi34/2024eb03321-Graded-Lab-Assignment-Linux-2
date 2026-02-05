#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>

#define NUM_CHILDREN 5

int main() {
    pid_t child_pids[NUM_CHILDREN];
    pid_t pid;
    int i;
    int status;
    
    printf("=== Zombie Process Prevention Demo ===\n");
    printf("Parent Process PID: %d\n\n", getpid());
    
    // Create multiple child processes
    printf("Creating %d child processes...\n\n", NUM_CHILDREN);
    fflush(stdout);  // Flush output buffer before forking
    
    for (i = 0; i < NUM_CHILDREN; i++) {
        pid = fork();
        
        if (pid < 0) {
            // Fork failed
            perror("Fork failed");
            exit(1);
        }
        else if (pid == 0) {
            // Child process
            printf("Child %d: PID = %d, Parent PID = %d\n", 
                   i + 1, getpid(), getppid());
            
            // Each child sleeps for a different amount of time
            // to simulate different execution times
            sleep(i + 1);
            
            printf("Child %d (PID %d): Terminating...\n", i + 1, getpid());
            
            // Child exits with its number as exit status
            exit(i + 1);
        }
        else {
            // Parent process
            child_pids[i] = pid;
            printf("Parent: Created child %d with PID = %d\n", i + 1, pid);
            fflush(stdout);  // Flush output buffer
        }
    }
    
    // Parent process continues here
    printf("\n=== Parent waiting for children to terminate ===\n\n");
    
    // Wait for all child processes to prevent zombies
    for (i = 0; i < NUM_CHILDREN; i++) {
        pid_t terminated_pid = waitpid(child_pids[i], &status, 0);
        
        if (terminated_pid > 0) {
            printf("Parent: Cleaned up child with PID = %d\n", terminated_pid);
            
            if (WIFEXITED(status)) {
                printf("        Child exited normally with status: %d\n", 
                       WEXITSTATUS(status));
            }
            else if (WIFSIGNALED(status)) {
                printf("        Child terminated by signal: %d\n", 
                       WTERMSIG(status));
            }
            printf("\n");
        }
        else {
            perror("waitpid failed");
        }
    }
    
    printf("=== All children cleaned up successfully ===\n");
    printf("Parent Process (PID %d): Exiting...\n", getpid());
    
    return 0;
}

