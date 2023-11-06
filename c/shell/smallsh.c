#define _XOPEN_SOURCE 700
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>
#include <ctype.h>
#include <fcntl.h>
#include <wait.h>
/*#include <setjmp.h>*/
/*function prototypes*/
int shell_user_entry(char args[512][2048]);
void catchSIGINT(int signo);
void catchSIGTSTP(int signo);


/*declare global variables*/
int previous_command_ret_val = -5; /*saves previous fg function exit value*/
/*variables are volatile so they are read from memory every time they are used*/
volatile sig_atomic_t foreground_only_flag = 0; /*sets foreground only flag*/
volatile int fg_flag=0; /*sets active running in fg flag*/
pid_t fg_pid; /*foreground pid to compare with bg children*/
char child_message_buff_global[512] = ""; /*buffer which has bg child return message*/

/***************************************************************************************
 * function: catchSIGCHLD
 * desc: This is the handler for SIGCHLD signal which is sent every time a child is terminated
 * the handler saves a child exit message to a global buffer which is written every loop of
 * shell_user_entry if there are characters inside of the string 
 * *************************************************************************************/
void catchSIGCHLD(int signo)
{
    pid_t pid = -4; /*pid of current exiting child*/
    int bg_exit_method = -4; /*bg child exit val*/
    char child_message_buff_local[512] = ""; /*local buffer which saves child exit message*/
    while (1) {
        /*keep looping until all children pids and exit methods have been recieved*/
        pid = waitpid(-1, &bg_exit_method, WNOHANG | WUNTRACED);
        if(pid <= 0) 
            break;
        else
        {
            /*if the current exiting child pid is the same as the current global fg pid do not write exit message to buffer*/
            if(pid != fg_pid)
            {
                if(WIFEXITED(bg_exit_method))
                {
                    /*if exited normally write exit status and message to global buffer*/
                    sprintf(child_message_buff_local,"background pid %d is done: exit value %d\n",pid , WEXITSTATUS(bg_exit_method));
                    strcat(child_message_buff_global, child_message_buff_local);
                }
                else if(WIFSIGNALED(bg_exit_method))
                {
                    /*if terminated via signal write signal no. and message to global buffer*/
                    sprintf(child_message_buff_local,"background pid %d is done: terminated with signal %d\n",pid , WTERMSIG(bg_exit_method));
                    strcat(child_message_buff_global, child_message_buff_local);
                }
            }            
        }
    }
}
/***************************************************************************************
 * function: catchSIGINT
 * desc: This is the handler for SIGINT signal which is sent every time a user hits ctrl C 
 * during fg process operation. Compares fg_flag and if there is a current fg operation 
 * print termination message. 
 * *************************************************************************************/
void catchSIGINT(int signo)
{
	/*if current process is a fg process kill process and print termination message (SIGINT = 2)*/
    if(fg_flag)
    {
        char* message = "terminated by signal 2\n";
        write(STDOUT_FILENO, message, 23); /*Use non re-entrant function to write to stdout*/
        fflush(stdout);
        fg_flag = 0; /*reset currently running fg flag*/
    }
}
/***************************************************************************************
 * function: catchSIGTSTP
 * desc: This is the handler for SIGTSTP signal which is sent every time a user hits ctrl Z 
 * during any process. This signal toggles a volatile foreground only flag which enables/diables 
 * bg functionality.
 * *************************************************************************************/
void catchSIGTSTP(int signo)
{
    /*invert flag*/
    foreground_only_flag = !foreground_only_flag;
    /*if flag is 1 print message showing disabling of bg*/
    if(foreground_only_flag == 1)
    {
        char* message = "Entering foreground-only mode (& is now ignored)\n";
        write(STDOUT_FILENO, message, 49);
        fflush(stdout);
    }
    /*if flag is 0 print message showing enabling of bg*/
    else
    {
        char* message = "Exiting foreground-only mode\n";
        write(STDOUT_FILENO, message, 29);
        fflush(stdout);
    }
    
}
/***************************************************************************************
 * function: shell_user_entry
 * desc: This is the main function which is looping forever during the operation of this program
 * it handles parsing arguments, throwing and catching flags and execution of all commands
 * *************************************************************************************/
