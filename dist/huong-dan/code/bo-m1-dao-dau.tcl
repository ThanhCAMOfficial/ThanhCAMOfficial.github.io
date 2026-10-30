# ThanhCAM — Bo M1 o lan thay dao dau tien
# Nguon: https://thanhcam.com/huong-dan/  |  Thu tren NX 12.0.2 Post Builder, post phay 3 truc Generic.
# Cach dung: Custom Command > Create, ten: skip_first_stop. Keo vao Auto Tool Change, ngay TRUOC khoi M1.
# Kiem tra lai tren may cua ban truoc khi chay that.

# Also drop the optional stop (M1) of the first tool change: the program
# already starts at home, so nothing needs to be checked before tool 1.
global thanhcam_stop_done
if { ![info exists thanhcam_stop_done] } {
   set thanhcam_stop_done 1
   MOM_suppress once M
}
