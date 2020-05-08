#!/bin/bash
gcc -std=c89 -pthread -lpthread -o mores.adventure mores.adventure.c -Wall
if [ $? = 0 ]
then
    ./mores.adventure
fi
