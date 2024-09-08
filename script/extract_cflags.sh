#!/bin/bash


# Read the contents of the cflags file
CFLAGS=$(cat $1)

# Extract all -D and -I flags (with or without a space after -I)
EXTRACTED_FLAGS=$(echo "$CFLAGS" | grep -oE '(-D[^ ]+|-I ?[^ ]+)' | tr '\n' ' ')

# Print the extracted flags
echo "$EXTRACTED_FLAGS" > $2