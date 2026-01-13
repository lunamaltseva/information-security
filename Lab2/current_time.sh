#!/bin/bash

echo "Current time: $(date +%H:%M:%S)"
echo "Work day ends at: $(date +%H:%M:%S -d 'At 7AM')"
