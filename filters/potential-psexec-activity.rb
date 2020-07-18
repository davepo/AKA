#Project: AKA Triage Suite
#Sub-Project: Filters
#Component: Remote login filter
#Purpose:	This script automates parsing csv files to
#			consolidate psexec related activity
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


log += Helpers.put_return("\nFiltering PSExec related event log data...\n")

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
                if row[3] == "4688" || row[3] == "4689" || row[3] == "4656" || row[3] == "4663" || row[3] == "4656" || row[3] == "4658" || row[3] == "4660" 
                    if row[23].downcase.include?("psexec") 
                        file.write row
                    end
                elsif row[3] == "5140"|| row[3] == "5145" 
                    if row[23].downcase.include?("psexec") || row[23].downcase.include?("\\??\\C:\\Windows") || row[23].downcase.include?("\\\\*\\IPC$")
                        file.write row
                    end
                elsif row[3] == "5156"
                    if row[23].downcase.include?(":135") || row[23].downcase.include?(":445") 
                        file.write row
                    end
                end
            end	
        else 
            log += "Failed to find or open: #{image_identifier} #{drive_identifier} Security.csv\n"
        end
        file.close
    end

    File.open(File.join(output_path,"System-log.csv"), "a+") do |file|
        if File.exist?(Helpers.find_file("System.csv", path))
            csv_file = CSV.read(Helpers.find_file("System.csv", path), headers: true)
            
            file.write Helpers.clean_csv_header(csv_file.headers)
            csv_file.each do |row|
                if row[3] == "7045"
                    if row[23].downcase.include?("psexec") 
                        file.write row
                    end
                elsif row[3] == "7036"
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
open('Filter_potential-psexec-activity.log', 'w') {|f| f.puts log}

sleep 5
exit