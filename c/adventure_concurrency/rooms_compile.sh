#!/bin/bash
gcc -std=c89 -o mores.buildrooms mores.buildrooms.c
if [ $? = 0 ]
then
    ./mores.buildrooms
fi
