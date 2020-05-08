/****************************************************************************************
*Filename: mores.adventure.c
*Author: Stephen More, 5/3/2020
*Description: Creates a room directory and creates 7 randomized rooms,
*with attributes ROOM NAME, ROOM TYPE, and assigns 3 to 6 random connections to each room.
*****************************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>
#include <pthread.h>
#include <ctype.h>
/*virtual bool enum*/
enum roomTypeEnum {START_ROOM = 1,MID_ROOM = 2,END_ROOM = 3};
typedef unsigned int BOOL;
/*roomValues struct saves all room data*/
/*includes name, an array of outbound connections, number of outbound connections,
room type, room name, and flag indicating player is in room*/
struct roomValues
{
    char roomName[32];
    enum roomTypeEnum roomType;
    int numOutboundConnections;
    int outBoundConnectionsIdx[6];
    BOOL playerFlag;
};
/*declare global variables*/
struct roomValues roomData[7];
int stepsTaken=0;
char pathTakenStr[256];
/*declare mutex variables*/
pthread_t secondaryThreadID;
pthread_mutex_t myMutex = PTHREAD_MUTEX_INITIALIZER;
/*function prototypes*/
void findMostRecentRoomDir(char* newestDirName);
void readRoomDirIntoStruct(char* newestDirName);
void assignIDToRoomNames(char* newestDirName);
BOOL viewPlayerInterface();
void getTime();
void* getTimeWithThread(void* arg);

