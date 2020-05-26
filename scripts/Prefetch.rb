#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component: Automated Prefetch Parsing 
#Purpose:	This script automates running PEcmd.exe
#			(an Eric Zimmerman tool) against extracted
#			prefetch files.
#Supporting tool: PEcmd.exe 
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

log += Helpers.put_return("\nPrefetch parser executable and paths:\n")
pecmd_exe = "PECmd.exe"
pecmd_full_path = Helpers.find_exe_path(pecmd_exe, tools_dir)
pecmd_dir = pecmd_full_path.gsub(pecmd_exe, "")
pecmd_dir.chop!

log += Helpers.put_return(pecmd_exe + "\n" + pecmd_dir + "\n" + pecmd_full_path + "\n\n")

Dir.chdir(pecmd_dir)

log += Helpers.put_return("\nPreftech folder paths:\n")
prefetch_folder_paths = Helpers.find_all_paths_with_term("prefetch", paths_file)
prefetch_folder_paths.each {|line| log += Helpers.put_return(line.chop + "\n")}

log += Helpers.put_return("\nRunning prefetch parser:\n")
prefetch_folder_paths.each do |path|
	chopped = path.chop
	command = "\"" + pecmd_full_path + "\" -d \"" + chopped + "\" --csv \"" + chopped + "\" --csvf Parsed_Prefetch.csv"
	command.gsub!("\\","/")
	result = nil
	log += Helpers.put_return("Command:\n "+ command)
	Timeout::timeout(180) {result=system(command) ? "Success" : "Failed"} rescue Timeout::Error
	if result == "Success" or result == "Failed"
		log += Helpers.put_return("Prefetch parser: "+ result+"\n")
	else 
		kill = %x( taskkill /IM PECmd.exe /F )
		log += Helpers.put_return("Timeout: Killing prefetch parser... " + kill + "\n")
		sleep 10
	end

end

log += Helpers.put_return("\n\nPrefetch processing complete.")

log_path = Helpers.get_script_log_path(paths_file)
Dir.chdir(log_path)

open('Prefetch_PEcmd.log', 'w') {|f| f.puts log}

sleep 5
exit