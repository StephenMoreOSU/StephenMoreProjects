#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

void main(int argc, char* argv[] )
{
    if((argc == 2) && (argc > 0) )
    {
        int i=0;
        int keysize = atoi(argv[1]);
        char key[keysize+1];
        srand(time(0));
        memset(key, 0, sizeof(key));
        for(i=0;i<keysize;i++)
        {
            key[i] = 65 + (rand() % 27);
            if(key[i] == 91)
                key[i] = 32;
        }
        strcat(key,"\n");
        printf("%s", key);
    }
}