#Project: AKA Triage Suite
#Sub-Project: AKA Standalone
#Component: Standalone extractor and launcher
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

source_type = ""
source = ""
output_path = ""
class_type = ""
help = false
export_only = false
no_av_scan = "false"

for i in 0 ... ARGV.length
   if ARGV[i] == "-h" || ARGV[i] == "--help"
		help = true
   elsif ARGV[i] == "-s" || ARGV[i] == "--source"
		source_type = ARGV[i+1]
		source = ARGV[i+2]
	elsif (ARGV[i] == "-c" || ARGV[i] == "--class") && source != ""
		class_type = ARGV[i+1]
	elsif (ARGV[i] == "-o" || ARGV[i] == "--output") && source != ""
		output_path = ARGV[i+1]
	elsif ARGV[i] == "--export-only"
		export_only = true
	elsif ARGV[i] == "--no-av-scan"
		no_av_scan = "true"
	end
end

if help==true
	puts "\nAKA Standalone Help\n\n"
	puts "Usage:\n"
	puts "\taka.rb -s|--source {Source Type} {Source Path} -o|--output {Output Path}\n\n"
	puts "Source Type {img|vol|dir}:\n\timg -> image -> Can be an .E01, .DD, .IMG, .001, .VDI, .VHD, .VHDX, or .VMDK format image file.\n\tvol -> volume -> A mounted drive path.\n\tdir -> directory -> A directory containing one or more image file (subdirectories included)\n\n"
	puts "Source:\nPath to the source.\n\tAn image file: ie. \"C:\\Evidence\\file.E01\"\nA mounted volume: ie. \"E:\\\"\n\tA directory of image files: \"C:\\Evidence\"\n\n"
	puts "Image example:\n\taka.rb -s img \"C:\\Evidence\\file.E01\" -o \"C:\\Cases\\Output\"\n"
	puts "Image example:\n\taka.rb -s vol \"E:\\\" -o \"C:\\Cases\\Output\"\n"
	puts "Image example:\n\taka.rb -s dir \"D:\\Evidence\\ImageFiles\" -o \"C:\\Cases\\Output\"\n\n"
	puts "\nUse the option \"--export-only\" to export artifacts, but not run any tools or filters.\n\n"
	puts "\nUse the option \"--no-av-scan\" to export artifacts, run tools and filters, but skip AV scanning the evidence target.\n\n"
	exit
end

if source == "" || source_type == "" || output_path == ""
	puts "\nInvalid arguments or argument format!"
	puts "Use '-h' or '--help' for help.\n\n"
	exit
end

unless source_type == "vol" || source_type == "img" || source_type == "dir" 
	puts "\nSource Type argument error!"
	puts "Valid arguments are 'vol', 'img', or 'dir'."
	puts "Use '-h' or '--help' for help.\n\n"
	exit
end

unless File.exist?(source)
	puts "\nError, provided source does not exist!"
	puts "Use '-h' or '--help' for help.\n\n"
	exit
end

unless File.exist?(output_path)
	puts "\nError, provided output path does not exist!"
	puts "Use '-h' or '--help' for help.\n\n"
	exit
end

valid_types = [".e01", ".dd", ".raw", ".001", ".img", ".vdi", ".vhd", ".vmdk"]
if source_type == "img"
	unless valid_types.include?(File.extname(source).downcase) 
		puts "\nError, not a valid image type."
		puts "Use '-h' or '--help' for help.\n\n"
		exit
	end
end

if File.exist?(File.join(output_path,"/AKA_Export"))
	puts "\nError!! An 'AKA_Export' folder already exists in the output path."
	puts "Please remove or rename before trying again.\n\n"
	exit
end

log = ""
log += Helpers.put_return("***AKA Standalone Triage Processor***")

aka_export = File.join(output_path,"/AKA_Export")
Helpers.make_dir(aka_export)

proc_dir = __dir__
scripts_dir = File.join(proc_dir,"/scripts")
tools_dir = File.join(proc_dir, "/tools")
Dir.chdir(proc_dir)
log += Helpers.put_return("\nCurrent directory: #{proc_dir} \nScripts directory: #{scripts_dir} \nTools directory: #{tools_dir} \nExport folder: #{aka_export}\n")

evidence_list = []

if source_type == "img" || source_type == "vol"
	evidence_list << source
elsif source_type == "dir"
	valid_types.each do |type|
		evidence_list = evidence_list + Dir.glob(File.join(source.gsub('\\','/'),"/**/*#{type}"))
	end
end

