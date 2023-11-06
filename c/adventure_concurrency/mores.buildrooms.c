/****************************************************************************************
*Filename: mores.buildrooms.c
*Author: Stephen More, 5/3/2020
*Description: Creates a room directory and creates 7 randomized rooms,
*with attributes ROOM NAME, ROOM TYPE, and assigns 3 to 6 random connections to each room.
*****************************************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "assert.h"
/*for virtual bool value*/
typedef unsigned int BOOL;

/*enum for roomType value*/
enum roomTypeEnum {START_ROOM = 1,MID_ROOM = 2,END_ROOM = 3};
/*array to store randomized room names*/
char roomNames[10][32] = {"","","","","","","","","",""};
/*array to store static room names*/
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

/*array to store roomTypes*/
enum roomTypeEnum roomTypes[7];
/* number of connections by room */
int numConnections[7];
int roomsInOrderOfConnections[7];
int roomConnection[7][6];
int room;
int orderIdx;
int checkVal;
int connIdx;
int checkConnIdx;
/*int checkOrderIdx; */
int checkRoom;
int found;
/* random room list */
int randomRoom[7];
int randomRoomIdx;
int i;
/* generate a random list of rooms */
/* randomRoom[7] */
void genRandomRooms()
{
	int i, j, k, temp;

	/* fill in order */
	for (i = 0; i < 7; i++)
	{
		randomRoom[i] = i;
	}
	/* shuffle */
	for (i = 0; i < 100; i++)
	{
		j = rand() % 7;
		k = i % 7;
		temp = randomRoom[k];
		randomRoom[k] = randomRoom[j];
		randomRoom[j] = temp;
	}
}

/* delete room from random rooms */
void delFromRandomRooms(int thisRoom)
{
	for (i = 0; i < 7; i++)
	{
		if (randomRoom[i] == thisRoom)
		{
			randomRoom[i] = -1;
		}
	}

}


#if 0
void assignConnections()
{
  int i;
  int roomIdx;
  int connectionIdx;
  int connectedRoomIdx;
  int numConnections;
  __time_t t;
  srand((unsigned) time(&t));

  roomIdx=0;


  /*Assign Room Connections*/
  while(roomIdx<7)
  {
    for(i=0;i<6;i++)
    {
      roomData.outBoundConnectionsIdx[i] = -1; 
    }
    
    numConnections = 3 + rand() % 4;
    connectionIdx = 0;
    while(connectionIdx < numConnections)
    {
      connectedRoomIdx = rand() % 7;
      if(roomData.outBoundConnectionsIdx[connectionIdx] == -1 );
        connectionIdx++;
    }
  }
}
#endif

#if 1
/*Assigns room names and roomtypes randomly with 1 START_ROOM and 1 END_ROOM*/
void assignRoomValues()
{
  
  int count;
  __time_t t;
  int randNum;
  int i = 0;

  srand((unsigned) time(&t));
  /*Assign Room Names*/
  count=0;
  /*Places all 10 of room names into roomNames randomly*/
  while(count<10)
  {
    randNum = rand() % 10;
    if(strcmp(roomNames[randNum],"") == 0)
    {
      strcpy(roomNames[randNum],roomNameList[count]);
      count++;
    }
  }
  /*Assign Start Room*/
  randNum = rand() % 7;
  roomTypes[randNum] = START_ROOM;
  /*roomData[randNum].roomType = START_ROOM;*/
  /*Assign End Room*/
  count=0;
  while(count==0)
  {
    randNum = rand() % 7;
    if(roomTypes[randNum] == START_ROOM)
      break;
    roomTypes[randNum] = END_ROOM;
    count++;
  }
  /*Assign Mid Rooms*/
  count=0;
  while(count<7)
  {
    if(!(roomTypes[count] == START_ROOM || roomTypes[count] == END_ROOM))
      roomTypes[count] = MID_ROOM;
      count++;
  }
  count=0;
}
#endif




