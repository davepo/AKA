#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component: Mft parrser
#Purpose:	This script automates parsing mft files to
#			a csv file
#Supporting tool: MFTECmd.exe 
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

log += Helpers.put_return("\nMFT parser executable and paths:\n")
mftcmd_exe = "MFTECmd.exe"
mftcmd_full_path = Helpers.find_exe_path(mftcmd_exe, tools_dir)
mftcmd_dir = mftcmd_full_path.gsub(mftcmd_exe, "")
mftcmd_dir.chop!

log += Helpers.put_return(mftcmd_exe + "\n" + mftcmd_dir + "\n" + mftcmd_full_path + "\n\n")

Dir.chdir(mftcmd_dir)

log += Helpers.put_return("\nMFT folder paths:\n")
mft_folder_paths = Helpers.find_all_paths_with_term("mft", paths_file)
mft_folder_paths.each {|line| log += Helpers.put_return(line.chop + "\n")}

mft_folder_paths.each do |path|
	chopped = path.chop
	command = "\"" + mftcmd_full_path + "\" -f \"" + path + "$MFT" + "\" --csv \"" + chopped + "\" --csvf Parsed_MFT.csv"
	command.gsub!("\\","/")
	result = nil
	log += Helpers.put_return("Command:\n "+ command)
	Timeout::timeout(1800) {result=system(command) ? "Success" : "Failed"} rescue Timeout::Error
	if result == "Success" or result == "Failed"
		log += Helpers.put_return("Mft parser: "+ result+"\n")
	else 
		kill = %x( taskkill /IM MFTECmd.exe /F )
		log += Helpers.put_return("Timeout: Killing MFt parser... " + kill + "\n")
		sleep 10
	end
end

log += Helpers.put_return("\nMft processing complete.")

log_path = Helpers.get_script_log_path(paths_file)
Dir.chdir(log_path)

open('Mft_MFTEcmd.log', 'w') {|f| f.puts log}

sleep 5
exit