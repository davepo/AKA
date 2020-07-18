#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component: AV Scanner
#Purpose:	This script attempts AV scan mounted
#			evidence files.
#Supporting tool: Clam Scanner
#Supporting URL: N/A
#Developer: Dave Posocco

require 'timeout'
require_relative '../AKA_Ruby_Script_helper'
include Helpers
$stdout.sync=true

if ARGV.length != 3
	puts "I need three argument!"
	exit
end

drive_letter_string =ARGV[0]
paths_file = ARGV[1]
unused = ARGV[2]

log = ""

drive_letters = []
drive_letter_string.each_char do |letter|
    drive_letters << letter
end
log += Helpers.put_return("\nAttempting to run AV scanner against: "+drive_letter_string+"\n")

av_log_path = Helpers.get_av_scan_output_path(paths_file)
log += Helpers.put_return("\nScan results will be placed in: "+av_log_path+"\n")

proc_dir = __dir__
tools_dir = proc_dir.gsub("scripts","tools")

scanner_exe = "clamscan.exe"
scanner_full_path = Helpers.find_exe_path(scanner_exe, tools_dir)
scanner_dir = scanner_full_path.gsub(scanner_exe, "")
scanner_dir.chop!

drive_letters.each do |drive|

	basic_options = "--recursive"
	symlink_options = "--follow-dir-symlinks=0 --follow-file-symlinks=0"
	max_options = "--max-filesize=5M --max-dir-recursion=7"

	xnontargetdrives = "^[^#{drive}]:\\\\" 
	xwindir = "^#{drive}:\\\\[wW]indows\\\\"
	xprogfil = "^#{drive}:\\\\[pP]rogram.[fF]iles\\\\"
	xprogfilx86 = "^#{drive}:\\\\[pP]rogram.[fF]iles..x86.\\\\"
	exclude_options = "--exclude-dir=\"(#{xnontargetdrives})|(#{xwindir})|(#{xprogfil})|(#{xprogfilx86})\""
	
	log_options = "--log=\"#{av_log_path}#{drive}-scan.txt\""
	
	command = "\"#{scanner_full_path}\" #{basic_options} #{symlink_options} #{max_options} #{exclude_options} #{drive}:\\ #{log_options}"
	
	result = nil
    log += Helpers.put_return("Command:\n "+ command)
    puts "Scanning..."
	Timeout::timeout(86400) {result=system(command) ? "Success" : "Failed"} rescue Timeout::Error
	if result == "Success" or result == "Failed"
		log += Helpers.put_return("AV Scanning "+drive+":\\ "+ "executed, see log for result."+"\n")
	else 
		kill = %x( taskkill /IM clamscan.exe /F )
		log += Helpers.put_return("Timeout: Killing AV scan... " + kill + "\n")
		sleep 10
	end
end

log += Helpers.put_return("\nAV Scanning complete.")

log_path = Helpers.get_script_log_path(paths_file)
Dir.chdir(log_path)

open('AV_Scanner.log', 'a+') {|f| f.puts log}

sleep 5
exit