evidence_paths_file = File.join(aka_export, "/evidencePaths.txt")
evidence_list.each do |evidence|
	File.open(evidence_paths_file, 'a+') do |file| 
		found = false
		file.each do |line|
			if line.include?(evidence)
				found = true
			end
		end
		unless found
			file.puts evidence
		end
		file.close
	end
end
log += Helpers.put_return("\nWrote file: "+ evidence_paths_file + "\n")

paths_file = File.join(aka_export, "/exportsPaths.txt") 
paths_list = []
mounted_drives_string = ""

def run_script(ruby_script, arg1, arg2, arg3, optional_1, optional_2)
	run_log = ""
	if optional_1 == ""
		command = "ruby "+"\""+ruby_script+"\" \""+arg1+"\" \""+arg2+"\" \""+arg3+"\""
	elsif optional_2 == ""
		command = "ruby "+"\""+ruby_script+"\" \""+arg1+"\" \""+arg2+"\" \""+arg3+"\" \""+optional_1+"\""
	else
		command = "ruby "+"\""+ruby_script+"\" \""+arg1+"\" \""+arg2+"\" \""+arg3+"\" \""+optional_1+"\" \""+optional_2+"\""
	end
	run_log += Helpers.put_return("\nRunning command:\n"+ command + "\n")
	pid=Process.spawn(command)
	run_log += Helpers.put_return("Running "+ruby_script+" as PID "+pid.to_s + "\n")
	Process.wait(pid)
	return run_log
end

