#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component: Event log parser
#Purpose:	This script automates parsing evtx files to
#			csv files
#Supporting tool: EvtxECmd.exe 
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

log += Helpers.put_return("\nEvtx parser executable and paths:\n")
evtxcmd_exe = "EvtxECmd.exe"
evtxcmd_full_path = Helpers.find_exe_path(evtxcmd_exe, tools_dir)
evtxcmd_dir = evtxcmd_full_path.gsub(evtxcmd_exe, "")
evtxcmd_dir.chop!

log += Helpers.put_return(evtxcmd_exe + "\n" + evtxcmd_dir + "\n" + evtxcmd_full_path + "\n\n")

Dir.chdir(evtxcmd_dir)

log += Helpers.put_return("\nEvent log folder paths:\n")
evtx_folder_paths = Helpers.find_all_paths_with_term("event_logs", paths_file)
evtx_folder_paths.each {|line| log += Helpers.put_return(line.chop + "\n")}

evtx_folder_paths.each do |path|
	evtx_logs = Dir.children(path)
	evtx_logs.each do |item|
		if item.include? ".evtx"
			chopped = path.chop
			command = "\"" + evtxcmd_full_path + "\" -f \"" + path + item + "\" --csv \"" + chopped + "\" --csvf " + item.gsub(".evtx",".csv")
			command.gsub!("\\","/")
			result = nil
			log += Helpers.put_return("Command:\n "+ command)
			Timeout::timeout(360) {result=system(command) ? "Success" : "Failed"} rescue Timeout::Error
			if result == "Success" or result == "Failed"
				log += Helpers.put_return("Evtx parser: "+ item + "   " + result+"\n")
			else 
				kill = %x( taskkill /IM EvtxECmd.exe /F )
				log += Helpers.put_return("Timeout: Killing MFt parser... " + item + "   " + kill + "\n")
				sleep 10
			end
		end
	end
end

log += Helpers.put_return("\nEvtx processing complete.")

log_path = Helpers.get_script_log_path(paths_file)
Dir.chdir(log_path)
open('EventLogs_EvtxECmd.log', 'a+') {|f| f.puts log}

sleep 5
exit