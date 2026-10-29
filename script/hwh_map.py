#!/usr/bin/env python3
"""hwh_map.py -- register-segment addresses of the linked design as ONE master sees them.

    from hwh_map import register_segments
    segs = register_segments("build_dir_x/kernel.xsa", "M_AXI_FPD")   # {instance: (base, high)}

Reads the top-level hardware hand-off (inside the v++ kernel.xsa, or a bare .hwh) and
returns every REGISTER slave segment reachable from `master`, keyed by cell instance.

Why: ip_layout.json's m_base_address is whatever view v++ put into the xclbin's IP_LAYOUT.
Since the shell lets the PCIe host reach the kernel control interconnect as well
(doc/secure-shell.md section 6), that is the HOST view (0x202_000x_xxxx), and the ARM must
not use it: the ARM (CIPS M_AXI_FPD) sees the same registers at 0xA4xx_xxxx. 2026-10-26 the
ARM version service took the host-view address from the device tree and died with an
SError. The ARM-side generators (kernel_table.py, base_address.py) therefore take the
address from the hand-off with master M_AXI_FPD; host_map.py does the same for the host
with CPM_PCIE_NOC_0.
"""
import re, sys, zipfile


def read_hwh(path):
    if path.endswith('.hwh'):
        return open(path, 'r', errors='replace').read()
    with zipfile.ZipFile(path) as z:
        names = [n for n in z.namelist() if n.endswith('.hwh') and '/' not in n.strip('/')]
        if not names:
            names = [n for n in z.namelist() if n.endswith('.hwh')]
        if not names:
            sys.exit(f"{path}: no .hwh inside")
        names.sort(key=lambda n: z.getinfo(n).file_size, reverse=True)   # top level = largest
        return z.read(names[0]).decode('utf-8', errors='replace')


def register_segments(path, master):
    """{instance: (base, high)} of the REGISTER segments `master` can reach (lowest base per cell)."""
    hwh = read_hwh(path)
    rx = re.compile(r'<MEMRANGE\s+([^>]*)/>')
    attr = re.compile(r'(\w+)="([^"]*)"')
    segs = {}
    for m in rx.finditer(hwh):
        a = dict(attr.findall(m.group(1)))
        if a.get('MASTERBUSINTERFACE') != master or a.get('MEMTYPE') != 'REGISTER':
            continue
        inst = a.get('INSTANCE', '')
        base, high = int(a['BASEVALUE'], 16), int(a['HIGHVALUE'], 16)
        if inst not in segs or base < segs[inst][0]:
            segs[inst] = (base, high)
    return segs


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit("usage: hwh_map.py <kernel.xsa|.hwh> <master>")
    for inst, (b, h) in sorted(register_segments(sys.argv[1], sys.argv[2]).items(), key=lambda kv: kv[1]):
        print(f"0x{b:010X}-0x{h:010X} {inst}")
