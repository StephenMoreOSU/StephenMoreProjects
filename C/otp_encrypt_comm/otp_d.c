#define _XOPEN_SOURCE 700
#include <signal.h>
#include <dirent.h>
#include <sys/stat.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>
#include <ftw.h>
#include <sys/ioctl.h>

//define macros
#define POST 0
#define GET 1
#define error_msg "!ERROR!"
#define DEBUG 1

void error(const char *msg) { perror(msg); exit(1); } // Error function used for reporting issues
void catchSIGCHLD(int signo);
int find_oldest(const char *path, const struct stat *sb, int typeflag);


volatile int process_count = 0; //counts the number of clients currently being serviced, must be volatile because decremented in SIGCHLD handler
char oldest[512+1] = {0}; // holds the oldest file in user directory
time_t mtime = 0; //holds timestamp to determine age


/***************************************************************************************
 * function: catchSIGCHLD
 * desc: This is the handler for SIGCHLD signal which is sent every time a child is terminated
 * the handler simply reaps zombie children which happens once they are finished 
 * servicing the client request. This function was taken from my smallsh.c
 * *************************************************************************************/
void catchSIGCHLD(int signo)
{
    pid_t pid = -4; /*pid of current exiting child*/
    int bg_exit_method = -4; /*bg child exit val*/
    //char child_message_buff_local[512] = ""; /*local buffer which saves child exit message*/
    while (1) {
        /*keep looping until all children pids and exit methods have been recieved*/
        pid = waitpid(-1, &bg_exit_method, WNOHANG | WUNTRACED);
        if(pid <= 0) 
            break;
        else
        {
            if(process_count > 0)
                process_count--; // decrement process count after child is terminated
            //I left the following section if child exit meathods are needed
#if 0
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
#endif           
        }
    }
}

/***************************************************************************************
 * function: find_oldest
 * desc: This function looks in the given directory for file with the oldest timestamp
 * I got this function from stack exchange at the following link:
 * https://stackoverflow.com/questions/25382163/getting-the-oldest-file-in-a-directory-c
 * *************************************************************************************/
int find_oldest(const char *path, const struct stat *sb, int typeflag) {
    if (typeflag == FTW_F && (mtime == 0 || sb->st_mtime < mtime)) {
        mtime = sb->st_mtime;
        strncpy(oldest, path, 512+1);
    }
    return 0;
}


