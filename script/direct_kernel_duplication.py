#!/usr/bin/env python3
import re
import argparse

def extract_kernel_names(config_file):
    """
    Extract unique kernel names from the config file (those following 'nk=<class>:<version>:<kernel_name>').
    """
    kernel_names = set()  # Set to ensure uniqueness
    kernel_pattern = r"nk=[^:]+:[^:]+:([^\s]+)"
    
    with open(config_file, 'r') as file:
        content = file.readlines()

    # Extract all unique kernel names using regex
    for line in content:
        matches = re.findall(kernel_pattern, line)
        if matches:
            kernel_names.update(matches)
    
    return sorted(kernel_names)  # Sorting for better readability

def duplicate_kernel_lines(config_file, kernel_names, num_duplications, output_file):
    """
    Duplicate lines containing kernel names from the config file.
    Each kernel name in the line will be replaced with _1, _2, etc.
    """
    # Read the config file
    with open(config_file, 'r') as file:
        content = file.readlines()

    # Open output file to write the duplicated config
    with open(output_file, 'w') as out_file:
        for line in content:
            # Check if the line contains any of the extracted kernel names
            line_duplicated = False
            kernels  = []
            for kernel_name in kernel_names:
                if kernel_name in line:
                    kernels.append(kernel_name)
                    line_duplicated = True
            # For each kernel name, create the necessary number of duplications
            
            print(kernels)
            for i in range(num_duplications):
                new_line = line
                for avaiable_kernel in kernels:
                    new_line = new_line.replace(avaiable_kernel, f"{avaiable_kernel}_{i + 1}")
                if line_duplicated:
                    out_file.write(new_line)
                
            
            # If no kernel name was found, write the line as-is
            if not line_duplicated:
                out_file.write(line)

    print(f"Duplicated config file saved to {output_file}")

def main():
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="Duplicate lines with kernel names in the config file.")
    parser.add_argument('config_file', type=str, help="Path to the config file.")
    parser.add_argument('num_duplications', type=int, help="Number of duplications for each kernel.")
    parser.add_argument('output_file', type=str, help="Path to the output config file.")
    args = parser.parse_args()

    # Extract kernel names from the config file
    kernel_names = extract_kernel_names(args.config_file)
    print(f"Extracted kernel names: {kernel_names}")

    # Duplicate kernel lines and save to the new file
    duplicate_kernel_lines(args.config_file, kernel_names, args.num_duplications, args.output_file)

if __name__ == "__main__":
    main()