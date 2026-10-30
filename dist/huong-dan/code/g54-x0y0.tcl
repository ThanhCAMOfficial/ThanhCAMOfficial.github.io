# ThanhCAM — Ve X0Y0 theo G54..G59 nguoi dung chon
# Nguon: https://thanhcam.com/huong-dan/  |  Thu tren NX 12.0.2 Post Builder, post phay 3 truc Generic.
# Cach dung: Custom Command > Create, ten: first_tool_xy0. Keo vao Auto Tool Change, sau G91G28Z0. Dat Fixture Offset trong MCS: 1 = G54, 2 = G55...
# Kiem tra lai tren may cua ban truoc khi chay that.

# Go to X0 Y0 once, in the work offset the user set on the first operation
# (G54..G59, same "+ 53" rule as the motion templates), not a fixed G54.
global thanhcam_xy0_done mom_fixture_offset_value
if { [info exists thanhcam_xy0_done] } { return }
set thanhcam_xy0_done 1
if { [info exists mom_fixture_offset_value] && [string is integer -strict $mom_fixture_offset_value] && $mom_fixture_offset_value >= 1 } {
   MOM_output_literal "G0G90G[expr {$mom_fixture_offset_value + 53}]X0Y0"
} else {
   MOM_output_literal "G0G90G54X0Y0"
   MOM_output_to_listing_device "Work offset unknown at program start; used G54 for the first X0Y0 move"
}

# ===== Chan G53: PB_CMD_fixture_offset_guard =====
# Custom Command > Create, ten: fixture_offset_guard.
# Mo PB_CMD_before_motion, them 1 dong: PB_CMD_fixture_offset_guard
# Fixture Offset = 0 se xuat G53 (toa do may). Lenh nay doi sang 1 (G54) va bao 1 lan moi operation.
# Dong G0G90G53 o cuoi chuong trinh la khoi co dinh, khong bi anh huong.
global mom_fixture_offset_value mom_operation_name thanhcam_g53_warned
if { [info exists mom_fixture_offset_value] && [string is integer -strict $mom_fixture_offset_value] && $mom_fixture_offset_value >= 1 } { return }
set mom_fixture_offset_value 1
if { ![info exists thanhcam_g53_warned($mom_operation_name)] } {
   set thanhcam_g53_warned($mom_operation_name) 1
   MOM_display_message "Operation $mom_operation_name: Fixture Offset = 0 se ra G53. Da doi sang G54, kiem tra lai MCS." "Canh bao G53"
}
