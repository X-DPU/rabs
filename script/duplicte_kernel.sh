#!/bin/bash

# Ensure input file, output file, and duplication count are provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 <input_file> <output_file> <number_of_duplicates>"
    exit 1
fi

input_file=$1
output_file=$2
num_duplicates=$3

# Clear the output file to start fresh
> "$output_file"

# Write the header lines (starting with '[') to the output file only once
awk '/^\[.*\]/ {print}' "$input_file" >> "$output_file"
echo "" >> "$output_file"  # Add a newline after the header section

# Function to duplicate and increment _1 occurrences, excluding headers
duplicate_with_increment() {
    local increment=$1
    awk -v inc="$increment" '
    /^\[.*\]/ {next}  # Skip header lines
    NF {              # Process non-empty lines
        gsub(/_1/, "_" inc);  # Replace _1 with incremented value
        print;
    }
    ' "$input_file"
}

# Run the duplication process
for ((i=1; i<=num_duplicates; i++)); do
    duplicate_with_increment "$i" >> "$output_file"
    echo "" >> "$output_file"  # Add a newline between duplicated sections
done

echo "Content duplicated $num_duplicates times into $output_file."
