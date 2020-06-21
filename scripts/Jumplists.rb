#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component:  Jumplist Files parser
#Purpose:	This script parses the exported users
#			jumplist files into a csv
#Supporting tool:  JLEcmd.exe
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

log += Helpers.put_return("\nJumplist parser executable and paths:\n")
jlecmd_exe = "JLECmd.exe"
jlecmd_full_path = Helpers.find_exe_path(jlecmd_exe, tools_dir)
jlecmd_dir = jlecmd_full_path.gsub(jlecmd_exe, "")
jlecmd_dir.chop!

log += Helpers.put_return(jlecmd_exe + "\n" + jlecmd_dir + "\n" + jlecmd_full_path + "\n\n")

Dir.chdir(jlecmd_dir)

log += Helpers.put_return("\nJumplist folder paths:\n")
jumplist_folder_paths = Helpers.find_all_paths_with_term("jumplist", paths_file)
jumplist_folder_paths.each {|line| log += Helpers.put_return(line.chop + "\n")}

log += Helpers.put_return("\nRunning jumplist parser:\n")
jumplist_folder_paths.each do |path|
	chopped = path.chop
	command = "\"" + jlecmd_full_path + "\" -d \"" + chopped + "\" --csv \"" + chopped + "\" --csvf Parsed_Jumplist_files.csv"
	command.gsub!("\\","/")
	result = nil
	log += Helpers.put_return("Command:\n "+ command)
	Timeout::timeout(180) {result=system(command) ? "Success" : "Failed"} rescue Timeout::Error
	if result == "Success" or result == "Failed"
		log += Helpers.put_return("Jumplist parser: "+ result+"\n")
	else 
		kill = %x( taskkill /IM JLECmd.exe /F )
		log += Helpers.put_return("Timeout: Killing jumplist parser... " + kill + "\n")
		sleep 10
	end
end

log += Helpers.put_return("\n\Jumplist processing complete.")

log_path = Helpers.get_script_log_path(paths_file)
Dir.chdir(log_path)

open('Jumplists_JLEcmd.log', 'a+') {|f| f.puts log}

sleep 5
exit