#Project: AKA Triage Suite
#Sub-Project: AKA StandAlone
#Component: MFT Carver
#Purpose:	This script attempts to carve the
#			mft from the provided volume.
#Supporting tool: RawCopy.exe
#Supporting URL: https://github.com/jschicht/RawCopy
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
rawcopy = "RawCopy64.exe"

rawcopy_full_path = Helpers.find_exe_path(rawcopy, tools_dir)
rawcopy_dir = rawcopy_full_path.gsub(rawcopy, "")
rawcopy_dir.chop!

log += Helpers.put_return(rawcopy + "\n" + rawcopy_dir + "\n" + rawcopy_full_path + "\n\n")

Dir.chdir(rawcopy_dir)
command = "#{rawcopy} /FileNamePath:#{volume_letter}:0 /OutputName:$MFT.bin /OutputPath:\"#{output_path.gsub("/","\\")}\""

result = nil
log += Helpers.put_return("Command:\n"+ command)
Timeout::timeout(1800) {result=system(command) ? "Success" : "Failed"} rescue Timeout::Error
if result == "Success" or result == "Failed"
    log += Helpers.put_return("\nMFT extraction: "+result)
end

log += Helpers.put_return("\nMFT extraction complete.")

log_path = Helpers.get_script_log_path(paths_file)
Dir.chdir(log_path)

open('carve-vol-mft.log', 'a+') {|f| f.puts log}

sleep 5
exit