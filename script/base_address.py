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


def generate_header(input_json, output_file, xsa=None, master="M_AXI_FPD"):
    # Load the JSON data from the input file
    with open(input_json, 'r') as file:
        json_data = json.load(file)

    # Generate the C header file content
    header_content = "#ifndef IP_LAYOUT_H\n#define IP_LAYOUT_H\n\n// Define base addresses for each module\n"

    # ARM-view addresses from the hand-off when available (see kernel_table.py / hwh_map.py)
    arm_view = register_segments(xsa, master) if xsa else None
    for entry in json_data["ip_layout"]["m_ip_data"]:
        # Process m_name to create a C-style constant name
        name = entry["m_name"].split(":")[1].upper().replace(":", "_").replace(".", "_")
        address = parse_base_address(entry.get("m_base_address"))
        if address is None:
            # free-running kernel: no AXI4-Lite port, so there is no address to define
            header_content += f"// {name}_BASE_ADDR omitted: m_base_address={entry.get('m_base_address')}\n"
            continue
        if arm_view is not None:
            inst = entry["m_name"].split(":")[-1]
            if inst not in arm_view:
                header_content += f"// {name}_BASE_ADDR omitted: no {master} address in the hand-off (host view 0x{address:X})\n"
                continue
            address = arm_view[inst][0]
        header_content += f"#define {name}_BASE_ADDR    0x{address:X}\n"

    header_content += "\n#endif // IP_LAYOUT_H\n"

    # Write the content to the specified output file
    with open(output_file, "w") as file:
        file.write(header_content)

    print(f"Header file '{output_file}' generated successfully!")

if __name__ == "__main__":
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Generate a C header file from a JSON IP layout.")
    parser.add_argument("input_json", help="Path to the input JSON file containing the IP layout.")
    parser.add_argument("output_file", help="Path to the output C header file.")
    parser.add_argument("--xsa", help="linked design (kernel.xsa or .hwh): take the ARM-view addresses from it")
    parser.add_argument("--master", default="M_AXI_FPD", help="master whose view to use (default M_AXI_FPD = the ARM)")

    args = parser.parse_args()

    # Generate the header file using the provided arguments
    generate_header(args.input_json, args.output_file, args.xsa, args.master)