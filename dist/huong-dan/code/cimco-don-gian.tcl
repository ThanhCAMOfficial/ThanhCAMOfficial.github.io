# ThanhCAM — Tu mo CIMCO sau khi xuat post (ban don gian)
# Nguon: https://thanhcam.com/huong-dan/  |  Thu tren NX 12.0.2 Post Builder, post phay 3 truc Generic.
# Cach dung: Custom Command > Create, ten: CIMCO. Keo vao Program End Sequence, sau dau %. Sua duong dan neu CIMCO cai o thu muc khac.
# Kiem tra lai tren may cua ban truoc khi chay that.

#C:\CIMCO\CIMCOEdit8
global mom_output_file_full_name
MOM_close_output_file $mom_output_file_full_name
exec "C:\\CIMCO\\CIMCOEdit8\\CIMCOEdit.exe" $mom_output_file_full_name