int main(int argc, char *argv[])
{
	int listenSocketFD, establishedConnectionFD, portNumber, charsRead; //declare socket variables
	socklen_t sizeOfClientInfo; 
	char buffer[2048];
	struct sockaddr_in serverAddress, clientAddress;

    pid_t spawn_pid, child_pid[5]; //spawn pid and array of child process ids
    int child_exit_meathod = -5; //child exit meathod

    int i; // index;

    char ciphertext[2048]; //ciphertext string
    char username[32]; //username string
    char* parsed_arg; //parsed section of buffer rx from client
    int parse_count=0; //index of parsed buffer
    int post_get_var=-1; //var labeling POST or GET

    FILE* fp; // general purpose file pointer
    char fname[256]; //general purpose file name string
    char pname[512]; //path name for saving and opening files in directories
    char pidstr[128]; //string holding the process id of child for differentiating saved files

    int ret_val=0; //return value determining error message ret
    int chars_sent=0; //number of chars sent across the buffer, used to resend if connection lost

    parsed_arg = (char *) malloc (2048); /*allocate memory for parsed arguments*/

    if (argc < 2) { fprintf(stderr,"USAGE: %s port\n", argv[0]); exit(1); } // Check usage & args


    struct sigaction SIGCHLD_action = {0}; //init sigaction struct
	SIGCHLD_action.sa_handler = catchSIGCHLD; //link handler to struct
	sigfillset(&SIGCHLD_action.sa_mask); /*block all signals in mask*/
	SIGCHLD_action.sa_flags = SA_RESTART; /*set restart flag to not have system calls interrupt*/
    sigaction(SIGCHLD, &SIGCHLD_action, NULL);

    //reset all strings to null terminating char to ensure correct value after strcpy, strcat
    memset(username,0,sizeof(username));
    memset(ciphertext,0,sizeof(ciphertext));
    memset(fname,0,sizeof(fname));
    memset(pname,0,sizeof(pname));
    memset(pidstr,0,sizeof(pidstr));

	// Set up the address struct for this process (the server)
	memset((char *)&serverAddress, '\0', sizeof(serverAddress)); // Clear out the address struct
	portNumber = atoi(argv[1]); // Get the port number, convert to an integer from a string
	serverAddress.sin_family = AF_INET; // Create a network-capable socket
	serverAddress.sin_port = htons(portNumber); // Store the port number
	serverAddress.sin_addr.s_addr = INADDR_ANY; // Any address is allowed for connection to this process

	// Set up the socket
	listenSocketFD = socket(AF_INET, SOCK_STREAM, 0); // Create the socket
	if (listenSocketFD < 0) error("ERROR opening socket");

	// Enable the socket to begin listening
	if (bind(listenSocketFD, (struct sockaddr *)&serverAddress, sizeof(serverAddress)) < 0) // Connect socket to port
		error("ERROR on binding");
	if(listen(listenSocketFD, 5) < 0) // Flip the socket on - it can now receive up to 5 connections
        perror("ERROR on listen");
    while (1) 
    {
        // Accept a connection, blocking if one is not available until one connects
        sizeOfClientInfo = sizeof(clientAddress); // Get the size of the address for the client that will connect
        establishedConnectionFD = accept(listenSocketFD, (struct sockaddr *)&clientAddress, &sizeOfClientInfo); // Accept
        if (establishedConnectionFD < 0) error("ERROR on accept");
        //printf("SERVER: Connected Client at port %d\n", ntohs(clientAddress.sin_port));
        spawn_pid = fork(); //fork after accept to create child to service client while parent looks for more clients
        if(spawn_pid == 0)
        {
            /*************************CHILD PROCESS**************************/
            // Get the message from the client and display it
            sleep(2); //sleep 2 for grading script
            memset(buffer, '\0', sizeof(buffer));
            charsRead = recv(establishedConnectionFD, buffer, sizeof(buffer)-1, 0); // Read the client's message from the socket
            if (charsRead < 0) error("ERROR reading from socket");
            //DEBUG PRINT STATEMENT
            //printf("SERVER: I received this from the client: \"%s\"\n", buffer);
            /*parse user input string for args*/
            parsed_arg = strtok(buffer, ",");
            //parse buffer from client to see if GET or POST request, as well as get ciphertext if POST
            while(parsed_arg != NULL)
            {
                /*copy parsed args to args string array*/
                if(parse_count == 0)
                    strcpy(username, parsed_arg); //if first parse save to username
                else
                    strcpy(ciphertext, parsed_arg); //else save to ciphertext
                parsed_arg = strtok(NULL, ","); //parse again
                parse_count++; //increment parse count to determine username vs ciphertext
            }
            free(parsed_arg); //free dyn mem
            //look at parse count and use for determining mode of operation
            if(parse_count == 1)
                post_get_var = GET;
            else if(parse_count == 2)
                post_get_var = POST;
            else
            {
                perror("ERROR unable to determine client request\n"); //catch default state and return error msg
                exit(1);
            }
            //if server is doing POST
            if(post_get_var == POST)
            {
                //if the ciphertext is the error message then assert return flag
                if(!strcmp(ciphertext, error_msg))
                {
                    ret_val = 1;
                }
                else
                {
                    DIR* dir = opendir(username); // try to open username directory 
                    if(dir <= 0) //if dir did not exist
                    {    
                        mkdir(username, 0755); //make directory with correct permissions
                        dir = opendir(username); //open the new dir
                    }
                    if(dir > 0) //if directory is opened
                    {
                        strcpy(fname,username); //copy username to filename
                        sprintf(pidstr, ".%d", getpid()); //get string of pid
                        /*cat with filename*/
                        strcat(fname,pidstr); //cat pid with filename
                        sprintf(pname, "%s/%s", username, fname); //create a path for the file to be opened
                        fp = fopen(pname, "w"); //open new file on path
                        fprintf(fp,"%s\n",ciphertext); //save ciphertext to filename
                        printf("%s\n",pname); //print the path of ciphertext to stdout
                        fclose(fp); // close fp
                        closedir(dir); //close dir
                    }  
                }  
            }
            else if(post_get_var == GET) //if server is in GET state
            {
                strcat(pname, "./"); // need to access file so cat ./ to path name
                strcat(pname,username); //cat username which is also directory name
                ftw(pname, find_oldest, 1); //use the ftw function and defined check_if_older fun
                //DEBUG PRINT STATEMENT
                //printf("SERVER: OLDEST FILE IN DIR: %s\n", oldest);
                if(!access(oldest, F_OK | R_OK )) //see if the oldest file exists and is readable
                {
                    fp = fopen(oldest,"r"); //open oldest file in read mode
                    memset(ciphertext,0,sizeof(ciphertext)); //clear ciphertext
                    fgets(ciphertext,sizeof(ciphertext),fp); //get string into ciphertext from oldest
                    ciphertext[strlen(ciphertext)-1] = 0; //remove newline
                    //DEBUG PRINT STATEMENT
                    //printf("SERVER: send %s to client to decrypt\n", ciphertext);
                    chars_sent=0; //reset chars_sent value
                    while(chars_sent < strlen(ciphertext))
                    {
                        charsRead = send(establishedConnectionFD, ciphertext, sizeof(ciphertext),0);
                        if (charsRead < 0) error("ERROR writing to socket");
                        chars_sent += charsRead; //add chars read value to chars_sent if error is triggered it will resend
                        //initially attempted to use ioctal checksend however did not work concurrently until strlen implementation
                        
                        //ioctl(establishedConnectionFD, TIOCOUTQ, &checkSend);  // Check the send buffer for this socket
                        //printf("SERVER: checkSend: %d\n", checkSend);  // Out of curiosity, check how many remaining bytes there are
                    }
                    fclose(fp); //close file
                    if(remove(oldest)) //remove file
                        perror("ERROR remove failed"); //if remove failed print error
                        //DEBUG PRINT STATEMENT
                        //printf("SERVER: Successfully deleted oldest file in User dir\n");
                }
                else
                {
                    //if file does not exist
                    perror("ERROR no message for inputted user\n");
                    // Send a Success message back to the client
                    charsRead = send(establishedConnectionFD, error_msg, sizeof(error_msg), 0); //send error message
                    if (charsRead < 0) error("ERROR writing to socket");
                    close(establishedConnectionFD); // Close the existing socket which is connected to the client
                    exit(ret_val);
                }
            }
            
            // This send message is NOT PRINTED it is only for the client side to recv so that the messages are printed at the correct time
            // Send a Success message back to the client
            charsRead = send(establishedConnectionFD, "I am the server, and I got your message", 39, 0); // Send success back
            close(establishedConnectionFD); // Close the existing socket which is connected to the client
            exit(ret_val); //return 
        }
        else
        {
            /**********************PARENT PROCESS******************************/
            spawn_pid = child_pid[process_count]; //save pid of children if needed for later use
            process_count++; //increment process count
            if(process_count == 5) //if the process count is equal to 5
            {
                //DEBUG PRINT STATEMENT
                //printf("Concurrent Client Limit Met\n");
                //blocking waitpid so that on the fifth concurrent process another cannot be spawned until completion
                if(!waitpid(spawn_pid, &child_exit_meathod,0))
                    perror("waitpid error\n");
            }
            
        }
        
    }
	close(listenSocketFD); // Close the listening socket
	return 0; 
}


