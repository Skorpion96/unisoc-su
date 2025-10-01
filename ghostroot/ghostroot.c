#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <ctype.h>

#define BR_IN  "/sdcard/rootbridge/in/command.txt"
#define BR_OUT "/sdcard/rootbridge/out/result.txt"

static char CURRENT_DIR[512] = "/";
static const char *ERR_MSG = "We don't do that here.";

// Global flag for signal handling
volatile sig_atomic_t signal_received = 0;

// Signal handler function - keep it minimal and safe
void signal_handler(int sig) {
    signal_received = sig;
    // Re-install the handler (some systems need this)
    signal(sig, signal_handler);
}

// Setup signal traps
void trap_signals() {
    signal(SIGINT, signal_handler);   // Ctrl+C
    signal(SIGQUIT, signal_handler);  // Ctrl+backslash
    signal(SIGTSTP, SIG_IGN);         // Ignore Ctrl+Z completely
}

// Check and handle any received signals
void check_signals() {
    if (signal_received) {
        printf("\n%s\n", ERR_MSG);
        signal_received = 0; // Reset flag
    }
}

void show_help() {
fprintf(stderr,
        "Usage:\n"
        "  ghostroot -c <command>   ->   run a single root command\n"
        "  ghostroot                ->   enter interactive ghostroot shell\n"
        "  <exit>                   ->   exits the rootbridge.sh\n"
        "  <q>                      ->   exits the ghostroot, you can always enter again and resume\n"
        "  <help>                   ->   show this help message\n"
);
}

void usage() {
    show_help();
    exit(1);
}

char *run_and_capture(const char *cmd);

int check_cmd_services() {
    char *service_state = run_and_capture("getprop init.svc.cmd_services");
    if (strcmp(service_state, "running") != 0) {
        fprintf(stderr, "Error: cmd_services not running.\n");
        fprintf(stderr, "Please start it before running this program.\n");
        return 0;
    }
    return 1;
}

int ping_check() {
    FILE *fp;
    char linebuf[256];
    char token[64];
    snprintf(token, sizeof(token), "GR_PING_%d", getpid());

    // clear old output
    fp = fopen(BR_OUT, "w");
    if (fp) fclose(fp);

    // send ping
    fp = fopen(BR_IN, "w");
    if (!fp) { perror("fopen BR_IN"); return 0; }
    fprintf(fp, "echo %s\n", token);
    fclose(fp);

    // wait up to 2s
    for (int i=0; i<20; i++) {
        usleep(100000);
        fp = fopen(BR_OUT, "r");
        if (fp) {
            while (fgets(linebuf, sizeof(linebuf), fp)) {
                if (strstr(linebuf, token)) {
                    fclose(fp);
                    return 1;
                }
            }
            fclose(fp);
        }
    }
    return 0;
}

char *run_and_capture(const char *cmd) {
    static char buf[256];
    FILE *fp = popen(cmd, "r");
    if (!fp) return "";
    if (fgets(buf, sizeof(buf), fp) == NULL) {
        pclose(fp);
        return "";
    }
    buf[strcspn(buf, "\n")] = 0;
    pclose(fp);
    return buf;
}

void update_pwd() {
    char *pwd = run_and_capture("ghostroot -c toybox pwd -L");
    if (pwd[0]) {
        strncpy(CURRENT_DIR, pwd, sizeof(CURRENT_DIR)-1);
        CURRENT_DIR[sizeof(CURRENT_DIR)-1] = '\0';
    }
}

// Function to check if command starts with "exec"
int is_exec_command(const char *cmd) {
    // Skip leading whitespace
    while (*cmd == ' ' || *cmd == '\t') cmd++;
    
    // Check if command starts with "exec"
    if (strncmp(cmd, "exec", 4) == 0) {
        // Make sure it's followed by whitespace or end of string
        char next = cmd[4];
        return (next == ' ' || next == '\t' || next == '\0');
    }
    return 0;
}

// Function to check if a command contains 'exit' as a word boundary
int contains_exit_word(const char *str) {
    const char *p = str;
    while ((p = strstr(p, "exit")) != NULL) {
        // Check if it's a word boundary before
        int before_ok = (p == str || !isalnum((unsigned char)*(p-1)) && *(p-1) != '_');
        // Check if it's a word boundary after
        int after_ok = (!isalnum((unsigned char)*(p+4)) && *(p+4) != '_');
        
        if (before_ok && after_ok) {
            return 1;
        }
        p++;
    }
    return 0;
}

// Function to check if exit is within quotes (echo, printf, cat commands)
int is_exit_in_safe_context(const char *cmd) {
    // Check if command starts with echo, printf, or cat
    const char *p = cmd;
    while (*p == ' ' || *p == '\t') p++;
    
    if (strncmp(p, "echo", 4) == 0 || 
        strncmp(p, "printf", 6) == 0 || 
        strncmp(p, "cat", 3) == 0) {
        
        // Look for exit within quotes
        const char *q = p;
        int in_single_quote = 0;
        int in_double_quote = 0;
        
        while (*q) {
            if (*q == '\'' && !in_double_quote) {
                in_single_quote = !in_single_quote;
            } else if (*q == '"' && !in_single_quote) {
                in_double_quote = !in_double_quote;
            } else if (*q == 'e' && (in_single_quote || in_double_quote)) {
                // Check if this is "exit" within quotes
                if (strncmp(q, "exit", 4) == 0) {
                    return 1;
                }
            }
            q++;
        }
    }
    return 0;
}

