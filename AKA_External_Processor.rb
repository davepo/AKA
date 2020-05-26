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

require_relative './AKA_Ruby_Script_helper'
include Helpers
$stdout.sync=true

if ARGV.length != 3
	puts "I need three arguments!"
	exit
end

log = ""
log += Helpers.put_return("***AKA Triage -External tools processor***")

sleep 1

log += Helpers.put_return("Hey guys!")
sleep 1

log += Helpers.put_return("It's me, Kyle. I'm over here too!")
sleep 1

log += Helpers.put_return("I guess I'll try to run those extra tools you added...")
sleep 1

log += Helpers.put_return("\nThis is the path for the processor script...")

aka_script_path = ARGV[0].gsub("\\","/")
log += Helpers.put_return(aka_script_path)

temp_string = "\nSetting present working directory to that!"
log += Helpers.put_return(temp_string)

Dir.chdir(aka_script_path)

log += Helpers.put_return("\nThis is the file containing the potential paths for exported items...")

paths_file = ARGV[1].gsub("\\","/")
log += Helpers.put_return(paths_file)

log += Helpers.put_return("\nThis is the file containing the paths of the evidence files...")

evidence_paths_file = ARGV[2].gsub("\\","/")
log += Helpers.put_return(evidence_paths_file)

log += Helpers.put_return("\nCreating the log fiels directory...")
log_path = Helpers.get_script_log_path(paths_file)
Dir.mkdir(log_path)
log += Helpers.put_return(log_path)

log += Helpers.put_return("\nHere are all the export paths:")

export_paths = File.open(paths_file)
export_paths.each do |line| 
	log += Helpers.put_return(line)
end
export_paths.closed?
export_paths.close

log += Helpers.put_return("\nHere are all the evidence paths:")

evidence_paths = File.open(evidence_paths_file)
evidence_paths.each do |line| 
	log += Helpers.put_return(line)
end
evidence_paths.closed?
evidence_paths.close


log += Helpers.put_return("\nCurrent working directory: ")

proc_dir = Dir.pwd
log += Helpers.put_return(proc_dir)


log += Helpers.put_return("\nScripts directory")

scripts_dir = proc_dir+"/scripts"
log += Helpers.put_return(scripts_dir)

script_files = Dir.children(scripts_dir)
script_files.each do |file| 
	log += Helpers.put_return(file)
end

log += Helpers.put_return("\nChaning to scripts dirctory...")

Dir.chdir(scripts_dir)
log += Helpers.put_return(Dir.pwd)

script_files.each do |file| 
	if file.include?(".rb") 
		command = "ruby "+"\""+file+"\" \""+aka_script_path+"\" \""+paths_file+"\" \""+evidence_paths_file+"\""
		log += Helpers.put_return("\nRunning command:\n"+ command + "\n")
		pid=Process.spawn(command)
		log += Helpers.put_return("Running "+file+" as PID "+pid.to_s + "\n")
		Process.wait(pid)
		
	end
end

log += Helpers.put_return("\nWell, looks like my work here is done.")

image_file = "AKA_Image.jpg"
Dir.chdir(aka_script_path)
exec("start "+image_file)

Dir.chdir(log_path)

open('AKA_EXternal_Processor.log', 'w') {|f| f.puts log}

sleep 5
exit