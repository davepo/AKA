#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component:  Jumplist Files parser
#Purpose:	This script parses the exported users
#			jumplist files into a csv
#Supporting tool:  JLEcmd.exe
#Supporting URL: https://ericzimmerman.github.io/#!index.md
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

log += put_return("\n\Jumplist parser directory:\n")
jlecmd_dir = tools_dir
log += put_return(jlecmd_dir+ "\n")

log += put_return("\Jumplist parser executable:\n")
Dir.chdir(jlecmd_dir)
jlecmd_exe = jlecmd_dir + "/JLEcmd.exe"
log += put_return(jlecmd_exe + "\n")

log += put_return("\Jumplist folder paths:\n")
jumplist_folder_paths = []
export_paths = File.open(paths_file)
export_paths.each do |line| 
	temp = line.downcase
	temp.gsub("\\","/")
	if temp.include? "jumplist"
		jumplist_folder_paths << line.chop
		log += put_return(line.chop + "\n")
	end
end

log += put_return("\nRunning jumplist parser:\n")
jumplist_folder_paths.each do |path|
	chopped = path.chop
	command = "\"" + jlecmd_exe + "\" -d \"" + chopped + "\" --csv \"" + chopped + "\" --csvf Parsed_Jumplist_files.csv"
	command.gsub("\\","/")
	result = nil
	log += put_return("Command:\n "+ command)
	Timeout::timeout(180) {result=system(command) ? "Success" : "Failed"} rescue Timeout::Error
	if result == "Success" or result == "Failed"
		log += put_return("Jumplist parser: "+ result+"\n")
	else 
		kill = %x( taskkill /IM JLEcmd.exe /F )
		log += put_return("Timeout: Killing jumplist parser... " + kill + "\n")
		sleep 10
	end

end

log += put_return("\n\Jumplist processing complete.")


aka_index = paths_file.index("AKA_Export")
aka_offset = aka_index+10
aka_negative_offset = aka_offset-paths_file.length
aka_export_path = paths_file[0..aka_negative_offset]
log_path = aka_export_path+"aka_script_logs/"
Dir.chdir(log_path)

open('Jumplist.log', 'w') {|f| f.puts log}


sleep 5
exit