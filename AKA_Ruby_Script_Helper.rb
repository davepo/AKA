#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component:  Helper file
#Purpose:	This script contains a module of
#			functions for use in scripting out 
#     additional external tools.
#Developer: Dave Posocco

require 'find'

module Helpers

  def Helpers.put_return (string)
    puts string
    return string + "\n"
  end
  
  def Helpers.find_exe_path (exe, tool_dir)
    exe_path = ""
    Find.find(tool_dir) do |path|
      if path.include? exe.downcase
        exe_path = path
      end
    end
  return exe_path
  end
  
  def Helpers.find_all_paths_with_term (search, paths_file)
    found = []
    all_paths = File.open(paths_file)
    all_paths.each do |line| 
    temp = line.downcase
    temp.gsub("\\","/")
      if temp.include? search.downcase
        found << line.chop
      end
    return found
  end
    
  def Helpers.get_aka_export_path (paths_file)
    aka_index = paths_file.index("AKA_Export")
    aka_offset = aka_index+10
    aka_negative_offset = aka_offset-paths_file.length
    aka_export_path = paths_file[0..aka_negative_offset]
    return aka_export_path
  end
  
  def Helpers.get_script_log_path (paths_file)
    return Helpers.get_aka_export_path+"aka_script_logs/"
  end
    
end