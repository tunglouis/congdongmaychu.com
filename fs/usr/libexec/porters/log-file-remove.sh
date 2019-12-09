#!/bin/bash

args=("$@")

for i in "${args[@]}"
do
    ls -t1 /var/log/$i'-'*|tail -n1|xargs rm -f
done