/*This function finds the previously built room directory with newest timestamp*/
/*This function is almost entirely taken from the CS 344 lecture slides*/
void findMostRecentRoomDir(char* newestDirName)
{
    int newestDirTime = -1; /* Modified timestamp of newest subdir examined */
    char targetDirPrefix[32] = "mores.rooms."; /* Prefix we're looking for */
    memset(newestDirName, '\0', sizeof(newestDirName));

    DIR* dirToCheck; /* Holds the directory we're starting in */
    struct dirent *fileInDir; /* Holds the current subdir of the starting dir */
    struct stat dirAttributes; /* Holds information we've gained about subdir */

    dirToCheck = opendir("."); /* Open up the directory this program was run in */

    if (dirToCheck > 0) /* Make sure the current directory could be opened */
    {
        while ((fileInDir = readdir(dirToCheck)) != NULL) /* Check each entry in dir */
        {
            if (strstr(fileInDir->d_name, targetDirPrefix) != NULL) /* If entry has prefix */
            {
                /*printf("Found the prefex: %s\n", fileInDir->d_name);*/
                stat(fileInDir->d_name, &dirAttributes); /* Get attributes of the entry*/

                if ((int)dirAttributes.st_mtime > newestDirTime) /* If this time is bigger */
                {
                    newestDirTime = (int)dirAttributes.st_mtime;
                    memset(newestDirName, '\0', sizeof(newestDirName));
                    strcpy(newestDirName, fileInDir->d_name);
                }
            }
        }
    }

    closedir(dirToCheck); /* Close the directory we opened */
}
/*reads room Directory data from files to roomValues Struct declared globally*/
void readRoomDirIntoStruct(char* newestDirName)
{
    DIR* roomDir; /* Holds the directory we're starting in */
    struct dirent *fileInDir; /* Holds the current subdir of the starting dir */
    FILE* fp;
    /*line read from file*/
    char lineOfFile[256];
    char pathOfRoomFile[256];
    char roomType[32];
    char roomName[32];
    char lineIdentifier[32];
    char tempBuff[32];
    int roomIdx;
    int i;
    /*set initial outbound connections to 0 so they can be incremented*/
    for(i=0;i<7;i++)
    {
        roomData[i].numOutboundConnections=0;
    }
    /*opens newest directory of built rooms*/
    roomDir = opendir(newestDirName);
    if(roomDir > 0)
    {
        roomIdx=0;
        /*cycles through files in directory*/
        while((fileInDir = readdir(roomDir)) != NULL)
        {
            /*checks to see if the directory is '.' or '..'*/
            if(fileInDir->d_name[0] != '.')
            {
                /*copy path to string to open file*/
                sprintf(pathOfRoomFile, "%s/%s",newestDirName , fileInDir->d_name);
                /*open file for reading*/
                fp = fopen(pathOfRoomFile, "r");
                /*cycle through file*/
                while(fgets(lineOfFile, sizeof(lineOfFile), (FILE*)fp ) != NULL)
                {
                    /*parse lines of file*/
                    sscanf(lineOfFile, "%*s %s %s", lineIdentifier, tempBuff);
                    /*if its TYPE: row*/
                    if((strcmp(lineIdentifier,"TYPE:") == 0 ))
                    {
                        /*if column room type is START set player flag*/
                        if(strcmp(tempBuff,"START_ROOM") == 0 )
                        {
                            roomData[roomIdx].roomType = START_ROOM;
                            roomData[roomIdx].playerFlag = 1;
                        }
                        else if(strcmp(tempBuff,"END_ROOM") == 0 )
                        {
                            roomData[roomIdx].roomType = END_ROOM;
                        }
                        else
                        {
                            roomData[roomIdx].roomType = MID_ROOM;
                        }
                    }
                    /*if third coulmn is not room name (ie is room connection) */
                    else if(!(strcmp(lineIdentifier,"NAME:") == 0 ))
                    {
                        /*save room connection values into struct*/
                        for(i=0;i<7;i++)
                        {
                            /*if the third column matches a roomName*/
                            if(strcmp(roomData[i].roomName,tempBuff) == 0)
                            {
                                /*add connection to current room*/
                                roomData[roomIdx].outBoundConnectionsIdx[roomData[roomIdx].numOutboundConnections] = i;
                                /*increment number of outbound connections for current room*/
                                roomData[roomIdx].numOutboundConnections++;
                                break;
                            }
                        }
                    }
                }
                /*close file*/
                fclose(fp);
                /*set all unconnected slots in current rooms outBoundConnections array to -1*/
                for(i=roomData[roomIdx].numOutboundConnections;i<6;i++)
                {
                    roomData[roomIdx].outBoundConnectionsIdx[i] = -1;
                }
                roomIdx++;
            }
        }
    }
    else
    {
        perror("roomDir was not read");
    }
    /*fclose(fp);*/
}
/*assign room names to indexes*/
void assignIDToRoomNames(char* newestDirName)
{
    /*hardcoded room names*/
    char roomNameList[10][32] = {
    "Dungeon",
    "Marsh",
    "Glacier",
    "Volcano",
    "City",
    "Farm",
    "Taiga",
    "Savannah",
    "Jungle",
    "Mountain"
    };
    DIR* roomDir; /* Holds the directory we're starting in */
    struct dirent *fileInDir; /* Holds the current subdir of the starting dir */
    FILE* fp;
    int roomIdx;
    int i;
    /*open and make sure dir is read from*/
    roomDir = opendir(newestDirName);
    if(roomDir > 0)
    {
        roomIdx=0;
        /*cycle through files*/
        while ((fileInDir = readdir(roomDir)) != NULL)
        {
            /*check to see if filename is '.' or '..'*/
            if(fileInDir->d_name[0] != '.')
            {
                /*cycle through all filenames*/
                for(i=0;i<10;i++)
                {
                    /*if the current file name is the same as index i in roomNameList*/
                    if(strcmp(fileInDir->d_name,roomNameList[i]) == 0)
                    {
                        /*copy filename into roomName in global roomData struct*/
                        strcpy(roomData[roomIdx].roomName, fileInDir->d_name);
                        break;
                    }
                }
                roomIdx++;
            }
        }
    }
}
/*presents player interface and executes turn functions*/
BOOL viewPlayerInterface()
{
    int i = 0;
    int j = 0;
    int k = 0;
    int strSize = 32;
    char* strInput;
    int result;
    int threadCode;
    int threadArg=1;
    int gameFlag=1;
    /*allocate memory for string*/
    strInput = (char*) malloc (strSize);
    /*search for player flag in all rooms*/
    for(i=0;i<6;i++)
    {
        if( roomData[i].playerFlag == 1)
        {
            break;
        }
    }
    /*print current room and all possible room connections*/
    printf("CURRENT LOCATION: %s\n", roomData[i].roomName);
    printf("POSSIBLE CONNECTIONS: ");
    for(j=0;j<roomData[i].numOutboundConnections;j++)
    {
        printf("%s", roomData[roomData[i].outBoundConnectionsIdx[j]].roomName);
        /*if not last entry print comma afterwards*/
        if(j!=(roomData[i].numOutboundConnections-1))
            printf(", ");
    }
    /*end with period and prompt*/
    printf(".\nWhere To? >");
    /*get user input into dynamically allocated strInput through stdin*/
    result = getline(&strInput, &strSize, stdin);
    /*if read correctly*/
    if(result != -1)
    {
        /*delete newline char from strInput*/
        strInput[strlen(strInput)-1] = 0;
        /*cycle through from 0 to number of outbound connections for current room*/
        /*cycling through all of the possible outbound connections for current room*/
        for(j=0;j<roomData[i].numOutboundConnections;j++)
        {
            /*if user entered "time" command*/
            if((strcmp(strInput, "time") == 0))
            {
                /*unlock mutex with main thread, this causes getTime() to be called*/
                pthread_mutex_unlock(&myMutex);
                /*wait until thread finishes executing*/
                threadCode = pthread_join(secondaryThreadID, NULL);
                /*lock mutex with main thread again*/
                pthread_mutex_lock(&myMutex);
                /*create a new thread which will wait until the main thread mutex is unlocked*/
                threadCode = pthread_create(&(secondaryThreadID), NULL, getTimeWithThread, (void *) &threadArg);
                break;
            }
            /*if string input is equal to the roomName of any possible connection to current room*/
            else if( (strcmp(strInput, roomData[roomData[i].outBoundConnectionsIdx[j]].roomName) == 0))
            {
                printf("\n");
                /*set player flag of current room to 0*/
                roomData[i].playerFlag = 0;
                /*set player flag of next room to 1*/
                roomData[roomData[i].outBoundConnectionsIdx[j]].playerFlag = 1; 
                /*increment stepsTaken global*/
                stepsTaken++;
                /*add next room to player path taken string*/
                strcat(pathTakenStr,"\n");
                strcat(pathTakenStr,roomData[roomData[i].outBoundConnectionsIdx[j]].roomName);
                /*if the next room is the last room set gameFlag to 0*/
                if(roomData[roomData[i].outBoundConnectionsIdx[j]].roomType == END_ROOM)
                {
                    gameFlag = 0;
                }
                break;
            }
            else
            {
                if(j == roomData[i].numOutboundConnections-1)
                {
                    printf("\nHUH? I DON’T UNDERSTAND THAT ROOM. TRY AGAIN.\n\n");
                    break;
                }
            }
        }    
    }
    /*free memory in strInput and return the game flag for turn*/
    free(strInput);
    return gameFlag;
}
/*get current time in format Ex. 10:02pm, Friday, May 1, 2020"*/
void getTime()
{
    FILE *fp;
    char strTime[256];
    __time_t currentTime;
    struct tm *temp;
    /*assign current time to time data type*/
    time(&currentTime);
    temp = localtime(&currentTime);
    /*if temp is NULL then print error*/
    if(temp == NULL)
    {
        perror("FAILED TO READ TIME");
    }
    /*format date and time*/
    strftime(strTime, sizeof(strTime), "%l:%M%P, %A, %B%e, %Y", temp);
    printf("\n%s\n\n", strTime);
    /*print time to currenTime.txt*/
    fp = fopen("currentTime.txt", "w");
    /*write time to currenTime.txt file*/
    fprintf(fp, "%s\n", strTime);
    fclose(fp);
}
/*function called when thread is generated, manages second thread mutex locks*/
void* getTimeWithThread(void* arg)
{
    /*passed in val and id are not needed in this case but wanted to keep in case of more than 2 threads*/
    int passedInVal;
    pthread_t id;
    passedInVal = *((int *) arg);
    /*check current threadID*/
    id = pthread_self();
    /*locks mutex with second thread*/
    pthread_mutex_lock(&myMutex);
    /*once the main thread unlocks mutex second thread locks and executes getTime()*/
    getTime();
    /*unlocks mutex with second thread*/
    pthread_mutex_unlock(&myMutex);
    return NULL;
}

