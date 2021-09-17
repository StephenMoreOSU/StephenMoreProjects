#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h> 
#include <wait.h>
#include <sys/ioctl.h>

//define macros
#define POST 0
#define GET 1
#define error_msg "!ERROR!"

char global_cipher[1024]; //for saving ciphertext generated via encryption function

void error(const char *msg) { perror(msg); exit(0); } // Error function used for reporting issues
//function protoypes
int encrypt(char plaintext_filename[128], char key_filename[128]);
int decrypt(char ciphertext_filename[128], char key_filename[128]);


int main(int argc, char *argv[])
{
	int socketFD, portNumber, charsWritten, charsRead, post_get_var=-1;
	struct sockaddr_in serverAddress;
	struct hostent* serverHostInfo;
	char buffer[2048]; //buffer used to send and rx data
    char command[8], user[32], plaintext_filename[128], key_filename[128]; //strings for filenames, usernames, ciphertext
    int retval; //return val variable
    
	if (argc < 3) { fprintf(stderr,"USAGE: %s get/post user (plaintext) key port\n", argv[0]); exit(0); } // Check usage & args
    
    //save command line arguments and validate
    //clear mem of strings
    memset(command,0,sizeof(command));
    memset(user,0,sizeof(user));
    memset(key_filename,0,sizeof(key_filename));
    memset(global_cipher,0,sizeof(global_cipher));
    memset(buffer,0,sizeof(buffer));
    //copy args into strings
    strcpy(command,argv[1]);
    strcpy(user,argv[2]);
    //User will always be sent regardless of mode
    strcat(buffer,user); //concatenate user name into buffer
    if(!strcmp(command, "post")) //if in post mode
    {  
        if (argc < 6) { fprintf(stderr,"USAGE: %s get/post user (plaintext) key port\n", argv[0]); exit(0); } // Check usage & args
        //clear filename str
        memset(plaintext_filename,0,sizeof(plaintext_filename));
        strcpy(plaintext_filename, argv[3]); //save post specific strings
        strcpy(key_filename, argv[4]);
        portNumber = atoi(argv[5]); // Get the port number, convert to an integer from a string
        retval = encrypt(plaintext_filename, key_filename); //encrypt plaintext and return error val
        if(retval)
        {
            strcpy(global_cipher, error_msg); //if error val returned replace cipher message with error_msg
        }
        strcat(buffer,","); //add , at end of stream to delim
        strcat(buffer,global_cipher); //finialize buffer
        post_get_var = POST; //set var to POST
    }
    else if(!strcmp(command, "get")) //of in GET mode
    {
        //make sure number of args is correct
        if (argc < 5) { fprintf(stderr,"USAGE: %s get/post user (plaintext) key port\n", argv[0]); exit(0); } // Check usage & args
        strcpy(key_filename, argv[3]); //copy key_filename into str
        portNumber = atoi(argv[4]); // Get the port number, convert to an integer from a string
        post_get_var = GET; //set var to GET mode
    }
    strcat(buffer,","); //add final , for delimination
    strcat(buffer,"\0"); //add NULL term char

    // Set up the server address struct
	memset((char*)&serverAddress, '\0', sizeof(serverAddress)); // Clear out the address struct
	serverAddress.sin_family = AF_INET; // Create a network-capable socket
	serverAddress.sin_port = htons(portNumber); // Store the port number
	serverHostInfo = gethostbyname("localhost");//gethostbyname(argv[1]); // Convert the machine name into a special form of address
	if (serverHostInfo == NULL) { fprintf(stderr, "CLIENT: ERROR, no such host\n"); exit(0); }
	memcpy((char*)&serverAddress.sin_addr.s_addr, (char*)serverHostInfo->h_addr, serverHostInfo->h_length); // Copy in the address

	// Set up the socket
	socketFD = socket(AF_INET, SOCK_STREAM, 0); // Create the socket
	if (socketFD < 0) error("CLIENT: ERROR opening socket");
	
	// Connect to server
	if (connect(socketFD, (struct sockaddr*)&serverAddress, sizeof(serverAddress)) < 0) // Connect socket to address
		error("CLIENT: ERROR connecting");
	// Send message to server
	charsWritten = send(socketFD, buffer, sizeof(buffer), 0); // Write to the server
	if (charsWritten < 0) error("CLIENT: ERROR writing to socket");
	if (charsWritten < strlen(buffer)) printf("CLIENT: WARNING: Not all data written to socket!\n");
    // Get return message from server
    memset(buffer, '\0', sizeof(buffer)); // Clear out the buffer again for reuse
    charsRead = recv(socketFD, buffer, sizeof(buffer) - 1, 0); // Read data from the socket, leaving \0 at end
    if (charsRead < 0) error("CLIENT: ERROR reading from socket");
    //DEBUG PRINT
    //printf("CLIENT: I received this from the server: \"%s\"\n", buffer);

    if(post_get_var == GET && (strcmp(buffer,error_msg)))
    {    
        //DEBUG PRINT
        //printf("CLIENT: Decrypting ciphertext from server...\n");
        decrypt(buffer, key_filename);
    }
    close(socketFD); // Close the socket
	return 0;
}

