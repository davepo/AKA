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
      temp_path = path.downcase
      temp_exe = exe.downcase
      if temp_path.include?(temp_exe)
        exe_path = path
      end
    end
    return exe_path
  end
  
  def Helpers.find_all_paths_with_term (string, paths_file)
    found = []
    temp_string = string.downcase
    all_paths = File.open(paths_file)
    all_paths.each do |line| 
      line.gsub!("\\","/")
      temp_line = line.downcase
      if temp_line.include?(temp_string)
        found << line.chop
      end
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
    return Helpers.get_aka_export_path(paths_file) + "aka_script_logs/"
  end
    
end