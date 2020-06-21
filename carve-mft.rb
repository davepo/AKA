#Project: AKA Triage Suite
#Sub-Project: AKA StandAlone
#Component: MFT Carver
#Purpose:	This script attempts to carve the
#			mft from the provided image file.
#Supporting tool: 
#Supporting URL: 
#Developer: Dave Posocco

require 'timeout'
require_relative './AKA_Ruby_Script_helper'
include Helpers
$stdout.sync=true

if ARGV.length != 3
	puts "I need three argument!"
	exit
end

evidence_path= ARGV[0]
output_path= ARGV[1]
paths_file = ARGV[2]
this_dir = __dir__

log = ""

tools_dir = this_dir+"/tools"

log += Helpers.put_return("\nExecutables and paths:\n")
fsstat = "fsstat.exe"
ifind = "ifind.exe"
icat = "icat.exe"

fsstat_full_path = Helpers.find_exe_path(fsstat, tools_dir)
fsstat_dir = fsstat_full_path.gsub(fsstat, "")
fsstat_dir.chop!

ifind_full_path = Helpers.find_exe_path(ifind, tools_dir)
ifind_dir = ifind_full_path.gsub(ifind, "")
ifind_dir.chop!

icat_full_path = Helpers.find_exe_path(icat, tools_dir)
icat_dir = icat_full_path.gsub(icat, "")
icat_dir.chop!

log += Helpers.put_return(fsstat + "\n" + fsstat_dir + "\n" + fsstat_full_path + "\n\n")
log += Helpers.put_return(ifind + "\n" + ifind_dir + "\n" + ifind_full_path + "\n\n")
log += Helpers.put_return(icat + "\n" + icat_dir + "\n" + icat_full_path + "\n\n")

Dir.chdir(fsstat_dir)

command = fsstat + " \"" + evidence_path.gsub("/","\\") + "\" > \"" + File.join(output_path.gsub("/","\\"), "\\fsstat_output.txt") + "\"" 

result = nil
log += Helpers.put_return("Command:\n"+ command)
Timeout::timeout(1800) {result=system(command) ? "Success" : "Failed"} rescue Timeout::Error
if result == "Success" or result == "Failed"
    cluster = ""
    inum = ""
    log += Helpers.put_return("fsstat: "+ result+"\n")
    File.open(File.join(output_path, "/fsstat_output.txt"), 'r') do |fsstat_file| 
        fsstat_file_data = fsstat_file.readlines.map(&:chomp)
        fsstat_file_data.each do |line|
            if line.downcase.include?("first cluster of mft:")
                cluster = (line.chars.map{|x| x[/\d+/]}).join
                command = ifind + " -d " + cluster + " \"" + evidence_path.gsub("/","\\") + "\" > \"" +File.join(output_path.gsub("/","\\"), "\\ifind_output.txt") + "\""
                result = nil
                log += Helpers.put_return("Command:\n "+ command)
                Timeout::timeout(1800) {result=system(command) ? "Success" : "Failed"} rescue Timeout::Error
                if result == "Success" or result == "Failed"
                    log += Helpers.put_return("ifind: "+ result+"\n")
                    File.open(File.join(output_path, "/ifind_output.txt"), 'r') do |ifind_file| 
                        inum = ifind_file.read.chomp
                        command = icat + " \"" + evidence_path.gsub("/","\\") + "\" " + inum + " >> \"" + File.join(output_path.gsub("/","\\"), "\\$MFT") + "\""
                        result = nil
                        log += Helpers.put_return("Command:\n "+ command)
                        Timeout::timeout(1800) {result=system(command) ? "Success" : "Failed"} rescue Timeout::Error
                        if result == "Success" or result == "Failed"
                            log += Helpers.put_return("icat: "+ result+"\n")
                        end
                    end
                end
            end
        end     
    end
end


log += Helpers.put_return("\nMFT extraction complete.")

log_path = Helpers.get_script_log_path(paths_file)
Dir.chdir(log_path)

open('carve-mft.log', 'a+') {|f| f.puts log}

sleep 5
exit