int main()
{
    char newestDirName[256];
    int playerCurrentRoom;
    BOOL gameFlag=1;
    int gameReturnCode = -1;
    int errorCode;
    int threadArg=0;
    /*find the most recently created rooms directory*/
    findMostRecentRoomDir(newestDirName);
    /*assign indexes to room names*/
    assignIDToRoomNames(newestDirName);
    /*reads all room files in newest directory into struct*/
    readRoomDirIntoStruct(newestDirName);
    /*Lock mutex w/ main thread*/
    pthread_mutex_lock(&myMutex);
    /*Create second thread*/
    errorCode = pthread_create(&(secondaryThreadID), NULL, getTimeWithThread, (void *) &threadArg);
    /*if the thread was not created send error message*/
    if(errorCode != 0)
    {
        perror("Second thread was not able to be created!");
        return 1;
    }
    /*call viewPlayerInterface until the player wins the game*/
    while(gameFlag == 1)
    {
        gameFlag = viewPlayerInterface();
    }
    /*print out victory message in correct format*/
    strcat(pathTakenStr,"\n");
    printf("YOU HAVE FOUND THE END ROOM. CONGRATULATIONS!\n");
    printf("YOU TOOK %d STEPS. YOUR PATH TO VICTORY WAS:%s", stepsTaken, pathTakenStr);
    /*return 0 if code makes it to the end successfully*/
    gameReturnCode = 0;
    return gameReturnCode;
}