int shell_user_entry(char args[512][2048])
{
    char *str_in = NULL; /*holds user inputted string*/
    char* parsed_arg; /*holds single parsed argument of user inputted str*/
    char* arg_pointer_list[512]; /*holds arg pointer list passed to execvp*/

    size_t str_size = 0; /*holds value allocated by getline of string size*/
    int result = 0; /*value of getline return*/
    int return_val = EXIT_SUCCESS; /*return val of entire function*/
    int arg_count = 0; /*number of arguments*/
    
    char current_dir[2048];
    char home_dir[2048];
    int i, j;

    int exec_flag = 0; /*flag which determines execution of non built in commands*/
    int background_flag = 0; /*flag which tells shell if current command is in bg*/
    int fileio_var = 0; /*variable holding which kind of fileio operation current command is exec*/

    char wr_filename[512]; /*fileio write filename*/
    char rd_filename[512]; /*fileio read filename*/
    
    pid_t spawn_pid = -5; /*process id returned from fork()*/
    int child_exit_meathod = -5; /*exit method of child*/
    int fd; /*file descriptor for redirecting stdin stdout*/

    pid_t shell_pid = -5; /*process id of shell*/
    char pid_string[64]; /*string of decimal pid of shell*/
    char* str_ptr; /*string pointer for strstr operations*/
    char buf[512]; /*buffer for strstr operation (replacing $$ with pid)*/
    int ret_flag = 0; /*flag which tells shell to return if asserted*/

    const char* shell_replace_string = "$$"; /*pid replacement string*/
    const char* HOME_env = getenv("HOME"); /*const pointer to HOME environemnt variable*/
    parsed_arg = (char *) malloc (2048); /*allocate memory for parsed arguments*/

    getcwd(current_dir, 2048); /*get current dir*/
    /*if the global child exit message buffer is empty there is nothing to write else print*/
    if(child_message_buff_global[0] != 0)
    {
        printf("%s",child_message_buff_global);
        fflush(stdout);
        /*set child message buff to null after write*/
        memset(child_message_buff_global, 0, sizeof(child_message_buff_global));
    }
        printf(":"); /*print prompt*/
    fflush(stdout);
    /******************GETLINE HANDLING***********************/
    /*use while loop and getline result to protect from error situation*/
    while(1)
    {
        result = getline(&str_in, &str_size, stdin);
        if(result == -1)
            clearerr(stdin);
        else
            break;
    }

    /*if the string input is just a newline prompt again*/
    if(!(str_in[0] == '\n' && result == 1))
    {
        /*parse user input string for args*/
        parsed_arg = strtok(str_in, " \n");
        while(parsed_arg != NULL)
        {
            /*copy parsed args to args string array*/
            strcpy(args[arg_count], parsed_arg);
            parsed_arg = strtok(NULL, " \n");
            arg_count++;
        }
        /*get shell pid, save to string*/
        shell_pid = getpid();
        sprintf(pid_string, "%d", shell_pid);
        /*loop through each arg and replace $$ with pid*/
        for(i=0;i<arg_count;i++)
        {
            if(!strcmp(args[i], "$$"))
            {
                strcpy(args[i],pid_string);
            }
            else
            {   
                /*if not just $$ as arg parse all args and replace $$ w pid*/
                int tmp;
                /*find where $$ in arg starts*/
                str_ptr = strstr(args[i], shell_replace_string);
                /*clear buff*/
                memset(buf, 0, sizeof(buf));
                if(str_ptr)
                {
                    /*copy args and save string without $$ into buffer*/
                    strncpy(buf, args[i], tmp = (int)(str_ptr - args[i]));
                    /*concatenate pid string to buffer*/
                    strcat(buf, pid_string);
                    /*strcat(buf, (const char*) &args[tmp+2]);*/
                    /*clear with null terminating char*/
                    strcat(buf, "\0");
                    /*clear original value of arg and save buf into it*/
                    memset(args[i], 0, sizeof(args[i]));
                    strcpy(args[i],buf);
                }
            }
            
        }

        /*This looks at last argument to see if should be running in background*/
        if(args[arg_count-1][0] == '&' && strlen(args[arg_count-1]) == 1)
        {
            background_flag = 1;
        }
        /*cycle through all arguments*/
        for(i=0;i<arg_count;i++)
        {
            /*if an argument has input operator*/
            if(args[i][0] == '<')
            {
                /*set fileio var to 2 and make sure is readable and exists with access sys call*/
                fileio_var = 2;
                if(!access(args[i+1], F_OK) && (!access(args[i+1], R_OK)))
                    strcpy(rd_filename, args[i+1]);   
                else
                {
                    /*if unreadable or does not exist return and print error message*/
                    perror("ERROR file does not exist or is unreadable");
                    ret_flag = 1;
                }
            }
            /*if output operator in arguments*/
            else if(args[i][0] == '>')
            {
                /*increment fileio variable (1 == output) (2 == input) (3 == input/output)*/
                fileio_var++;
                strcpy(wr_filename, args[i+1]); /*save filename into string*/
                if(fileio_var == 3)
                    break;
            }

        }
        /*if first character is comment ignore and return*/
        if(args[0][0] == '#')
        {
            ret_flag = 1;
        }
        /*if exit built in command is called free memory and exit program*/
        else if(!strcmp(args[0],"exit"))
        {
            free(str_in);
            free(parsed_arg);
            str_in = NULL;
            exit(0);
        }
        /*if cd built in command is called change direc to HOME or inputted dir*/
        else if(!strcmp(args[0],"cd"))
        {
            if(arg_count == 1)
                chdir(HOME_env);
            else 
                chdir(args[1]);

        }
        /*if status command is called print status of last fg process exit method or signal*/
        else if(!strcmp(args[0],"status"))
        {
            /*only signal that kills fg processes is SIGINT*/
            if(previous_command_ret_val !=2)
                printf("exit value %d\n", previous_command_ret_val);
            else
                printf("terminated by signal %d\n", previous_command_ret_val);
            fflush(stdout);
        }
        else
        {
           exec_flag = 1; /*if none of built in commands assert exec flag and try to find in path*/
        }
        /*if ret_flag was asserted previously then free variables and return out of loop*/
        if(ret_flag)
        {
            free(str_in);
            free(parsed_arg);
            str_in = NULL;
            ret_flag = 0;
            return(return_val);
        }
        /*if non built in command begin exec prep*/
        if(exec_flag)
        {
            if(fileio_var)
            {
                /*if there is fileio the fileio args must be deleted*/
                if(background_flag && fileio_var != 3)
                {
                    /*if bg and fileio delete last 3 args*/
                    for(i=1;i<4;i++)
                    {
                        memset(args[arg_count-i],0,sizeof(args[arg_count-i]));
                    }
                    arg_count -= 3;   
                }
                else if(background_flag && fileio_var == 3)
                {
                    /*if bg and input/output delete last 5 args*/
                    for(i=1;i<6;i++)
                    {
                        memset(args[arg_count-i],0,sizeof(args[arg_count-i]));
                    }
                    arg_count -= 5; 
                }
                else
                {
                    /*if regular fileio delete last 2 args*/
                    if(fileio_var != 3)
                    {
                        for(i=1;i<3;i++)
                        {   
                            memset(args[arg_count-i],0,sizeof(args[arg_count-i]));
                        }
                        arg_count -= 2;
                    }
                    /*if both input and output delete last 4 args*/
                    else
                    {
                        for(i=1;i<5;i++)
                        {
                            memset(args[arg_count-i],0,sizeof(args[arg_count-i]));
                        }
                        arg_count -=4;
                    }
                }
            }
            /*if not fileio but bg asserted then only delete last arg*/
            else if(background_flag)
            {
                memset(args[arg_count-1],0,sizeof(args[arg_count-1]));
                arg_count -= 1;
                /*if fg only flag is asserted deassert bg flag*/
                if(foreground_only_flag)
                    background_flag = 0;
            }

            /*spawn child process for exec*/
            spawn_pid = fork();
            if(spawn_pid == 0)
            {
                /******************************CHILD PROCESS******************************/
                /*perform redirection of fileio*/
                if(fileio_var == 1)
                {
                    /*stdout to file*/
                    fd = open(wr_filename, O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR);
                    dup2(fd, 1);
                    close(fd);
                }
                else if(fileio_var == 2)
                {
                    /*file to stdin*/
                    fd = open(rd_filename, O_RDONLY | O_CREAT, S_IRUSR | S_IWUSR);
                    dup2(fd, 0);
                    close(fd); 
                }
                /*****************************FOR INPUT OUTPUT*******************************************/
                else if(fileio_var == 3)
                {
                    /*file to stdin*/
                    fd = open(rd_filename, O_RDONLY | O_CREAT, S_IRUSR | S_IWUSR);
                    dup2(fd, 0);
                    close(fd);
                    /*stdout to file*/
                    fd = open(wr_filename, O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR);
                    dup2(fd, 1);
                    close(fd);
                }
                /*if bg flag is asserted and no fileio was given to command send stdin stdout to dev/null*/
                if(background_flag)
                {
                    /****set process id group to be different so cannot be killed via ctrl C*****/
                    setpgid(0,0);
                    /*send to black hole*/
                    fd = open("/dev/null", O_RDWR | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR);
                    if(fileio_var == 1)
                        dup2(fd, 0);
                    else if(fileio_var == 2)
                        dup2(fd, 1);
                    else
                    {
                        dup2(fd, 0);
                        dup2(fd, 1);
                    }
                    close(fd);
                }                
                /**LAST STEP BEFORE EXECUTION**/
                /*set arg pointer to static args list*/
                for(i=0;i<arg_count;i++)
                {
                    arg_pointer_list[i]=args[i];
                }
                /*set last pointer to NULL*/
                arg_pointer_list[arg_count] = NULL;
                /*execute on path command and args list*/
                if(execvp(arg_pointer_list[0],arg_pointer_list) < 0)
                {
                    /*if failed exec print error*/
                    perror("Command execution failure\n");
                    return_val = 1;
                }
            }
            else
            {
                /******************************PARENT PROCESS******************************/
                if(background_flag)
                {
                    /*if exec in bg deassert fg flag and print out bg process id*/
                    fg_flag = 0;
                    printf("background process pid is %d\n",spawn_pid);
                    fflush(stdout);
                }
                else
                {
                    /*if exec in fg assert fg flag global and set spawn pid to fg_pid this value will be compared at SIGCHLD handler*/
                    fg_flag = 1;
                    fg_pid = spawn_pid;
                    /*perform blocking waitpid on fg process*/
                    if(waitpid(spawn_pid, &child_exit_meathod, 0))
                    {
                        /*find exit return val or signal return val of fg process*/
                        if(WIFEXITED(child_exit_meathod))
                            previous_command_ret_val = WEXITSTATUS(child_exit_meathod);
                        else if(WIFSIGNALED(child_exit_meathod))
                            previous_command_ret_val = WTERMSIG(child_exit_meathod);
                        /*fg is finished exec so deassert running flag*/
                        fg_flag = 0;               
                    }
                    else
                    {
                        /*print error if fg child non positive val*/
                        perror("waitpid error\n");
                    }
                }
            }
        }
        /*null values in argument string*/
        args = NULL;
    }
    /*free memory and ret function*/
    free(str_in);
    free(parsed_arg);
    str_in = NULL;
    return return_val;
}

