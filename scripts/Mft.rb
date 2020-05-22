#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component: Mft parrser
#Purpose:	This script automates parsing mft files to
#			a csv file
#Supporting tool: MFTECmd.exe 
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

log += put_return("\nMft parser directory:\n")
mftcmd_dir = tools_dir
log += put_return(mftcmd_dir+ "\n")

log += put_return("\nMft parser executable:\n")
Dir.chdir(mftcmd_dir)
mftcmd_exe = mftcmd_dir + "/MFTEcmd.exe"
log += put_return(mftcmd_exe + "\n")

log += put_return("\nMft folder paths:\n")
mft_folder_paths = []
export_paths = File.open(paths_file)
export_paths.each do |line| 
	temp = line.downcase
	temp.gsub("\\","/")
	if temp.include? "mft"
		mft_folder_paths << line.chop
		log += put_return(line.chop + "\n")
	end
end

mft_folder_paths.each do |path|
	chopped = path.chop
	command = "\"" + mftcmd_exe + "\" -f \"" + path + "$MFT" + "\" --csv \"" + chopped + "\" --csvf Parsed_MFT.csv"
	command.gsub("\\","/")
	result = nil
	log += put_return("Command:\n "+ command)
	Timeout::timeout(1800) {result=system(command) ? "Success" : "Failed"} rescue Timeout::Error
	if result == "Success" or result == "Failed"
		log += put_return("Mft parser: "+ result+"\n")
	else 
		kill = %x( taskkill /IM MFTEcmd.exe /F )
		log += put_return("Timeout: Killing MFt parser... " + kill + "\n")
		sleep 10
	end

end


log += put_return("\nMft processing complete.")

aka_index = paths_file.index("AKA_Export")
aka_offset = aka_index+10
aka_negative_offset = aka_offset-paths_file.length
aka_export_path = paths_file[0..aka_negative_offset]
log_path = aka_export_path+"aka_script_logs/"
Dir.chdir(log_path)

open('Mft.log', 'w') {|f| f.puts log}

sleep 5
exit