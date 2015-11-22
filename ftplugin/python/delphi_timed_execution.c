#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include <fcntl.h>

int main(int argc, char** argv){
    if (argc != 4){
        printf("Usage: %s input_file output_file time_limit\n", argv[0]);
        exit(1);
    }
    int time_limit = atoi(argv[3]) * 1000;
    int cid = fork();

    char* python_command[3];
    python_command[0] = "python";
    python_command[1] = argv[1];
    python_command[2] = NULL;

    int python_out_fd;

    if (cid < 0){
        printf("Fork failed\n");
        exit(1);
    }else if(cid == 0){
        python_out_fd = open(argv[2], O_TRUNC|O_CREAT|O_WRONLY, 0755);
        if (python_out_fd < 0){
            printf("error opening file\n");
            exit(1);
        }
        if (dup2(python_out_fd,1)<0 || dup2(python_out_fd,2)<0){
            printf("dup error\n");
            exit(1);
        }
        execvp("python", (char* const*)python_command);
    }else{
        usleep(time_limit);
        kill(cid, SIGKILL);
    }
}
