#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component: Automated Prefetch Parsing 
#Purpose:	This script automates running PEcmd.exe
#			(an Eric Zimmerman tool) against extracted
#			prefetch files.
#Supporting tool: PEcmd.exe 
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

log += put_return("\n\nPrefetch parser directory:\n")
pecmd_dir = tools_dir
log += put_return(pecmd_dir+ "\n")

log += put_return("\Prefetch parser executable:\n")
Dir.chdir(pecmd_dir)
pecmd_exe = pecmd_dir + "/PEcmd.exe"
log += put_return(pecmd_exe + "\n")

log += put_return("\Prefetch folder paths:\n")
prefetch_folder_paths = []
export_paths = File.open(paths_file)
export_paths.each do |line| 
	temp = line.downcase
	temp.gsub("\\","/")
	if temp.include? "prefetch"
		prefetch_folder_paths << line.chop
		log += put_return(line.chop + "\n")
	end
end

log += put_return("\nRunning prefetch parser:\n")
prefetch_folder_paths.each do |path|
	chopped = path.chop
	command = "\"" + pecmd_exe + "\" -d \"" + chopped + "\" --csv \"" + chopped + "\" --csvf Parsed_Prefetch.csv"
	command.gsub("\\","/")
	result = nil
	log += put_return("Command:\n "+ command)
	Timeout::timeout(180) {result=system(command) ? "Success" : "Failed"} rescue Timeout::Error
	if result == "Success" or result == "Failed"
		log += put_return("Prefetch parser: "+ result+"\n")
	else 
		kill = %x( taskkill /IM PEcmd.exe /F )
		log += put_return("Timeout: Killing prefetch parser... " + kill + "\n")
		sleep 10
	end

end

log += put_return("\n\nPrefetch processing complete.")

aka_index = paths_file.index("AKA_Export")
aka_offset = aka_index+10
aka_negative_offset = aka_offset-paths_file.length
aka_export_path = paths_file[0..aka_negative_offset]
log_path = aka_export_path+"aka_script_logs/"
Dir.chdir(log_path)

open('Prefetch.log', 'w') {|f| f.puts log}

sleep 5
exit