#Main
evidence_list.each do |evidence|

	if source_type == "vol"
		ev_id_export = File.join(aka_export, "mounted_volume")
	else
		ev_id_export = File.join(aka_export, File.basename(evidence, ".*"))
	end

	Helpers.make_dir(ev_id_export)
	log_path = File.join(aka_export, "/01-Script_logs")
	Helpers.make_dir(log_path)
	av_log_path = File.join(aka_export, "/03-AV_scans_results")
	Helpers.make_dir(av_log_path)

	log += Helpers.put_return("Created the directories...\nEvidence identified export folder: #{ev_id_export} \nLog output folder: #{log_path} \nAV scan output folder: #{av_log_path} \n")
	
	mounted_drives = []
	unless source_type == "vol" 
		log += Helpers.put_return("\nAttempting to mount evidence file...\n")
		pre_mount_drives = Helpers.get_drives()
		post_mount_drives = []		
		Dir.chdir(proc_dir)
		log += run_script("ImageMounter.rb", proc_dir, paths_file, evidence, "", "")
		post_mount_drives = Helpers.get_drives()

		mounted_drives = mounted_drives + (post_mount_drives - pre_mount_drives)
		
		mounted_drives.each do |letter|
			unless mounted_drives_string.include?(letter)
				mounted_drives_string += letter
			end
		end

	else
		mounted_drives << evidence[0]
		mounted_drives_string = evidence[0]
	end

	mounted_drives.each do |drive|
		log += Helpers.put_return("\nExtracticting artifacts from mounted drive: "+drive+":\\\n")
		paths_list << ev_id_export + "/"

		current_drive_path = File.join(ev_id_export, drive)
		Helpers.make_dir(current_drive_path)
		paths_list << current_drive_path + "/"

		evt_path = File.join(File.join(ev_id_export, drive),"Event_Logs")
		Helpers.make_dir(evt_path)
		paths_list << evt_path + "/"

		reg_file_path = File.join(File.join(ev_id_export, drive),"Registry_Files")
		Helpers.make_dir(reg_file_path)
		paths_list << reg_file_path + "/"

		Helpers.make_dir(File.join(File.join(ev_id_export, drive),"AV_Logs"))
		av_path_mc = File.join(File.join(File.join(ev_id_export, drive),"AV_Logs"),"McAfee")
		Helpers.make_dir(av_path_mc)
		paths_list << av_path_mc + "/"
		av_path_sym = File.join(File.join(File.join(ev_id_export, drive),"AV_Logs"),"Symantec")
		Helpers.make_dir(av_path_sym)
		paths_list << av_path_sym + "/"
		av_path_windef = File.join(File.join(File.join(ev_id_export, drive),"AV_Logs"),"Defender")
		Helpers.make_dir(av_path_windef)
		paths_list << av_path_windef + "/"

		mft_path = File.join(File.join(ev_id_export, drive),"MFT")
		Helpers.make_dir(mft_path)
		paths_list << mft_path + "/"

		usnj_path = File.join(File.join(ev_id_export, drive),"UsnJournal")
		Helpers.make_dir(usnj_path)
		paths_list << usnj_path + "/"

		usb_path = File.join(File.join(ev_id_export, drive),"USB")
		Helpers.make_dir(usb_path)
		paths_list << usb_path + "/"

		suspicious_path = File.join(File.join(ev_id_export, drive),"Suspicious_Files")
		Helpers.make_dir(suspicious_path)
		paths_list << suspicious_path + "/"

		prefetch_files_path = File.join(File.join(ev_id_export, drive),"Prefetch")
		Helpers.make_dir(prefetch_files_path)
		paths_list << prefetch_files_path + "/"

		wbem_path = File.join(File.join(ev_id_export, drive),"WBEM_Repository")
		Helpers.make_dir(wbem_path)
		paths_list << wbem_path + "/"

		thumbcache_path = File.join(File.join(ev_id_export, drive),"Thumbcache_Files")
		Helpers.make_dir(thumbcache_path)
		paths_list << thumbcache_path + "/"

		lnk_path = File.join(File.join(ev_id_export, drive),"User_LNK_Files")
		Helpers.make_dir(lnk_path)
		paths_list << lnk_path + "/"

		jumplist_path = File.join(File.join(ev_id_export, drive),"User_Jumplist_Files")
		Helpers.make_dir(jumplist_path)
		paths_list << jumplist_path + "/"

		#Registry files
		log += Helpers.put_return("\nAttempting to extract registry artifacts...")
		Find.find(drive+":/windows/system32/config") do |item|
			regs = ["sam","software","system","security"]
			regs.each do |test_item|
				if File.basename(item).downcase == test_item
					Helpers.export_file(item, reg_file_path)
					log += Helpers.put_return("Extracting: "+ item)
				end
			end
		end
		if File.exist?(drive+":/Windows/appcompat/Programs/Amcache.hve")
			Helpers.export_file(drive+":/Windows/appcompat/Programs/Amcache.hve", reg_file_path)
			log += Helpers.put_return("Extracting: "+ drive+":/Windows/appcompat/Programs/Amcache.hve")
		end

		#Event Logs
		log += Helpers.put_return("\nAttempting to extract event logs...")
		Find.find(drive+":/windows/system32/winevt/logs") do |item|
			if File.extname(item) == ".evtx"
				if File.basename(item).include?("PnP%4Configuration") or File.basename(item).include?("ShimEngine%4Operational") 
					#USB relevant event logs get exported to both places
					Helpers.export_file(item, evt_path)
					Helpers.export_file(item, usb_path)
				else
					Helpers.export_file(item, evt_path)
				end
				log += Helpers.put_return("Extracting: "+ item)
			end
		end

		#USB
		log += Helpers.put_return("\nAttempting to extract USB artifacts...")
		Find.find(drive+":/windows/inf") do |item|
			if File.basename(item).downcase.include?("setupapi")
				Helpers.export_file(item, usb_path)
				log += Helpers.put_return("Extracting: "+ item)
			end
		end

		#WBEM
		log += Helpers.put_return("\nAttempting to extract WBEM artifacts...")
		if File.exist?(drive+":/Windows/System32/wbem/Repository")
			Helpers.export_folder(drive+":/Windows/System32/wbem/Repository", wbem_path)
			log += Helpers.put_return("Extracting: "+ drive+":/Windows/System32/wbem/Repository")
		end

		#Prefetch
		log += Helpers.put_return("\nAttempting to extract prefetch artifacts...")
		Find.find(drive+":/windows/prefetch") do |item|
			if File.extname(item) == ".pf"
				Helpers.export_file(item, prefetch_files_path)
				log += Helpers.put_return("Extracting: "+ item)
			end
		end

		#AV
		log += Helpers.put_return("\nAttempting to extract AV artifacts...")
		if File.exist?(drive+":/ProgramData/McAfee")
			Find.find(drive+":/ProgramData/McAfee") do |item|
				if File.extname(item) == ".log"
					Helpers.export_file(item, av_path_mc)
					log += Helpers.put_return("Extracting: "+ item)
				end
			end
		end
		if File.exist?(drive+":/ProgramData/Symantec")
			Find.find(drive+":/ProgramData/Symantec") do |item|
				if File.extname(item) == ".log"
					Helpers.export_file(item, av_path_sym)
					log += Helpers.put_return("Extracting: "+ item)
				end
			end
		end
		if File.exist?(drive+":/ProgramData/Microsoft/Windows Defender/Support")
			Find.find(drive+":/ProgramData/Microsoft/Windows Defender/Support") do |item|
				if File.extname(item) == ".log"
					Helpers.export_file(item, av_path_windef)
					log += Helpers.put_return("Extracting: "+ item)
				end
			end
		end

		#Users folder
		# lnk, thumbcache, ntuser.dat, userclass, jumplists
		log += Helpers.put_return("\nAttempting to extract User folder artifacts (lnk, thumbcache, ntuser.dat, userclass, jumplists)...")
		if File.exist?(drive+":/Users")
			userlist = []
			Dir.each_child(drive+":/Users") do |kid|
				if File.directory?(drive+":/Users/"+kid)
					userlist << kid
				end
			end

			userlist.each do |username|
				Helpers.make_dir(File.join(thumbcache_path,username))
				Helpers.make_dir(File.join(lnk_path,username)) 
				Helpers.make_dir(File.join(jumplist_path,username))
				paths_list << File.join(thumbcache_path,username) + "/"
				paths_list << File.join(lnk_path,username) + "/"
				paths_list << File.join(jumplist_path,username) + "/"
				
				Find.find(drive+":/Users/"+username) do |item|
					if File.basename(item).downcase == "ntuser.dat" 
						Helpers.export_file_as(item, username+"-NTUSER.DAT", reg_file_path)
						log += Helpers.put_return("Extracting User: " + username + ": " + item)
					elsif File.basename(item).downcase == "userclass.dat"
						Helpers.export_file_as(item, username+"UserClass.DAT", reg_file_path)
						log += Helpers.put_return("Extracting User: " + username + ": " + item)
					elsif File.basename(item).downcase.include?("thumbcache_") 
						Helpers.export_file(item, File.join(thumbcache_path,username))
						log += Helpers.put_return("Extracting User: " + username + ": " + item)
					elsif File.extname(item) == ".lnk"
						Helpers.export_file(item, File.join(lnk_path,username))
						log += Helpers.put_return("Extracting User: " + username + ": " + item)
					elsif File.basename(item).downcase.include?("automaticdestination-ms") 
						Helpers.export_file(item, File.join(jumplist_path,username))
						log += Helpers.put_return("Extracting User: " + username + ": " + item)
					elsif File.basename(item).downcase.include?("customdestinations-ms") 
						Helpers.export_file(item, File.join(jumplist_path,username))
						log += Helpers.put_return("Extracting User: " + username + ": " + item)
					end
				end
			
			end
		end

		#Suspicious files - Future addition.

		#MFT
		if File.exist?(drive+":/$MFT")
			Dir.chdir(proc_dir)
			log += Helpers.put_return("\nAttempting to extract MFT through low level methods...")
			log += run_script("carve-mft.rb", mounted_drives_string, mft_path, paths_file, "", "")
		end

		#USNJounral
		if File.exist?(drive+":/$Extend")
			Dir.chdir(proc_dir)
			log += Helpers.put_return("\nAttempting to extract UsnJrnl through low level methods...")
			log += run_script("carve-usnjournal.rb", mounted_drives_string, usnj_path, paths_file, "", "")
		end
		
		#Write log
		log_path = Helpers.get_script_log_path(paths_file)
		Dir.chdir(log_path)
		open('aka_standalone_extractor.log', 'a+') {|f| f.puts log}
		
		#Cleanup
		Helpers.delete_empty_dirs(aka_export)
        log += Helpers.put_return("\nRemoved empty directories from export folder.\n")
        
	end
