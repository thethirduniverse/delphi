#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>

int main(int argc, char** argv){
    if (argc != 5){
        printf("Usage: %s input_file output_file time_limit\n", argv[0]);
        //exit(1);
    }
    //int time_limit = atoi(argv[3]);
    int time_limit = 100000;
    int cid = fork();

    printf("here\n");
    
    char python_command[200];
    sprintf(python_command, "rm %s;python %s 2>%s 1>%s", argv[2], argv[1], argv[2], argv[2]);
        

    if (cid < 0){
        printf("Fork failed\n");
        exit(1);
    }else if(cid == 0){
        execvp("python", (char* const*)python_command);
    }else{
        sleep(1);
        kill(cid, SIGKILL);
    }
}
