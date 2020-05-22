#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component: External processor
#Purpose: 	This script automates running additional programs by
#			running all scripts in the designated folder with the
#			arguments of the exporst paths file, the evidence paths
#			file, and the scripts location.  It outputs a log of
#			all activites into the AKA_Exports folder.
#Supporting tool: Ruby
#Supporting URL: ruby-lang.org
#Developer: Dave Posocco

if ARGV.length != 3
	puts "I need three arguments!"
	exit
end

def put_return (string)
	puts string
	return string+"\n"
end

log = ""
log += put_return("***AKA Triage -External tools processor***")

sleep 1

log += put_return("Hey guys!")
sleep 1

log += put_return("It's me, Kyle. I'm over here too!")
sleep 1

log += put_return("I guess I'll try to run those extra tools you added...")
sleep 1

log += put_return("\nThis is the path for the processor script...")

aka_script_path = ARGV[0]
aka_script_path = aka_script_path.gsub("\\","/")
log += put_return(aka_script_path)

temp_string = "\nSetting present working directory to that!"
log += put_return(temp_string)

Dir.chdir(aka_script_path)

log += put_return("\nThis is the file containing the potential paths for exported items...")

paths_file = ARGV[1]
paths_file = paths_file.gsub("\\","/")
log += put_return(paths_file)

log += put_return("\nThis is the file containing the paths of the evidence files...")

evidence_paths_file = ARGV[2]
evidence_paths_file = evidence_paths_file.gsub("\\","/")
log += put_return(evidence_paths_file)

log += put_return("\nCreating the log fiels directory...")
aka_index = paths_file.index("AKA_Export")
aka_offset = aka_index+10
aka_negative_offset = aka_offset-paths_file.length
aka_export_path = paths_file[0..aka_negative_offset]
log_path = aka_export_path+"aka_script_logs/"
Dir.mkdir(log_path)
log += put_return(log_path)

log += put_return("\nHere are all the export paths:")

export_paths = File.open(paths_file)
export_paths.each do |line| 
	log += put_return(line)
end
export_paths.closed?
export_paths.close

log += put_return("\nHere are all the evidence paths:")

evidence_paths = File.open(evidence_paths_file)
evidence_paths.each do |line| 
	log += put_return(line)
end
evidence_paths.closed?
evidence_paths.close


log += put_return("\nCurrent working directory: ")

proc_dir = Dir.pwd
log += put_return(proc_dir)


log += put_return("\nScripts directory")

scripts_dir = proc_dir+"/scripts"
log += put_return(scripts_dir)

script_files = Dir.children(scripts_dir)
script_files.each do |file| 
	log += put_return(file)
end

log += put_return("\nChaning to scripts dirctory...")

Dir.chdir(scripts_dir)
log += put_return(Dir.pwd)

script_files.each do |file| 
	if file.include?(".rb") 
		command = "ruby "+"\""+file+"\" \""+aka_script_path+"\" \""+paths_file+"\" \""+evidence_paths_file+"\""
		log += put_return("\nRunning command:\n"+ command + "\n")
		pid=Process.spawn(command)
		log += put_return("Running "+file+" as PID "+pid.to_s + "\n")
		Process.wait(pid)
		
	end
end

log += put_return("\nWell, looks like my work here is done.")


Dir.chdir(log_path)

open('AKA_EXternal_Processor.log', 'w') {|f| f.puts log}

sleep 5
exit