void main()
{
    /*declare shell return and args variables*/
    int shell_ret = 0;
    char args[512][2048];

    /*set up signal handling struct for SIGTSTP*/
    struct sigaction SIGTSTP_action = {0};
    SIGTSTP_action.sa_handler = catchSIGTSTP;
    sigfillset(&SIGTSTP_action.sa_mask); /*block all signals in mask*/
    SIGTSTP_action.sa_flags = 0;
    sigaction(SIGTSTP, &SIGTSTP_action, NULL);

    struct sigaction SIGINT_action = {0};
	SIGINT_action.sa_handler = catchSIGINT;
	sigfillset(&SIGINT_action.sa_mask); /*block all signals in mask*/
	SIGINT_action.sa_flags = SA_RESTART; /*set restart flag to not have system calls interrupt*/
    sigaction(SIGINT, &SIGINT_action, NULL);
    
    struct sigaction SIGCHLD_action = {0};
	SIGCHLD_action.sa_handler = catchSIGCHLD;
	sigfillset(&SIGCHLD_action.sa_mask); /*block all signals in mask*/
	SIGCHLD_action.sa_flags = SA_RESTART; /*set restart flag to not have system calls interrupt*/
    sigaction(SIGCHLD, &SIGCHLD_action, NULL);

    /*loop forever in normal operation*/
    while(shell_ret == 0)
        shell_ret = shell_user_entry(args);
}

