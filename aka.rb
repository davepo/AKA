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
include Helpers
$stdout.sync=true

case ARGV.length 
when 0
    puts "I need two arguments!"
    puts "Use -h or --help for help."
    exit
when 1
    if ARGV[0].to_s.include?("-h") or ARGV[0].to_s.include?("--help")
        puts "\nAKA Standalone Launcher Help\n\n"
        puts "Usage:\n   aka.rb {System} {Evidence} {Output}\n\n"
        puts "\'System\' is the evidence operating system"
        puts "    -Currently supported: {win10}"
        puts "\'Evidence\' should be the full path to an E01 or Raw image file."
        puts "\'Output\' is the directory you would like the \'AKA_Export\' folder created in.\n\n"
        puts "Example:\n"
        puts "   aka.rb win10 \"Drive:\\Path\\To\\Evidence.e01\" \"Drive:\\Path\\To\\Store\\Output\\\"\n\n"
    else
        puts "Invalid arguments."
        puts "Type -h or --help for usage.\n\n"
    end
    exit
when 2
    puts "Invalid arguments."
    puts "Type -h or --help for usage.\n\n"
    exit
when 3
    puts "Correct number of arguments detected ... "
    unless ARGV[0] == "win10"
        puts "Invalid argument: " + ARGV[0]
        puts "Type -h or --help for usage.\n\n"
        exit
    end
else
    puts "Invalid arguments."
    puts "Type -h or --help for usage.\n\n"
    exit
end


log = ""
log += Helpers.put_return("***AKA Standalone Triage Processor***")

evidence = ARGV[1]
aka_export = File.join(ARGV[2],"/AKA_Export")
Helpers.make_dir(aka_export)

proc_dir = __dir__
scripts_dir = File.join(proc_dir,"/scripts")
tools_dir = File.join(proc_dir, "/tools")
Dir.chdir(proc_dir)
log += Helpers.put_return("\nCurrent directory: #{proc_dir} \nScripts directory: #{scripts_dir} \nTools directory: #{} \nExport folder: #{} \nEvidence file: #{evidence} \n")

ev_id_export = File.join(aka_export, File.basename(evidence, ".*"))
Helpers.make_dir(ev_id_export)
log_path = File.join(aka_export, "/aka_script_logs")
Helpers.make_dir(log_path)
av_log_path = File.join(aka_export, "/av_scans")
Helpers.make_dir(av_log_path)

log += Helpers.put_return("Created the directories...\nEvidence identified export folder: #{ev_id_export} \nLog output folder: #{log_path} \nAV scan output folder: #{av_log_path} \n")

evidence_paths_file = File.join(aka_export, "/evidencePaths.txt")
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
end
log += Helpers.put_return("\nWrote file: "+ evidence_paths_file + "\n")

paths_file = File.join(aka_export, "/exportsPaths.txt") 
paths_list = []

Dir.chdir(scripts_dir)
script_files = Dir.children(scripts_dir)

def run_script(ruby_script, arg1, arg2, arg3, optional)
    run_log = ""
    if optional == ""
        command = "ruby "+"\""+ruby_script+"\" \""+arg1+"\" \""+arg2+"\" \""+arg3+"\""
    else
        command = "ruby "+"\""+ruby_script+"\" \""+arg1+"\" \""+arg2+"\" \""+arg3+"\" \""+optional+"\""
    end
	run_log += Helpers.put_return("\nRunning command:\n"+ command + "\n")
	pid=Process.spawn(command)
	run_log += Helpers.put_return("Running "+ruby_script+" as PID "+pid.to_s + "\n")
	Process.wait(pid)
	return run_log
end

log += Helpers.put_return("\nAttempting to mount evidence files...\n")
pre_mount_drives = Helpers.get_drives()
post_mount_drives = []
mounted_drives = []
script_files.each do |file|
	if file.include?("ImageMounter.rb")
		log += run_script(file, proc_dir, paths_file, evidence_paths_file, "")
	end
end
post_mount_drives = Helpers.get_drives()
mounted_drives = post_mount_drives - pre_mount_drives
mounted_drives_string = ""
mounted_drives.each do |letter|
	mounted_drives_string += letter
end

#main
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

    #Suspicious files

    #MFT
    log += Helpers.put_return("\nAttempting to extract the MFT...")
    if File.exist?(drive+":/$MFT")
        Dir.chdir(proc_dir)
        log += run_script("carve-mft.rb", evidence, mft_path, paths_file, "")
    end
        

    #Write paths file
    File.open(paths_file, 'a+') do |file| 
        paths_list.each do |list_line|
            found = false
            file.each do |line|
                if line.include?(list_line)
                    found = true
                end
            end
            unless found
                file.puts list_line
            end
        end     
    end
    log += Helpers.put_return("\nWrote file: "+ paths_file + "\n")

    #Cleanup
    Helpers.delete_empty_dirs(aka_export)
    log += Helpers.put_return("\nRemoved empty directories from export folder.\n")

    
end

log_path = Helpers.get_script_log_path(paths_file)
Dir.chdir(log_path)
    
open('aka_standalone_extractor.log', 'w') {|f| f.puts log}

Dir.chdir(proc_dir)
run_script("AKA_External_Processor.rb", proc_dir, paths_file, evidence_paths_file, mounted_drives_string)

sleep 5
exit