end

#Write paths file
File.open(paths_file, 'a+') do |file| 
	file.puts paths_list.uniq
	file.close
end
log += Helpers.put_return("\nWrote file: "+ paths_file + "\n")

unless export_only
	Dir.chdir(proc_dir)
	run_script("AKA_External_Processor.rb", proc_dir, paths_file, evidence_paths_file, mounted_drives_string, no_av_scan)
else
	log += Helpers.put_return("\nAttempting to close windows and remove mounted images...")
	tools_dir = File.join(proc_dir,"/tools")
	aim_ll = Helpers.find_exe_path("aim_ll.exe", tools_dir)
	kill = %x( taskkill /IM cmd.exe /F )
	log += Helpers.put_return("Killing cmd.exe processes... " + kill + "\n")
	unmount=system(aim_ll+" -d") ? "Success" : "Failed"
	log += Helpers.put_return("Unmounted virtual drives... " + unmount + "\n")
	time = Time.new
	puts "\nRenaming export folder .... "
	Dir.chdir(Helpers.get_aka_export_path(paths_file))
	Dir.chdir("..")
	File.rename("./AKA_Export", "./AKA_Export-"+time.strftime("%y%m%d%H%M"))
	puts "\nExport folder renamed and tagged with date stamp."
end

sleep 5
exit