#!/usr/bin/env python3
import json
import argparse

def generate_header(input_json, output_header):
    # Load the JSON data from the input file
    with open(input_json, 'r') as file:
        json_data = json.load(file)

    # Prepare the header file content
    header_content = """
#ifndef __IP_TABLE_H__
#define __IP_TABLE_H__

#include <stdint.h>
#include <string.h>


// Define the structure for each IP entry
typedef struct {
    const char *name;
    uint64_t base_address;
} ip_entry_t;

// Define all entries based on the JSON data
static ip_entry_t ip_entries[] = {
"""

    # Generate entries for each IP in JSON
    for entry in json_data["ip_layout"]["m_ip_data"]:
        name = entry["m_name"]
        base_address = entry["m_base_address"].upper()
        header_content += f'    {{"{name}", 0x{base_address[2:]}}},\n'

    header_content += """
};

// Define the number of entries for traversal
#define IP_ENTRY_COUNT (sizeof(ip_entries) / sizeof(ip_entry_t))

// Function to find an IP entry by name
static ip_entry_t* find_ip_entry_by_name(const char *name) {
    for (int i = 0; i < IP_ENTRY_COUNT; i++) {
        if (strcmp(ip_entries[i].name, name) == 0) {
            return &ip_entries[i];
        }
    }
    return NULL; // Return NULL if no match is found
}

#endif // __IP_TABLE_H__
"""

    # Write the content to the specified output file
    with open(output_header, "w") as file:
        file.write(header_content)

    print(f"Header file '{output_header}' generated successfully!")

if __name__ == "__main__":
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Generate a C header file from a JSON IP layout.")
    parser.add_argument("input_json", help="Path to the input JSON file containing the IP layout.")
    parser.add_argument("output_header", help="Path to the output C header file.")

    args = parser.parse_args()

    # Generate the header file using the provided arguments
    generate_header(args.input_json, args.output_header)