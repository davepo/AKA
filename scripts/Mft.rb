#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component: Mft parrser
#Purpose:	This script automates parsing mft files to
#			a csv file
#Supporting tool: MFT2Csv64.exe 
#Supporting URL: https://github.com/jschicht/Mft2Csv
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
mftcsv_exe = "Mft2Csv64.exe"
mftcsv_full_path = Helpers.find_exe_path(mftcsv_exe, tools_dir)
mftcsv_dir = mftcsv_full_path.gsub(mftcsv_exe, "")
mftcsv_dir.chop!

log += Helpers.put_return(mftcsv_exe + "\n" + mftcsv_dir + "\n" + mftcsv_full_path + "\n\n")

Dir.chdir(mftcsv_dir)

log += Helpers.put_return("\nMFT folder paths:\n")
mft_folder_paths = Helpers.find_all_paths_with_term("mft", paths_file)
mft_folder_paths.each {|line| log += Helpers.put_return(line.chop + "\n")}

mft_folder_paths.each do |path|
	chopped = path.chop
	command = "\"" + mftcsv_full_path + "\" /MftFile:\"" + path + "$MFT.bin" + "\" /Separator:, /OutputPath:\"" + chopped + "\""
	command.gsub!("\\","/")
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

log_path = Helpers.get_script_log_path(paths_file)
Dir.chdir(log_path)

open('Mft_mft2csv.log', 'a+') {|f| f.puts log}

sleep 5
exit