#if 0
/*I wrote this find command in path function however upon realizing execvp did all the work for me I did not use but kept in so efforts were not wasted*/
int find_command_in_path(char args[512][2048], char* temp_command_path)
{
    int found_exe = 0;
    char* parsed_arg_path;
    int arg_count = 0;
    int arg_len;

    parsed_arg_path = (char *) malloc(512);
    const char* PATH = getenv("PATH");
    
    parsed_arg_path = strtok(PATH, ":");
    while(parsed_arg_path != NULL)
    {
        /*printf("%s\n", parsed_arg);*/
        /*printf("args[arg_count]: %s\n",args[arg_count]);*/
        arg_len = strlen(parsed_arg_path);

        /*strncpy(temp_command_path, parsed_arg_path, arg_len);
        strncat(temp_command_path, "/",1);

        arg_len = strlen(args[0]);
        strncat(temp_command_path, args[0], arg_len);
        */
        strcpy(temp_command_path, parsed_arg_path);
        strcat(temp_command_path, "/");
        strcat(temp_command_path, args[0]);

        if(!access(temp_command_path, X_OK))
        {
            found_exe = 1;
            break;
        }
        parsed_arg_path = strtok(NULL, ":");
        arg_count++;
    }
    parsed_arg_path = NULL;
    free(parsed_arg_path);
    return(found_exe);
}
#endif