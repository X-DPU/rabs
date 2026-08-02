#!/usr/bin/env python3
import json
import argparse

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


def generate_header(input_json, output_file):
    # Load the JSON data from the input file
    with open(input_json, 'r') as file:
        json_data = json.load(file)

    # Generate the C header file content
    header_content = "#ifndef IP_LAYOUT_H\n#define IP_LAYOUT_H\n\n// Define base addresses for each module\n"

    for entry in json_data["ip_layout"]["m_ip_data"]:
        # Process m_name to create a C-style constant name
        name = entry["m_name"].split(":")[1].upper().replace(":", "_").replace(".", "_")
        address = parse_base_address(entry.get("m_base_address"))
        if address is None:
            # free-running kernel: no AXI4-Lite port, so there is no address to define
            header_content += f"// {name}_BASE_ADDR omitted: m_base_address={entry.get('m_base_address')}\n"
            continue
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

    args = parser.parse_args()

    # Generate the header file using the provided arguments
    generate_header(args.input_json, args.output_file)