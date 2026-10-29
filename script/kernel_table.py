#!/usr/bin/env python3
import json
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from hwh_map import register_segments

def parse_base_address(raw):
    """Return an int, or None when the IP has no addressable control port.

    Free-running kernels (ap_ctrl_none, no s_axilite) have no AXI4-Lite port, and
    ip_layout.json reports m_base_address as 'not_used' for them. The old code did
    base_address[2:] assuming a '0x' prefix, which turned 'NOT_USED' into 'T_USED'
    and emitted the non-literal 0xT_USED.
    """
    if raw is None:
        return None
    text = str(raw).strip()
    try:
        return int(text, 16) if text.lower().startswith("0x") else int(text, 10)
    except ValueError:
        return None


def generate_header(input_json, output_header, xsa=None, master="M_AXI_FPD"):
    # Load the JSON data from the input file
    with open(input_json, 'r') as file:
        json_data = json.load(file)

    # Prepare the header file content
    header_content = """
#ifndef __KERNEL_TABLE_H__
#define __KERNEL_TABLE_H__

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

    # Generate entries for each IP in JSON. IPs with no addressable control port
    # are left out of the table on purpose: a free-running kernel must never be
    # started from software, so an accidental lookup should fail loudly in
    # find_ip_entry_by_name() rather than hand back a bogus address.
    # The ARM runs this table through /dev/mem, so the address must be the ARM's
    # (M_AXI_FPD) view. ip_layout.json carries whichever view v++ chose -- the host's
    # since the PCIe host can also reach the control interconnect -- so when the linked
    # design's hand-off is available the address is taken from there (hwh_map.py).
    arm_view = register_segments(xsa, master) if xsa else None
    not_addressable = []
    for entry in json_data["ip_layout"]["m_ip_data"]:
        name = entry["m_name"]
        address = parse_base_address(entry.get("m_base_address"))
        if address is None:
            not_addressable.append((name, entry.get("m_base_address")))
            continue
        if arm_view is not None:
            inst = name.split(":")[-1]
            if inst not in arm_view:
                not_addressable.append((name, f"no {master} address in the hand-off (host view 0x{address:X})"))
                continue
            address = arm_view[inst][0]
        header_content += f'    {{"{name}", 0x{address:X}}},\n'

    for name, raw in not_addressable:
        header_content += f'    // omitted, no addressable control port: {name} (m_base_address={raw})\n'

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
    parser.add_argument("--xsa", help="linked design (kernel.xsa or .hwh): take the ARM-view addresses from it")
    parser.add_argument("--master", default="M_AXI_FPD", help="master whose view to use (default M_AXI_FPD = the ARM)")

    args = parser.parse_args()

    # Generate the header file using the provided arguments
    generate_header(args.input_json, args.output_header, args.xsa, args.master)