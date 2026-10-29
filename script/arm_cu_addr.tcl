# arm_cu_addr.tcl -- v++ post-system-link hook (compiler.userPostSysLinkOverlayTcl, rabs
# phase_hw.mk): give every kernel control slave its ARM-side (CIPS M_AXI_FPD) AND host-side
# (CPM_PCIE_NOC_0/1, PCIe BAR2) addresses explicitly, BEFORE v++ runs its own assign_bd_address.
#
# Why: since the PCIe host also reaches the kernel control interconnect (opendpu shell
# host_m_axi -> platform_interface/S01_AXI, doc/secure-shell.md 6), Vivado's automatic
# assignment can give such a slave an address in only ONE of the two masters' spaces: the
# other one fails with "[BD 41-1743] Cannot assign slave segment ... because no available
# apertures exist" although the apertures are almost empty (reproduced on the bare shell BD
# 2026-10-26, /local_data/xtra/logs/aperture_exp3.log: host path present -> 64 KB slaves get
# the host view only; host path removed -> the ARM view; ARM view pre-assigned -> the host
# view fails). Explicit assignments are accepted for both, so this script does both,
# deterministically: lowest free slot aligned to the segment range, ARM in the first
# M_AXI_FPD aperture (0xA400_0000, 192 MB), host inside the BAR2 window the shell routes
# through the NoC (0x202_0000_0000, 2 MB -- driver/opendpu_nic_main.c ODPU_BAR2_SIZE).
# The hand-off then carries both views: the ARM generators (kernel_table.py --xsa) and the
# device tree use the FPD one (a host-view address in the DT was an SError in the
# opendpu-version service), the host driver takes its map from host_map.py.
#
# Runs inside vpl's create_bd step, after the kernels are instantiated and connected, before
# update_bd/assign_bd_address. It never fails the link: every problem is a WARNING and the
# auto assignment runs as before for whatever is left.

proc odpu_cu_addr_space {sp_name ap_base ap_size} {
    set sp [get_bd_addr_spaces -quiet $sp_name]
    if {$sp eq ""} { puts "arm_cu_addr: no address space $sp_name -- skipped"; return }
    set ap_end [expr {$ap_base + $ap_size}]
    # occupied ranges inside the aperture (shell segments and anything assigned earlier)
    set used {}
    foreach s [get_bd_addr_segs -quiet -of_objects $sp] {
        set off [get_property OFFSET $s]; set rng [get_property RANGE $s]
        if {$off eq "" || $rng eq ""} continue
        if {$off >= $ap_base && $off < $ap_end} { lappend used [list $off [expr {$off + $rng}]] }
    }
    set done 0; set skipped 0
    # kernel control slaves = AXI slaves outside platform_interface hanging off its master pins
    foreach pin [get_bd_intf_pins -quiet -of_objects [get_bd_cells platform_interface] -filter {MODE == Master && VLNV =~ "xilinx.com:interface:aximm_rtl:*"}] {
        set net [get_bd_intf_nets -quiet -of_objects $pin]
        if {$net eq ""} continue
        foreach other [get_bd_intf_pins -quiet -of_objects $net -filter {MODE == Slave}] {
            set cell [get_bd_cells -quiet -of_objects $other]
            if {$cell eq "" || [string match "/platform_interface*" $cell]} continue
            foreach seg [get_bd_addr_segs -quiet -of_objects $other] {
                set cname [get_property NAME $cell]
                if {[get_bd_addr_segs -quiet -of_objects $sp -filter "NAME =~ *${cname}*"] ne ""} { incr skipped; continue }
                set rng [get_property RANGE $seg]
                if {$rng eq "" || $rng <= 0} continue
                set off $ap_base; set placed 0
                while {$off + $rng <= $ap_end} {
                    set clash 0
                    foreach u $used { lassign $u lo hi; if {$off < $hi && $off + $rng > $lo} { set clash 1; set off $hi; break } }
                    if {$clash} { set off [expr {(($off + $rng - 1) / $rng) * $rng}]; continue }
                    if {[catch {assign_bd_address -offset $off -range $rng -target_address_space $sp $seg -force} err]} {
                        puts "WARNING: arm_cu_addr: $seg in $sp_name at [format 0x%X $off]: $err"
                        break
                    }
                    lappend used [list $off [expr {$off + $rng}]]
                    puts [format "arm_cu_addr: %-46s %-30s 0x%X (%d KB)" $seg $sp_name $off [expr {$rng / 1024}]]
                    set placed 1; incr done
                    break
                }
                if {!$placed} { puts "WARNING: arm_cu_addr: no room in $sp_name aperture [format 0x%X $ap_base] for $seg ($rng bytes)" }
            }
        }
    }
    puts "arm_cu_addr: $sp_name: assigned $done kernel control segment(s), $skipped already visible"
}
proc odpu_arm_cu_addr {} {
    odpu_cu_addr_space cips_qdma/cips_0/M_AXI_FPD     0xA4000000    [expr {192 * 1024 * 1024}]
    odpu_cu_addr_space cips_qdma/cips_0/CPM_PCIE_NOC_0 0x20200000000 [expr {2 * 1024 * 1024}]
    odpu_cu_addr_space cips_qdma/cips_0/CPM_PCIE_NOC_1 0x20200000000 [expr {2 * 1024 * 1024}]
}
if {[catch {odpu_arm_cu_addr} err]} { puts "WARNING: arm_cu_addr: $err -- leaving the views to assign_bd_address" }
