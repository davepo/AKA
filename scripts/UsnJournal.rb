#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component: UsnJrnl parrser
#Purpose:	This script automates parsing UsnJrnl files to
#			a csv file
#Supporting tool: UsnJrnl2Csv64.exe
#Supporting URL: https://github.com/jschicht/UsnJrnl2Csv
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

log += Helpers.put_return("\UsnJrnl parser executable and paths:\n")
ujcsv_exe = "UsnJrnl2Csv64.exe"
ujcsv_full_path = Helpers.find_exe_path(ujcsv_exe, tools_dir)
ujcsv_dir = ujcsv_full_path.gsub(ujcsv_exe, "")
ujcsv_dir.chop!

log += Helpers.put_return(ujcsv_exe + "\n" + ujcsv_dir + "\n" + ujcsv_full_path + "\n\n")

Dir.chdir(ujcsv_dir)

log += Helpers.put_return("\nUsnJrnl folder paths:\n")
uj_folder_paths = Helpers.find_all_paths_with_term("UsnJournal", paths_file)
uj_folder_paths.each {|line| log += Helpers.put_return(line.chop + "\n")}

uj_folder_paths.each do |path|
    chopped = path.chop
    command = "\"" + ujcsv_full_path + "\" /UsnJrnlFile:\"" + path + "$UsnJrnl.bin" + "\" /Separator:, /OutputPath:\"" + chopped + "\""
    command.gsub!("\\","/")
	result = nil
	log += Helpers.put_return("Command:\n "+ command)
	Timeout::timeout(2700) {result=system(command) ? "Success" : "Failed"} rescue Timeout::Error
	if result == "Success" or result == "Failed"
		log += Helpers.put_return("UsnJrnl parser: "+ result+"\n")
	else 
		kill = %x( taskkill /IM #{ujcsv_exe} /F )
		log += Helpers.put_return("Timeout: Killing UsnJrnl parser... " + kill + "\n")
		sleep 10
	end
end

log += Helpers.put_return("\nUsnJrnl processing complete.")

log_path = Helpers.get_script_log_path(paths_file)
Dir.chdir(log_path)

open('UsnJrnl_UsnJrnl2csv.log', 'a+') {|f| f.puts log}

sleep 5
exit