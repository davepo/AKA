#Project: AKA Triage Suite
#Sub-Project: AKA StandAlone
#Component: UsnJrnl Carver
#Purpose:	This script attempts to carve the
#			UsnJrnl from the provided volume.
#Supporting tool: ExtractUsnJrnl.exe
#Supporting URL: https://github.com/jschicht/ExtractUsnJrnl
#Developer: Dave Posocco

require 'timeout'
require_relative './AKA_Ruby_Script_helper'
include Helpers
$stdout.sync=true

if ARGV.length != 3
	puts "I need three argument!"
	exit
end

volume_letter= ARGV[0]
output_path= ARGV[1]
paths_file = ARGV[2]
this_dir = __dir__

log = ""

tools_dir = this_dir+"/tools"

log += Helpers.put_return("\nExecutable and paths:\n")
extractUsnJrnl = "ExtractUsnJrnl64.exe"

extractUsnJrnl_full_path = Helpers.find_exe_path(extractUsnJrnl, tools_dir)
extractUsnJrnl_dir = extractUsnJrnl_full_path.gsub(extractUsnJrnl, "")
extractUsnJrnl_dir.chop!

log += Helpers.put_return(extractUsnJrnl + "\n" + extractUsnJrnl_dir + "\n" + extractUsnJrnl_full_path + "\n\n")

Dir.chdir(extractUsnJrnl_dir)
command = "#{extractUsnJrnl} /DevicePath:#{volume_letter}: /OutputPath:\"#{output_path.gsub("/","\\")}\" /OutputName:$UsnJrnl.bin"

result = nil
log += Helpers.put_return("Command:\n"+ command)
Timeout::timeout(1800) {result=system(command) ? "Success" : "Failed"} rescue Timeout::Error
if result == "Success" or result == "Failed"
    log += Helpers.put_return("\nUsnJrnl extraction: "+result)
end

log += Helpers.put_return("\nUsnJrnl extraction complete.")

log_path = Helpers.get_script_log_path(paths_file)
Dir.chdir(log_path)

open('carve-usnjournal.log', 'a+') {|f| f.puts log}

sleep 5
exit