// Check if command contains unsafe exit usage
// Returns 1 if safe, 0 if unsafe
int is_safe_exit(const char *cmd) {
    // Skip leading whitespace
    const char *p = cmd;
    while (*p == ' ' || *p == '\t') p++;
    
    // If command is exactly "exit", it's safe (handled specially)
    if (strcmp(p, "exit") == 0) {
        return 1;
    }
    
    // Check if command contains 'exit' as a word
    if (contains_exit_word(cmd)) {
        // If exit is in a safe context (within quotes in echo/printf/cat), it's safe
        if (is_exit_in_safe_context(cmd)) {
            return 1;
        }
        // Otherwise, it's unsafe
        return 0;
    }
    
    // No 'exit' found, so it's safe
    return 1;
}

// Function to safely execute exec commands
void handle_exec_command(const char *cmd) {
    FILE *fp;
    char modified_cmd[1024];
    char outbuf[1024];
    
    // Check for unsafe exit usage
    if (!is_safe_exit(cmd)) {
        fprintf(stderr, "We don't do that here.\n");
        return;
    }
    
    // Wrap the exec command in a subshell to prevent it from replacing the main process
    snprintf(modified_cmd, sizeof(modified_cmd), "sh -c '%s'", cmd);
    
    // Send modified command to rootbridge
    fp = fopen(BR_IN, "w");
    if (!fp) { 
        perror("fopen BR_IN"); 
        return; 
    }
    fprintf(fp, "%s\n", modified_cmd);
    fclose(fp);

    usleep(200000);

    // Read result
    fp = fopen(BR_OUT, "r");
    if (fp) {
        while (fgets(outbuf, sizeof(outbuf), fp)) {
            fputs(outbuf, stdout);
        }
        fclose(fp);
    }
}

// Function to execute regular commands
void execute_command(const char *cmd) {
    FILE *fp;
    char outbuf[1024];
    
    // Check for unsafe exit usage
    if (!is_safe_exit(cmd)) {
        fprintf(stderr, "We don't do that here.\n");
        return;
    }
    
    // Send to rootbridge
    fp = fopen(BR_IN, "w");
    if (!fp) { 
        perror("fopen BR_IN"); 
        return; 
    }
    fprintf(fp, "%s\n", cmd);
    fclose(fp);

    usleep(200000);

    // Read result
    fp = fopen(BR_OUT, "r");
    if (fp) {
        while (fgets(outbuf, sizeof(outbuf), fp)) {
            fputs(outbuf, stdout);
        }
        fclose(fp);
    }
}

void ghostshell() {
    char cmd[1024];
    FILE *fp;

    // Setup signal traps
    trap_signals();

    char device[128];
    fp = popen("getprop ro.product.device", "r");
    if (fp) {
        if (fgets(device, sizeof(device), fp) != NULL) {
            device[strcspn(device, "\n")] = 0;
        } else {
            strcpy(device, "/");
        }
        pclose(fp);
    } else {
        strcpy(device, "/");
    }

    // set initial pwd
    update_pwd();

    printf("Welcome to the ghostroot shell (powered by cmd_skt root socket)\n\n");
    printf("Type 'q' to quit, 'exit' to stop rootbridge.\n\n");

    while (1) {
        check_signals();
        // Print prompt
        printf("%s:%s # ", device, CURRENT_DIR);
        fflush(stdout);

        if (!fgets(cmd, sizeof(cmd), stdin)) break;
        cmd[strcspn(cmd, "\n")] = 0;

        // Check for signals again after input
        check_signals();

        if (strcmp(cmd, "q") == 0) {
            printf("ghostroot shell provided by the Elite x Skorpion96\n");
            exit(0);
        }
        if (strcmp(cmd, "exit") == 0) {
            fp = fopen(BR_IN, "w");
            if (fp) { fprintf(fp, "exit\n"); fclose(fp); }
            printf("The ghostroot will now exit as the rootbridge.sh got closed.\n");
            exit(0);
        }
        if (strcmp(cmd, "help") == 0) {
            show_help();
            continue;
        }
        if (strlen(cmd) == 0) continue;

        // Check if it's an exec command and handle appropriately
        if (is_exec_command(cmd)) {
            handle_exec_command(cmd);
        } else {
            execute_command(cmd);
        }

        // Update CURRENT_DIR only if cmd is cd
        if (strncmp(cmd, "cd", 2) == 0) {
            update_pwd();
        }
    }
}

int main(int argc, char *argv[]) {
    if (!check_cmd_services()) {
        return 1;
    }
    if (!ping_check()) {
        fprintf(stderr, "Error: rootbridge is not responding.\n");
        fprintf(stderr, "Please start rootbridge before running this program.\n");
        return 1;
    }

    if (argc == 1) {
        ghostshell();
    } else if (argc > 2 && strcmp(argv[1], "-c") == 0) {
        FILE *fp;
        char combined_cmd[1024] = "";
        
        // Combine all arguments after -c
        for (int i = 2; i < argc; i++) {
            strcat(combined_cmd, argv[i]);
            if (i < argc - 1) strcat(combined_cmd, " ");
        }

        // Check if it's help command
        if (strcmp(combined_cmd, "help") == 0) {
            show_help();
            return 0;
        }
        
        // Check for unsafe exit usage
        if (!is_safe_exit(combined_cmd)) {
            fprintf(stderr, "We don't do that here.\n");
            return 1;
        }
        
        // Check if it's an exec command and handle appropriately
        if (is_exec_command(combined_cmd)) {
            handle_exec_command(combined_cmd);
        } else {
            fp = fopen(BR_IN, "w");
            if (!fp) { perror("fopen BR_IN"); return 1; }
            fprintf(fp, "%s\n", combined_cmd);
            fclose(fp);

            usleep(200000);

            fp = fopen(BR_OUT, "r");
            if (fp) {
                char line[1024];
                while (fgets(line, sizeof(line), fp)) {
                    fputs(line, stdout);
                }
                fclose(fp);
            }
        }
    } else {
        usage();
    }
    return 0;
}