int main()
{
	int result;
	char pname[32];
	char fname[32] = "mores.rooms";
	char pidstr[10];
	int i = 0;
	FILE *fp;
	
	assignRoomValues();

  	/* random seed */
	srand((unsigned int) time(NULL));   

	/* clear all connections */
	for (room = 0; room < 7; room++)
	{
		for (connIdx = 0; connIdx < 6; connIdx++)
		{
			roomConnection[room][connIdx] = -1;
		}
	}

	/* assign each room # of connections */
	for(room = 0; room<7; room++)
	{
		numConnections[room] = 3 + rand() % 4;
	}

#if 0
	/* sort by # of connections */
	orderIdx = 0;
	for (checkVal = 3; checkVal < 7 && orderIdx < 7; checkVal++)
	{
		for(room=0;room < 7;room++)
		{
			if (numConnections[room] == checkVal)
			{
				roomsInOrderOfConnections[orderIdx] = room;
				orderIdx++;
			}
		}
	}
#endif

	/* assign random connections in order least to most, no self, no dupes */
	for (room = 0; room < 7; room++)
	{
		/* assign connections */
		genRandomRooms();
		/* remove this room as a connection option */
		delFromRandomRooms(room);
		randomRoomIdx = 0;
		for (connIdx = 0; connIdx < numConnections[room]; connIdx++)
		{
			/* check if connection entry empty */
			if (roomConnection[room][connIdx] == -1)
			{
				/* find next available random room */
				while (randomRoom[randomRoomIdx] == -1)
				{
					randomRoomIdx++;
					assert(randomRoomIdx < 7);
				}
				roomConnection[room][connIdx] = randomRoom[randomRoomIdx];
				randomRoomIdx++;
			}
			else
			{
				/* not empty, so remove from connection options */
				delFromRandomRooms(roomConnection[room][connIdx]);
			}
		}
		/* add return connections if needed */

		/* for all rooms connected to this one */
		for (connIdx = 0; connIdx < numConnections[room]; connIdx++)
		{
			checkRoom = roomConnection[room][connIdx];
			/* by check room connection */
			found = 0;
			for (checkConnIdx = 0; checkConnIdx < numConnections[checkRoom]; checkConnIdx++)
			{
				/* check for back connection */
				if (roomConnection[checkRoom][checkConnIdx] == -1)
					break;
				if (roomConnection[checkRoom][checkConnIdx] == room)
				{
					found = 1;
					break;
				}
			}
			/* if not found and add back connection */
			if (!found)
			{
				/* if all full */
				if (checkConnIdx == numConnections[checkRoom])
				{
					/* add connection */
					numConnections[checkRoom]++;
				}
				roomConnection[checkRoom][checkConnIdx] = room;
			}
		}
	}

#if 0
	/* print rooms and connections */
	for (room = 0; room < 7; room++)
	{
		std::cout << "Room " << room << "  Connections " << numConnections[room] << "\n";
		for (connIdx = 0; connIdx < 6; connIdx++)
		{
			std::cout << roomConnection[room][connIdx] << " ";
		}
		std::cout << "\n";
	}
#endif
#if 0
	/* print rooms and connections in order */
	printf("\nRooms in order of connections:\n");
	for (room = 0; room < 7; room++)
	{
    printf("Room: %d # of Connections: %d numConnections[room]  ", room, numConnections[room]);
		/*std::cout << "Room " << room << " # of Connections " << numConnections[room] << "    ";*/
		for (connIdx = 0; connIdx < 6; connIdx++)
		{
			if(roomConnection[room][connIdx] != -1)
				printf("%d  ", roomConnection[room][connIdx]);
        /*std::cout << roomConnection[room][connIdx] << " ";*/
		}
		printf("\n");
	}
#endif
	/*get string of PID*/
	sprintf(pidstr, ".%d", getpid());
	/*cat with filename*/
	strcat(fname,pidstr);
	/*make directory with correct permissions*/
	result = mkdir(fname, 0755);
	/*cycle through rooms*/
	for(room=0; room<7; room++)
	{
		/*create path for files*/
		sprintf(pname, "%s/%s", fname,roomNames[room]);
		/*create and open rooms*/
		fp = fopen(pname, "w");
		/*print room data*/
		fprintf(fp, "ROOM NAME: %s\n", roomNames[room]);
		for(connIdx = 0; connIdx < 6; connIdx++)
		{
			if(roomConnection[room][connIdx] != -1)
				fprintf(fp, "CONNECTION %d: %s\n", (connIdx+1), roomNames[roomConnection[room][connIdx]]);
		}
		if(roomTypes[room] == 1)
			fprintf(fp, "ROOM TYPE: %s\n", "START_ROOM");
		else if (roomTypes[room] == 3)
			fprintf(fp, "ROOM TYPE: %s\n", "END_ROOM");
		else
			fprintf(fp, "ROOM TYPE: %s\n", "MID_ROOM");
		/*close file*/
		fclose(fp);
	}
}