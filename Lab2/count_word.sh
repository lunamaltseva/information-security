#!/bin/bash

read -p "Enter file path: " path
read -p "Enter search pattern: " pattern

count=0

for word in $(cat "$path"); do
  if [ "$word" == "$pattern" ]; then
    count=$((count + 1))
  fi
done

echo "Total count: $count"

