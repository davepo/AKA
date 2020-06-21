#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component: AV Scanner
#Purpose:	This script attempts AV scan mounted
#			evidence files.
#Supporting tool: Windows Defender
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
log += Helpers.put_return("\nAttempting to run Defender against: "+drive_letter_string+"\n")

av_log_path = Helpers.get_av_scan_output_path(paths_file)
log += Helpers.put_return("\nScan results will be placed in: "+av_log_path+"\n")

defender_path = "%ProgramFiles%/Windows Defender/MpCmdRun.exe"

drive_letters.each do |drive|
    command = "\"" + defender_path + "\" -Scan -ScanType 3 -File \"" + drive + ":\\\" -DisableRemediation >> \"" + av_log_path + drive + "-scan.txt\"" 
	command.gsub!("\\","/")
	result = nil
    log += Helpers.put_return("Command:\n "+ command)
    puts "Scanning..."
	Timeout::timeout(86400) {result=system(command) ? "Success" : "Failed"} rescue Timeout::Error
	if result == "Success" or result == "Failed"
		log += Helpers.put_return("AV Scanning "+drive+":\\ "+ result+"\n")
	else 
		kill = %x( taskkill /IM MpCmdRun.exe /F )
		log += Helpers.put_return("Timeout: Killing defender scan... " + kill + "\n")
		sleep 10
	end
end

log += Helpers.put_return("\nImage mounting complete.")

log_path = Helpers.get_script_log_path(paths_file)
Dir.chdir(log_path)

open('AV_DefenderScanner.log', 'a+') {|f| f.puts log}

sleep 5
exit