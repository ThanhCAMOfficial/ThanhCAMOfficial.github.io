# ThanhCAM — Canh bao S = 0 va F = 250
# Nguon: https://thanhcam.com/huong-dan/  |  Thu tren NX 12.0.2 Post Builder, post phay 3 truc Generic.
# Cach dung: Custom Command > Create, ten: custom_S0F250, dan phan (A). Mo PB_CMD_before_motion, them 1 dong: PB_CMD_custom_S0F250
# Kiem tra lai tren may cua ban truoc khi chay that.

# ===== (A) PB_CMD_custom_S0F250 =====
global mom_spindle_speed
global mom_operation_name
global feed

if { $mom_spindle_speed == 0 } {
   MOM_display_message "Toc do S = 0 nen da dat S5000. Hay sua S neu khong phu hop." "Canh bao S = 0"
   set mom_spindle_speed "5000"
}

if { $feed == 250 } {
   set errmes "\n\n Nhac nho: operation $mom_operation_name dang de F = 250. Kiem tra lai luong chay dao.\n\n"
   MOM_abort "$errmes"
}

