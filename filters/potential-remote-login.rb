#Project: AKA Triage Suite
#Sub-Project: Filters
#Component: Remote login filter
#Purpose:	This script automates parsing csv files to
#			consolidate remote login related activity
#Supporting tool: n/a
#Supporting URL: n/a
#Developer: Dave Posocco

require 'csv'
require_relative '../AKA_Ruby_Script_helper'
include Helpers
$stdout.sync=true

if ARGV.length != 3
	puts "I need three arguments!"
	exit
end

aka_script_path =ARGV[0]
paths_file = ARGV[1]
evidence_paths_file= ARGV[2]

log = ""

log += Helpers.put_return("\nEvent log folder paths:\n")
evtx_folder_paths = Helpers.find_all_paths_with_term("event_logs", paths_file)
evtx_folder_paths.each {|line| log += Helpers.put_return(line.chop + "\n")}


log += Helpers.put_return("\nFiltering remote login related event log data...\n")

script_output_path = File.join(Helpers.get_filter_output_path(paths_file),File.basename(__FILE__))
unless File.exist?(script_output_path)
    Dir.mkdir(script_output_path)
end

evtx_folder_paths.each do |path|
    drive_identifier = File.basename(File.expand_path('..', path))
    image_identifier = File.basename(File.expand_path('..',File.expand_path('..', path)))
    output_path = File.join(script_output_path,"#{image_identifier}-#{drive_identifier}/")
    unless File.exist?(output_path)
        Dir.mkdir(output_path)
    end
    File.open(File.join(output_path,"security-log.csv"), "a+") do |file|
        if File.exist?(Helpers.find_file("Security.csv", path))
            csv_file = CSV.read(Helpers.find_file("Security.csv", path), headers: true)
            file.write Helpers.clean_csv_header(csv_file.headers)
            csv_file.each do |row|
                if row[3] == "4624" || row[3] == "4634" 
                    if row[16].include?("3") || row[16].include?("8") || row[16].include?("7") || row[16].include?("10") 
                        file.write row
                    end
                elsif row[3] == "4625"|| row[3] == "4647" || row[3] == "4676" || row[3] == "4778" || row[3] == "4779"
                    file.write row
                end
            end	
        else 
            log += "Failed to find or open: #{image_identifier} #{drive_identifier} Security.csv\n"
        end
        file.close
    end

    File.open(File.join(output_path,"MSWin_TermServ_RemConMan_Op-log.csv"), "a+") do |file|
        if File.exist?(Helpers.find_file("Microsoft-Windows-TerminalServices-RemoteConnectionManager%4Operational.csv", path))
            csv_file = CSV.read(Helpers.find_file("Microsoft-Windows-TerminalServices-RemoteConnectionManager%4Operational.csv", path), headers: true)
            file.write Helpers.clean_csv_header(csv_file.headers)
            csv_file.each do |row|
                if row[3] == "1149"
                    file.write row
                end
            end
        else
            log += "Failed to find or open: #{image_identifier} #{drive_identifier} Microsoft-Windows-TerminalServices-RemoteConnectionManager%4Operational.csv\n"
        end
        file.close
    end

    File.open(File.join(output_path,"MSWin_TermServ_LocSesMan_Op-log.csv"), "a+") do |file|
        if File.exist?(Helpers.find_file("Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational.csv", path))
            csv_file = CSV.read(Helpers.find_file("Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational.csv", path), headers: true)

            file.write Helpers.clean_csv_header(csv_file.headers)
            csv_file.each do |row|
                if row[3].to_i > 20 && row[3].to_i < 26
                    file.write row
                elsif row[3] == "39" || row[3] =="40"
                    file.write row
                end
            end
        else
            log += "Failed to find or open: #{image_identifier} #{drive_identifier} Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational.csv\n"
        end
        file.close
    end

    File.open(File.join(output_path,"System-log.csv"), "a+") do |file|
        if File.exist?(Helpers.find_file("System.csv", path))
            csv_file = CSV.read(Helpers.find_file("System.csv", path), headers: true)
            
            file.write Helpers.clean_csv_header(csv_file.headers)
            csv_file.each do |row|
                if row[3] == "9009"
                    file.write row
                end
            end
        else
            log += "Failed to find or open: #{image_identifier} #{drive_identifier} System.csv\n"
        end
        file.close
    end

end

log += Helpers.put_return("\nFiltering complete.")

log_path = Helpers.get_script_log_path(paths_file)
Dir.chdir(log_path)
open('Filter_potential-remote-login.log', 'w') {|f| f.puts log}

sleep 5
exit