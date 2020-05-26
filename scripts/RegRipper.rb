#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component: Automated RegRipper  
#Purpose: 	This script automates running 
#			regripper against extracted registry file artifacts.
#Supporting tool: rip.exe 
#Supporting URL: https://github.com/keydet89/RegRipper2.8
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

log += Helpers.put_return("\nRegripper executable and paths:\n")
rr_exe = "rip.exe"
rr_full_path = Helpers.find_exe_path(rr_exe, tools_dir)
rr_dir = rr_full_path.gsub(rr_exe, "")
rr_dir.chop!

log += Helpers.put_return(rr_exe + "\n" + rr_dir + "\n" + rr_full_path + "\n\n")

Dir.chdir(rr_dir)

log += Helpers.put_return("\nRegistry file folder paths:\n")
reg_folder_paths = Helpers.find_all_paths_with_term("registry", paths_file)
reg_folder_paths.each {|line| log += Helpers.put_return(line.chop + "\n")}


log += Helpers.put_return("\nRunning regripper:\n")
def run_regripper (path, rr_full_path, log_res)
	dir_items = Dir.children(path)
	dir_items.each do |original_item|
		name = original_item
		item = path + original_item
		if File.directory?(item)
			log_res += run_regripper(item+"\\", rr_full_path, log_res)
		elsif File.file?(item) and !item.include? ".txt"
			command = ""
			command = "\""+rr_full_path + "\""+" -r " + "\""+item+"\""
			case name.downcase		
				when "system"
					command += " -f system"
				when "security"
					command += " -f security"
				when "sam"
					command += + " -f sam"
				when "software"
					command += " -f software"
				when "amcache.hve"
					command += " -f amcache"
				when "ntuser.dat"
					command += " -f ntuser"
				when "userclass.dat"
					command += " -f userclass"
			end
			command += " > \"" + item +"-Ripped.txt\""
			command.gsub!("\\","/")
			result = nil
			Timeout::timeout(900) {result=system(command) ? "Success" : "Failed"} rescue Timeout::Error
			if result == "Success" or result == "Failed"
				log_res += name+" "+ result+"\n"
			else 
				kill = %x( taskkill /IM rip.exe /F )
				log_res += "Timeout: Killing... "+name+ " "+kill +"\n"
				sleep 10
			end
		end
	end
	return log_res
end

reg_folder_paths.each do |path|
	log += Helpers.put_return(run_regripper(path, rr_full_path, ""))
end

log += Helpers.put_return("\n\nRegRipper processing complete.")

log_path = Helpers.get_script_log_path(paths_file)
Dir.chdir(log_path)

open('Registry_rip.log', 'w') {|f| f.puts log}

sleep 5
exit