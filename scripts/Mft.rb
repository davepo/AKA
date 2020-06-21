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

#When AKA uses this script for a mounted volume:
# paths_file => The output directory path
# evidence_paths_file => The single letter of the volume

log = ""

tools_dir = aka_script_path+"/tools"

log += Helpers.put_return("\nMFT parser executable and paths:\n")
mftcsv_exe = "Mft2Csv64.exe"
mftcsv_full_path = Helpers.find_exe_path(mftcsv_exe, tools_dir)
mftcsv_dir = mftcsv_full_path.gsub(mftcsv_exe, "")
mftcsv_dir.chop!

log += Helpers.put_return(mftcsv_exe + "\n" + mftcsv_dir + "\n" + mftcsv_full_path + "\n\n")

Dir.chdir(mftcsv_dir)

log += Helpers.put_return("\nMFT folder paths:\n")
mft_folder_paths = []

if evidence_paths_file.include?(".txt")
	mft_folder_paths = Helpers.find_all_paths_with_term("mft", paths_file)
	mft_folder_paths.each {|line| log += Helpers.put_return(line.chop + "\n")}
else
	mft_folder_paths << evidence_paths_file+":\\"
end

mft_folder_paths.each do |path|
	unless path == evidence_paths_file
		chopped = path.chop
		command = "\"" + mftcsv_full_path + "\" /MftFile:\"" + path + "$MFT" + "\" /Separator:, /OutputPath:\"" + chopped + "\""
		command.gsub!("\\","/")
	else
		command = "\"" + mftcsv_full_path + "\" /Volume:\"" + path + "$MFT" + "\" /Separator:, /OutputPath:\"" + paths_file + "\""
	end
	result = nil
	log += Helpers.put_return("Command:\n "+ command)
	Timeout::timeout(2700) {result=system(command) ? "Success" : "Failed"} rescue Timeout::Error
	if result == "Success" or result == "Failed"
		log += Helpers.put_return("Mft parser: "+ result+"\n")
	else 
		kill = %x( taskkill /IM #{mftcsv_exe} /F )
		log += Helpers.put_return("Timeout: Killing MFt parser... " + kill + "\n")
		sleep 10
	end
end

log += Helpers.put_return("\nMft processing complete.")

log_path = ""
unless evidence_paths_file.length > 1
	log_path = Helpers.get_script_log_path(paths_file)
else
	log_path = paths_file
end
Dir.chdir(log_path)
open('Mft_mft2csv.log', 'a+') {|f| f.puts log}

sleep 5
exit