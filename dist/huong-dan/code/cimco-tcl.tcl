# ThanhCAM — Tu mo CIMCO (hoac Notepad++) sau khi xuat post — cach 2: sua file .tcl
# Nguon: https://thanhcam.com/huong-dan/cimco.html  |  Thu tren NX 12.0.2.
# SAO LUU file .tcl truoc khi sua. Mo file .tcl cua post bang Notepad++:
#  1) Tim "proc MOM_end_of_program". Ngay sau dong "PB_CMD_kin_end_of_program" va dau "}" cua no, them:
#        PB_CMD_open_nc_in_cimco
#  2) Tim "proc PB_start_of_program". Ngay duoi dong "PB_CMD_fix_RAPID_SET" them:
#        PB_CMD_Cimco
#  3) Tim "proc PB_CMD_FEEDRATE_NUMBER". Dan TOAN BO phan ben duoi vao NGAY TREN dong "#====" cua proc do.
# Chon trinh soan thao rieng: tao file editor_path.txt canh file post, moi dong 1 duong dan .exe.
# Moi lan mo, post ghi them file <ten NC>.cimco-launch.diag (kich thuoc + SHA256) canh file NC.

#=============================================================
proc PB_CMD_Cimco { } {
#=============================================================
# Start of program: define helper procs, reset per-run data, hook the final editor launch.
PB_CMD_thanhcam_helpers
catch {unset ::tc_tool_comment_numbers}
PB_CMD_install_cimco_finalizer
}


