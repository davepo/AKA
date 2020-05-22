#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component: Event log parser
#Purpose:	This script automates parsing evtx files to
#			csv files
#Supporting tool: EvtxECmd.exe 
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
tools = Dir.children(tools_dir)

log += put_return("\nMft parser directory:\n")
evtxcmd_dir = ""
tools.each do |tool|
	tool = tools_dir+"/"+tool
	if File.directory?(tool) 
		temp = tool.downcase
		if temp.include? "evtx"
			evtxcmd_dir = tool.gsub("\\","/")
			log += put_return(evtxcmd_dir + "\n")
		end
	end
end


log += put_return("\nEvtx parser executable:\n")
Dir.chdir(evtxcmd_dir)
evtxcmd_exe = evtxcmd_dir + "/EvtxECmd.exe "
log += put_return(evtxcmd_exe + "\n")

log += put_return("\nEvtx folder paths:\n")
evtx_folder_paths = []
export_paths = File.open(paths_file)
export_paths.each do |line| 
	temp = line.downcase
	temp.gsub("\\","/")
	if temp.include? "event_logs"
		evtx_folder_paths << line.chop
		log += put_return(line.chop + "\n")
	end
end

evtx_folder_paths.each do |path|
	evtx_logs = Dir.children(path)
	evtx_logs.each do |item|
		if item.include? ".evtx"
			chopped = path.chop
			command = "\"" + evtxcmd_exe + "\" -f \"" + path + item + "\" --csv \"" + chopped + "\" --csvf " + item.gsub(".evtx",".csv")
			command.gsub("\\","/")
			result = nil
			log += put_return("Command:\n "+ command)
			Timeout::timeout(360) {result=system(command) ? "Success" : "Failed"} rescue Timeout::Error
			if result == "Success" or result == "Failed"
				log += put_return("Evtx parser: "+ item + "   " + result+"\n")
			else 
				kill = %x( taskkill /IM MFTEcmd.exe /F )
				log += put_return("Timeout: Killing MFt parser... " + item + "   " + kill + "\n")
				sleep 10
			end
		end
	end

end


log += put_return("\nEvtx processing complete.")

aka_index = paths_file.index("AKA_Export")
aka_offset = aka_index+10
aka_negative_offset = aka_offset-paths_file.length
aka_export_path = paths_file[0..aka_negative_offset]
log_path = aka_export_path+"aka_script_logs/"
Dir.chdir(log_path)

open('Evtx.log', 'w') {|f| f.puts log}

sleep 5
exit