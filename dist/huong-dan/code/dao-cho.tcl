# ThanhCAM — Dao cho (preselect next tool)
# Nguon: https://thanhcam.com/huong-dan/  |  Thu tren NX 12.0.2 Post Builder, post phay 3 truc Generic.
# Cach dung: Custom Command > Create, ten: preselect_next_tool, dan phan duoi. Keo PB_CMD_preselect_next_tool vao Auto Tool Change, sau MOM_set_seq_off.
# Kiem tra lai tren may cua ban truoc khi chay that.

# "Dao cho": after the tool change line (N1T7M6) print the next tool (T16) so the
# magazine can get it ready. On the last tool NX gives the first tool number,
# so the magazine is ready for the next run. Same tool next: nothing printed. enabled 0 = off.
global mom_tool_number mom_next_tool_number
set enabled 1
if { !$enabled } { return }
if { ![info exists mom_next_tool_number] || ![info exists mom_tool_number] } { return }
if { ![string is integer -strict $mom_next_tool_number] || $mom_next_tool_number <= 0 } { return }
if { $mom_next_tool_number == $mom_tool_number } { return }
MOM_output_literal "T$mom_next_tool_number"
