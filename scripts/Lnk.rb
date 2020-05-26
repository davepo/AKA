#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component:  Lnk Files parser
#Purpose:	This script parses the exported users
#			lnk files into a csv
#Supporting tool:  LEcmd.exe
#Supporting URL: https://ericzimmerman.github.io/#!index.md
#Developer: Dave Posocco

require 'timeout'
require_relative '../AKA_Ruby_Script_helper'
include Helpers
$stdout.sync=true

if ARGV.length != 3
	puts "I need three arguments!"
	exit
end

aka_script_path =ARGV[0]
paths_file = ARGV[1]
evidence_paths_file= ARGV[2]

log = ""

tools_dir = aka_script_path+"/tools"

log += Helpers.put_return("\nLnk parser executable and paths:\n")
lecmd_exe = "LECmd.exe"
lecmd_full_path = Helpers.find_exe_path(lecmd_exe, tools_dir)
lecmd_dir = lecmd_full_path.gsub(lecmd_exe, "")
lecmd_dir.chop!

log += Helpers.put_return(lecmd_exe + "\n" + lecmd_dir + "\n" + lecmd_full_path + "\n\n")

Dir.chdir(lecmd_dir)

log += Helpers.put_return("\nLnk file locations:\n")
lnk_folder_paths = Helpers.find_all_paths_with_term("_lnk_", paths_file)
lnk_folder_paths.each {|line| log += Helpers.put_return(line.chop + "\n")}

log += Helpers.put_return("\nRunning lnk parser:\n")
lnk_folder_paths.each do |path|
	chopped = path.chop
	command = "\"" + lecmd_full_path + "\" -d \"" + chopped + "\" --csv \"" + chopped + "\" --csvf Parsed_lnk_files.csv"
	command.gsub!("\\","/")
	result = nil
	log += Helpers.put_return("Command:\n "+ command)
	Timeout::timeout(180) {result=system(command) ? "Success" : "Failed"} rescue Timeout::Error
	if result == "Success" or result == "Failed"
		log += Helpers.put_return("Lnk parser: "+ result+"\n")
	else 
		kill = %x( taskkill /IM LECmd.exe /F )
		log += Helpers.put_return("Timeout: Killing lnk parser... " + kill + "\n")
		sleep 10
	end
end

log += Helpers.put_return("\n\Lnk processing complete.")

log_path = Helpers.get_script_log_path(paths_file)
Dir.chdir(log_path)
open('Lnk_LEcmd.log', 'w') {|f| f.puts log}

sleep 5
exit