#=============================================================
proc PB_CMD_find_cimco { } {
#=============================================================
   global env
   set candidates {}
   if { [info exists env(THANHCAM_CIMCO_EXE)] } {
      lappend candidates $env(THANHCAM_CIMCO_EXE)
   }

   # App Paths supports a custom installation folder without scanning drives.
   if { ![catch {package require registry}] } {
      foreach base {HKEY_CURRENT_USER HKEY_LOCAL_MACHINE} {
         foreach branch {SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths SOFTWARE\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\App Paths} {
            if { ![catch {registry get "$base\\$branch\\CIMCOEdit.exe" ""} exe] } {
               lappend candidates [string trim $exe {" }]
            }
         }
      }
   }

   set roots {C:/CIMCO}
   foreach key {ProgramW6432 ProgramFiles ProgramFiles(x86)} {
      if { [info exists env($key)] } { lappend roots $env($key) }
   }
   foreach root $roots {
      foreach folder [lsort -dictionary -decreasing [glob -nocomplain -types d -directory $root *CIMCO*]] {
         lappend candidates [file join $folder CIMCOEdit.exe]
         foreach child [lsort -dictionary -decreasing [glob -nocomplain -types d -directory $folder *]] {
            lappend candidates [file join $child CIMCOEdit.exe]
         }
      }
   }
   foreach exe $candidates {
      if { [file isfile $exe] && [string equal -nocase [file tail $exe] CIMCOEdit.exe] } {
         return [file normalize $exe]
      }
   }
   return ""
}


#=============================================================
proc PB_CMD_find_editor { } {
#=============================================================
   # Order: editor_path.txt next to this post (user choice) -> CIMCO -> Notepad++.
   # editor_path.txt: one .exe path per line, '#' starts a comment, first valid wins.
   set dirs {}
   foreach name {mom_event_handler_file_name} {
      if { [info exists ::$name] } { lappend dirs [file dirname [set ::$name]] }
   }
   if { [info exists ::mom_sys_this_post_dir] } { lappend dirs $::mom_sys_this_post_dir }
   foreach dir $dirs {
      set list_file [file join $dir editor_path.txt]
      if { ![file isfile $list_file] || [catch {open $list_file r} f] } { continue }
      set text [read $f]
      close $f
      foreach line [split $text \n] {
         set line [string trim $line " \t\r\"'"]
         if { $line eq "" || [string index $line 0] eq "#" } { continue }
         if { [file isfile $line] && [string equal -nocase [file extension $line] .exe] } {
            return [file normalize $line]
         }
      }
   }
   if { ![catch {PB_CMD_find_cimco} exe] && $exe ne "" } { return $exe }
   set roots {}
   foreach key {ProgramW6432 ProgramFiles ProgramFiles(x86)} {
      if { [info exists ::env($key)] } { lappend roots $::env($key) }
   }
   foreach root $roots {
      set exe [file join $root Notepad++ notepad++.exe]
      if { [file isfile $exe] } { return [file normalize $exe] }
   }
   return ""
}


#=============================================================
proc PB_CMD_thanhcam_helpers { } {
#=============================================================
   # Post Builder custom commands cannot take arguments, so the three small helpers
   # that need them are defined here (global procs). Called once at program start.
   uplevel #0 {

      # Whole minutes -> {hours minutes}, rounded once: 119.7 -> {2 0}, never "1 h 60 min".
      proc PB_CMD_split_hours_minutes { total_minutes } {
         set total [expr {int(round($total_minutes))}]
         if { $total < 0 } { set total 0 }
         return [list [expr {$total / 60}] [expr {$total % 60}]]
      }

      # Temporary launcher policy, NOT a documented NX flag contract.
      proc PB_CMD_read_cimco_flag { name } {
         upvar #0 $name value
         if { ![info exists value] } { return absent }
         if { $value eq "" } { return empty }
         if { ![string is boolean -strict $value] } { return invalid }
         if { [string is true -strict $value] } { return true }
         return false
      }

      # Size + SHA256 of the closed NC, written next to it before the editor opens.
      proc PB_CMD_cimco_launch_snapshot { path exe } {
         global env
         set size [file size $path]
         set certutil [file join $env(SystemRoot) System32 certutil.exe]
         set report [exec -- $certutil -hashfile [file nativename $path] SHA256]
         set sha ""
         foreach line [split $report \n] {
            set candidate [string map {" " "" "\t" "" "\r" ""} $line]
            if { [regexp {^[0-9a-fA-F]{64}$} $candidate] } {
               set sha [string toupper $candidate]
            }
         }
         if { $sha eq "" } { error "SHA256 missing from certutil output" }
         if { [file size $path] != $size } { error "NC size changed while hashing" }
         set diag "${path}.cimco-launch.diag"
         set f [open $diag w]
         fconfigure $f -encoding utf-8 -translation lf
         set write_code [catch {
            puts $f [list format THANHCAM_CIMCO_LAUNCH_V1]
            puts $f [list nc_path [file nativename $path]]
            puts $f [list size $size]
            puts $f [list sha256 $sha]
            puts $f [list editor [file nativename $exe]]
            puts $f [list snapshot_utc [clock format [clock seconds] -gmt 1 -format {%Y-%m-%dT%H:%M:%SZ}]]
            puts $f [list status launch_requested]
         } write_message write_options]
         close $f
         if { $write_code } { return -options $write_options $write_message }
         return $diag
      }
   }
}


#=============================================================
proc PB_CMD_install_cimco_finalizer { } {
#=============================================================
   # Post Builder regenerates the event body, including its listing/kin tail.
   # This persistent start-program custom command restores only our final call.
   # No wrapper, delayed process or second event handler is introduced.
   set body [info body ::MOM_end_of_program]
   if { ![regexp {PB_CMD_open_nc_in_cimco\s*$} $body] } {
      append body "\n   PB_CMD_open_nc_in_cimco\n"
      proc ::MOM_end_of_program {} $body
   }
}


#=============================================================
proc PB_CMD_open_nc_in_cimco { } {
#=============================================================
   PB_CMD_thanhcam_helpers
   global ptp_file_name
   # Temporary launcher policy, NOT a documented NX flag contract:
   # absent/empty/false may launch; true or invalid must not launch.
   set blocked 0
   foreach name {mom_program_aborted mom_event_error} {
      switch [PB_CMD_read_cimco_flag $name] {
         true { set blocked 1 }
         invalid {
            upvar #0 $name value
            MOM_output_to_listing_device "CIMCO skipped: invalid $name=[list $value] (temporary flag policy)"
            set blocked 1
         }
      }
   }
   if { $blocked || ![info exists ptp_file_name] || ![file isfile $ptp_file_name] } { return }
   if { [catch {PB_CMD_find_editor} exe] } {
      MOM_output_to_listing_device "Editor lookup failed: $exe"
      return
   }
   if { $exe eq "" } { return }
   set path [file normalize $ptp_file_name]
   # This is the final output action, after every NC block and the kin tail.
   # Keep the NC closed: reopening here reacquires NX's exclusive write lock,
   # which blocks both certutil and the editor with ERROR_SHARING_VIOLATION.
   MOM_close_output_file $ptp_file_name
   set snapshot_code [catch {PB_CMD_cimco_launch_snapshot $path $exe} snapshot]
   if { $snapshot_code } {
      MOM_output_to_listing_device "CIMCO skipped: launch snapshot failed: $snapshot"
      return
   }
   if { [catch {exec -- $exe [file nativename $path] &} message] } {
      MOM_output_to_listing_device "Editor could not open the NC file: $message"
   }
}