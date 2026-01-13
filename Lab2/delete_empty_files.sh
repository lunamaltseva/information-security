#!/bin/bash

for file in *; do 
  if [ -s "$file" ]; then
    true 
  else
    echo "$file"  
    rm "$file" 
  fi 
done
