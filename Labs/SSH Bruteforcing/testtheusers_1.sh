#!/bin/bash
# Author: Gresa Hisa
# Cross-reference extracted usernames against /etc/passwd

while read user; do
    if grep -q "^$user:" /etc/passwd; then
        echo "EXISTS: $user"
    else
        echo "NOT FOUND: $user"
    fi
done < abc.txt
