#!/bin/bash

if [ $# == 0 ]
then
    echo "error: need a task file!"
    exit 1
fi

for repo in `cat $1`
do
    printf "%-100s" $repo
    if svnadmin verify -q $repo
    then
        echo "yes"
    else
        echo "no"
    fi
done

