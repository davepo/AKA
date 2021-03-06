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
require 'fileutils'
include Helpers
$stdout.sync=true

if ARGV.length != 3
	unless ARGV.length == 4 || ARGV.length == 5
		puts "I need 3 to 5 arguments!"
		exit
	end
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

mounted_drives_string = ""
unless ARGV[3] == nil
	mounted_drives_string = ARGV[3]
end

skip_av_scan = ""
unless ARGV[4] == nil
	skip_av_scan = ARGV[4]
end

log += Helpers.put_return("\nCreating the log files directory...")
log_path = Helpers.get_script_log_path(paths_file)
unless File.exist?(log_path)
	Dir.mkdir(log_path)
end
log += Helpers.put_return(log_path)

log += Helpers.put_return("\nCreating the AV scan results directory...")
av_log_path = Helpers.get_av_scan_output_path(paths_file)
unless File.exist?(av_log_path)
	Dir.mkdir(av_log_path)
end
log += Helpers.put_return(av_log_path)

log += Helpers.put_return("\nCreating the autoruns scan results directory...")
autoruns_log_path = Helpers.get_autoruns_output_path(paths_file)
unless File.exist?(autoruns_log_path)
	Dir.mkdir(autoruns_log_path)
end
log += Helpers.put_return(autoruns_log_path)

log += Helpers.put_return("\nCreating the filters output directory...")
filters_output_path = Helpers.get_filter_output_path(paths_file)
unless File.exist?(filters_output_path)
	Dir.mkdir(filters_output_path)
end
log += Helpers.put_return(filters_output_path)

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

proc_dir = __dir__
log += Helpers.put_return(proc_dir)


log += Helpers.put_return("\nScripts directory")

scripts_dir = File.join(proc_dir,"/scripts")
log += Helpers.put_return(scripts_dir)

filters_dir = File.join(proc_dir,"/filters")
log += Helpers.put_return(filters_dir)

script_files = Dir.children(scripts_dir)
script_files.each do |file| 
	log += Helpers.put_return(file)
end

filter_files =  Dir.children(filters_dir)
filter_files.each do |file|
	log += Helpers.put_return(file)
end

log += Helpers.put_return("\nChaning to scripts directory...")

def run_script(ruby_script, aka, paths, evidence)
	run_log = ""
	command = "ruby "+"\""+ruby_script+"\" \""+aka+"\" \""+paths+"\" \""+evidence+"\""
	run_log += Helpers.put_return("\nRunning command:\n"+ command + "\n")
	pid=Process.spawn(command)
	run_log += Helpers.put_return("Running "+ruby_script+" as PID "+pid.to_s + "\n")
	Process.wait(pid)
	return run_log
end

Dir.chdir(scripts_dir)
log += Helpers.put_return(Dir.pwd)
log += Helpers.put_return("\nAttempting to start running scripts...")
script_files.each do |file| 
	if file.include?(".rb") 
		unless file.include?("ImageMounter") or file.include?("AVScan") or file.include?("Autoruns")
			log += run_script(file, aka_script_path, paths_file, evidence_paths_file)
		end
	end
end

Dir.chdir(filters_dir)
log += Helpers.put_return(Dir.pwd)
log += Helpers.put_return("\nAttempting to start filtering...")
filter_files.each do |file| 
	if file.include?(".rb") 
		log += run_script(file, aka_script_path, paths_file, evidence_paths_file)
	end
end

Dir.chdir(proc_dir)
log += Helpers.put_return(Dir.pwd)
if mounted_drives_string == ""
	log += Helpers.put_return("\nAttempting to mount evidence files...")
	pre_mount_drives = Helpers.get_drives()
	post_mount_drives = []
	mounted_drives = []
	log += run_script("ImageMounter.rb", aka_script_path, paths_file, evidence_paths_file)

	post_mount_drives = Helpers.get_drives()
	mounted_drives = post_mount_drives - pre_mount_drives
	mounted_drives.each do |letter|
		mounted_drives_string += letter
	end
end

if File.exist?(File.join(scripts_dir, "Autoruns.rb"))
	Dir.chdir(scripts_dir)
	log += Helpers.put_return("\nAttempting to run autoruns scans...")
	log += run_script("Autoruns.rb", mounted_drives_string, paths_file, "")
end

if File.exist?(File.join(scripts_dir, "AVScan.rb")) && skip_av_scan != "true"
	Dir.chdir(scripts_dir)
	log += Helpers.put_return("\nAttempting to run AV scans...")
	log += run_script("AVScan.rb", mounted_drives_string, paths_file, "")
end

log += Helpers.put_return("\nAttempting to close windows and remove mounted images...")

tools_dir = File.join(proc_dir,"/tools")
aim_ll = Helpers.find_exe_path("aim_ll.exe", tools_dir)
kill = %x( taskkill /IM cmd.exe /F )
log += Helpers.put_return("Killing cmd.exe processes... " + kill + "\n")

unmount=system(aim_ll+" -d") ? "Success" : "Failed"
log += Helpers.put_return("Unmounted virtual drives... " + unmount + "\n")

log += Helpers.put_return("\nAttempting to remove differencing images...")
Helpers.delete_diff_files(evidence_paths_file)

log += Helpers.put_return("\nWell, looks like my work here is done.")

if ARGV.length == 4
	image_file = "AKA_Image_Standalone.jpg"
else
	image_file = "AKA_Image.jpg"
end
Dir.chdir(aka_script_path)

showimage=system("start "+image_file) ? "Success" : "Failed"
log += Helpers.put_return("Displayed Image ... " + unmount + "\n")

Dir.chdir(log_path)
open('AKA_EXternal_Processor.log', 'a+') {|f| f.puts log}

time = Time.new
puts "\nRenaming export folder .... "
Dir.chdir(Helpers.get_aka_export_path(paths_file))
Dir.chdir("..")
File.rename("./AKA_Export", "./AKA_Export-"+time.strftime("%y%m%d%H%M"))
puts "\nExport folder renamed and tagged with date stamp."

sleep 5
exit