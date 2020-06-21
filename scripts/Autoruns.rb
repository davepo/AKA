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
log += Helpers.put_return("\nAttempting to run Autoruns against: "+drive_letter_string+"\n")

autoruns_log_path = Helpers.get_autoruns_output_path(paths_file)
log += Helpers.put_return("\nScan results will be placed in: "+autoruns_log_path+"\n")

proc_dir = __dir__
tools_dir = proc_dir.gsub("scripts","tools")

log += Helpers.put_return("\nAutoruns executable and paths:\n")
autoruns_exe = "autorunsc64.exe"
autoruns_full_path = Helpers.find_exe_path(autoruns_exe, tools_dir)
autoruns_dir = autoruns_full_path.gsub(autoruns_exe, "")
autoruns_dir.chop!

log += Helpers.put_return(autoruns_exe + "\n" + autoruns_dir + "\n" + autoruns_full_path + "\n\n")
Dir.chdir(autoruns_dir)
drive_letters.each do |drive|
    command = autoruns_exe + " -a * -c -o \"#{File.join(autoruns_log_path, "Mounted_Volume-"+drive+".csv")}\" -z #{drive}:\\Windows -nobanner" 
	command.gsub!("/","\\")
	result = nil
    log += Helpers.put_return("Command:\n "+ command)
	Timeout::timeout(1800) {result=system(command) ? "Success" : "Failed"} rescue Timeout::Error
	if result == "Success" or result == "Failed"
		log += Helpers.put_return("Autoruns scanning "+drive+":\\ "+ result+"\n")
	else 
		kill = %x( taskkill /IM #{autoruns_exe} /F )
		log += Helpers.put_return("Timeout: Killing image mounter... " + kill + "\n")
		sleep 10
	end
end

log += Helpers.put_return("\nAutoruns complete.")

log_path = Helpers.get_script_log_path(paths_file)
Dir.chdir(log_path)

open('Autoruns_autorunsc64.log', 'a+') {|f| f.puts log}

sleep 5
exit