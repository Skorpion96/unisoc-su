#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define BR_IN  "/sdcard/rootbridge/in/command.txt"
#define BR_OUT "/sdcard/rootbridge/out/result.txt"

static char CURRENT_DIR[512] = "/";

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

void ghostshell() {
    char cmd[1024];
    char outbuf[1024];

        char device[128];
    FILE *fp = popen("getprop ro.product.device", "r");
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
    char *ps1    = run_and_capture("ghostroot -c 'echo $PS1'");

    // set initial pwd
    update_pwd();

    printf("Welcome to the ghostroot shell (powered by cmd_skt root socket)\n\n");
    printf("Type 'q' to quit, 'exit' to stop rootbridge.\n\n");

    while (1) {
        // Print prompt
// Print prompt
printf("%s:%s # ", device, CURRENT_DIR);
fflush(stdout);
if (ps1 && strlen(ps1) > 0)

        if (!fgets(cmd, sizeof(cmd), stdin)) break;
        cmd[strcspn(cmd, "\n")] = 0;

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

        // send to rootbridge
        fp = fopen(BR_IN, "w");
        if (!fp) { perror("fopen BR_IN"); continue; }
        fprintf(fp, "%s\n", cmd);
        fclose(fp);

        usleep(200000);

        // read result
        fp = fopen(BR_OUT, "r");
        if (fp) {
            while (fgets(outbuf, sizeof(outbuf), fp)) {
                fputs(outbuf, stdout);
            }
            fclose(fp);
        }

        // update CURRENT_DIR only if cmd is cd
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
        FILE *fp = fopen(BR_IN, "w");
        if (!fp) { perror("fopen BR_IN"); return 1; }
        for (int i=2; i<argc; i++) {
            fprintf(fp, "%s ", argv[i]);
        }
        fprintf(fp, "\n");
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
    } else {
        usage();
    }
    return 0;
}

