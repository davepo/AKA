#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component: Automated RegRipper  
#Purpose: 	This script automates running 
#			regripper against extracted registry file artifacts.
#Supporting tool: rip.exe 
#Supporting URL: https://github.com/keydet89/RegRipper2.8
#Developer: Dave Posocco

require 'timeout'

if ARGV.length != 3
	puts "I need three arguments!"
	exit
end

def put_return (string)
	puts string
	return string+"\n"
end

aka_script_path =ARGV[0]
paths_file = ARGV[1]
evidence_paths_file= ARGV[2]

log = ""
$stdout.sync=true

tools_dir = aka_script_path+"/tools"
tools = Dir.children(tools_dir)

log += put_return("\n\nRegRipper directory:\n")
regripper_dir = ""
tools.each do |tool|
	tool = tools_dir+"/"+tool
	if File.directory?(tool) 
		temp = tool.downcase
		if temp.include? "regripper"
			regripper_dir = tool.gsub("\\","/")
			log += put_return(regripper_dir + "\n")
		end
	end
end

log += put_return("\nRegripper executable:\n")
Dir.chdir(regripper_dir)
rr_exe = regripper_dir + "/rip.exe"
log += put_return(rr_exe + "\n")

log += put_return("\nRegistry paths:\n")
reg_folder_paths = []
export_paths = File.open(paths_file)
export_paths.each do |line| 
	temp = line.downcase
	temp.gsub("\\","/")
	if temp.include? "registry"
		reg_folder_paths << line.chop
		log += put_return(line.chop + "\n")
	end
end

log += put_return("\nRunning regripper:\n")
def run_regripper (path, rr_exe, log_res)
	dir_items = Dir.children(path)
	dir_items.each do |original_item|
		name = original_item
		item = path + original_item
		if File.directory?(item)
			log_res += run_regripper(item+"\\", rr_exe, log_res)
		elsif File.file?(item) and !item.include? ".txt"
			command = ""
			command = "\""+rr_exe + "\""+" -r " + "\""+item+"\""
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
	log += put_return(run_regripper(path, rr_exe, ""))
end

log += put_return("\n\nRegRipper processing complete.")

aka_index = paths_file.index("AKA_Export")
aka_offset = aka_index+10
aka_negative_offset = aka_offset-paths_file.length
aka_export_path = paths_file[0..aka_negative_offset]
log_path = aka_export_path+"aka_script_logs/"
Dir.chdir(log_path)

open('RegRipper.log', 'w') {|f| f.puts log}

sleep 5
exit