/***************************************************************************************
 * function: encrypt
 * desc: This function takes the filenames for the plaintext and key and first checks to make sure
 * the files are in the correct format, if the format is wrong it will return with a error_flag 
 * which will make it so an error message is sent to the server, which responds accordingly by not doing
 * anything with the client sending the error. If the plaintext is correctly formatted, the function
 * will use the key to encrypt the data and send it to global_ciphertext string
 * *************************************************************************************/
int encrypt(char plaintext_filename[128], char key_filename[128])
{
    int i=0; //index
    FILE* key_fp; //file pointers
    FILE* plaintext_fp; 
    int mid, numeric; //variables to store numeric representations of chars
    char key_c, plaintext_c; //chars taken from fps
    char ciphertext[1024]; //ciphertext string 
    char plaintext_line[1024], key_line[1024]; //lines taken from files for error checking
    int ret_flag=0; //ret flag for error return
    memset(ciphertext,0,sizeof(ciphertext)); // clear buffer
    //ERROR CHECKING POST INPUT
    key_fp = fopen(key_filename, "r"); //open files in read mode
    plaintext_fp = fopen(plaintext_filename, "r");
    fgets(plaintext_line,sizeof(plaintext_line),plaintext_fp); //get line of each file
    fgets(key_line,sizeof(key_line),key_fp);
    plaintext_line[strlen(plaintext_line)-1] = 0; //remove newline
    if(strlen(plaintext_line) > strlen(key_line)) //compare to see if the key is of proper size
    {
        perror("ERROR Key is smaller than plaintext please make a larger key\n");
        ret_flag = 1; //assert ret flag
    }
    for(i=0;i<strlen(plaintext_line)-1;i++) //make sure there are no invalid chars in plaintext line (except newline at end)
    {
        if((plaintext_line[i] > 90 || plaintext_line[i] < 65) && plaintext_line[i] != ' ') //if char is NOT A-Z or space throw error
        {
            fprintf(stderr, "ERROR Invalid characters in \'%s\' file\n", plaintext_filename);
            ret_flag = 1;
            break;
        }
    }
    //close files
    fclose(key_fp);
    fclose(plaintext_fp);
    if(ret_flag)
    {
        return 1; //return with error code
    }
    key_fp = fopen(key_filename, "r"); //re open files for encryption processing
    plaintext_fp = fopen(plaintext_filename, "r");
    i=0;
    while(1)
    {
        //get chars from each file
        key_c = fgetc(key_fp);
        plaintext_c = fgetc(plaintext_fp);
        //if char is newline break
        if(feof(plaintext_fp) || plaintext_c == '\n')
            break;
        if(key_c == ' ') //if key is space change val to 26 instead of 32
            key_c = 26;
        else
            key_c = key_c - 65; //subtract 65 from all key vals (should get to 0-25)
        if(plaintext_c >= 65 && plaintext_c <= 90) //if char is valid change to 0-25 range
            numeric = (plaintext_c - 65);
        else if(plaintext_c == ' ') //make same transformation with plaintext space from 32 to 26
            numeric = 26;
        mid = (numeric + key_c) % 27; //modulo added plaintext and key with 27
        if(mid == 26) //adjust for spaces
            ciphertext[i] = ' ';
        else
            ciphertext[i] = 65 + mid; //save to ciphertext buffer
        i++;
    }
    //DEBUG PRINT
    //printf("%s\n",ciphertext);
    strcpy(global_cipher,ciphertext); //copy to global cipher
    fclose(key_fp); //close files
    fclose(plaintext_fp);
    return 0;
}


/***************************************************************************************
 * function: decrypt
 * desc: This function takes the string and filename of key and returns a plaintext version of
 * the cipher using the key provided, plaintext is printed to stdout.
 * *************************************************************************************/
int decrypt(char buffer[2048], char key_filename[128])
{
    int i = 0;
    FILE* key_fp;
    char key_c, ciphertext_c; //chars read in
    int numeric; //numeric representation of chars
    char plaintext[1024]; //plaintext buffer
    memset(plaintext,0,sizeof(plaintext)); //clear buffer

    key_fp = fopen(key_filename, "r"); // open key file
    i=0;
    while(i<strlen(buffer)) //while index is less than the length of ciphertext buffer
    {
        key_c = fgetc(key_fp); //get key char
        if(key_c == ' ') //adjust space for 0-26 range
            key_c = 26;
        else
            key_c = key_c - 65;
        ciphertext_c = buffer[i];
        if((ciphertext_c > 90 || ciphertext_c < 65) && ciphertext_c != ' ')
            break;
        if(ciphertext_c == ' ') //adjust space for 0-26 range
            ciphertext_c = 26;
        else
            ciphertext_c = ciphertext_c - 65; //adjust chars for 0-25 range
        numeric = ciphertext_c - key_c; //subtract key from ciphertext to decry
        if(numeric < 0)
            numeric = numeric + 27; //if subtraction has negative result add 27
        else
            numeric = numeric % 27; //mod 27 to get original chars
        if(numeric == 26) //decrypt ' '
            plaintext[i] = ' ';
        else
            plaintext[i] = numeric + 65;
        i++;
    }
    printf("%s\n",plaintext); //output to stdout    
    fclose(key_fp);
    return 0;
}