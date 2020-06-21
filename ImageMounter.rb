#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component: Image mounter
#Purpose:	This script attempts to mount each
#			ewf image as read only in Windows.
#Supporting tool: aim_cli.exe 
#Supporting URL: "https://github.com/ArsenalRecon/Arsenal-Image-Mounter/tree/master/Command line applications"
#Developer: Dave Posocco

require 'timeout'
require_relative './AKA_Ruby_Script_helper'
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

log += Helpers.put_return("\nImage mounter executable and paths:\n")
aim_exe = "aim_cli.exe"
aim_full_path = Helpers.find_exe_path(aim_exe, tools_dir)
aim_dir = aim_full_path.gsub(aim_exe, "")
aim_dir.chop!

log += Helpers.put_return(aim_exe + "\n" + aim_dir + "\n" + aim_full_path + "\n\n")

Dir.chdir(aim_dir)

log += Helpers.put_return("\nImage paths:\n")
image_paths = []
if File.extname(evidence_paths_file) == ".txt"
	image_paths = Helpers.get_image_paths(evidence_paths_file)
	image_paths.each {|line| log += Helpers.put_return(line.chop + "\n")}
else
	image_paths << evidence_paths_file
end

image_paths.each do |path|
    chopped = path.chop
    if path.include? ".e01" or path.include? ".E01"
        command = "start cmd /K \"\"" + aim_full_path + "\" /mount /readonly /filename=\"" + path + "\" /provider=libewf\""
    else
        command = "start cmd /K \"\"" + aim_full_path + "\" /mount /readonly /filename=\"" + path + "\" /provider=MultiPartRaw\""
    end
	command.gsub!("\\","/")
	result = nil
	log += Helpers.put_return("Command:\n "+ command)
	Timeout::timeout(1800) {result=system(command) ? "Success" : "Failed"} rescue Timeout::Error
	if result == "Success" or result == "Failed"
		log += Helpers.put_return("Mounting "+path+": "+ result+"\n")
	else 
		#kill = %x( taskkill /IM aim_cli.exe /F )
		#log += Helpers.put_return("Timeout: Killing image mounter... " + kill + "\n")
		sleep 10
	end
	sleep 5
end

log += Helpers.put_return("\nImage mounting complete.")

log_path = Helpers.get_script_log_path(paths_file)
Dir.chdir(log_path)

open('ImageMounting_aim_cli.log', 'a+') {|f| f.puts log}

sleep 5
exit