#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component:  Helper file
#Purpose:	This script contains a module of
#			    functions for use in scripting out 
#         additional external tools.
#Developer: Dave Posocco

require 'find'
require 'fileutils'
require 'win32ole'
require 'rubygems'
require 'zip'

module Helpers

  def Helpers.put_return (string)
    puts string
    return string + "\n"
  end

  def Helpers.export_file (item, output_path)
    begin
      FileUtils.copy_stream(item, File.join(output_path,File.basename(item))) unless File.directory?(item)
    rescue Exception => e
      puts "\nRescued - export_file - "+ File.basename(item)
      puts "\tException:   " + e.message + "\n"
    end
  end
  
  def Helpers.export_file_as (item, new_name, output_path)
    begin
      FileUtils.copy_stream(item, File.join(output_path,new_name)) unless File.directory?(item)
    rescue Exception => e
      puts "\nRescued - export_file_as - "+ new_name
      puts "\tException:   " + e.message + "\n"
    end
  end

  def Helpers.export_folder (item, output_path)
    begin
      FileUtils.copy_entry(item, File.join(output_path,File.basename(item))) unless !File.directory?(item)
    rescue Exception => e
      puts "\nRescued - export_folder - "+ File.basename(item)
      puts "\tException:   " + e.message + "\n"
    end
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

  def Helpers.find_file (file, base_path)
    return Helpers.find_exe_path(file, base_path)
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

  def Helpers.get_image_paths (paths_file)
    images = []
    all_paths = File.open(paths_file)
    all_paths.each do |line| 
      line.gsub!("\\","/")
      temp_line = line.downcase
      images << line.chop
    end
    return images
  end
    
  def Helpers.get_aka_export_path (paths_file)
    aka_index = paths_file.index("AKA_Export")
    aka_offset = aka_index+10
    aka_negative_offset = aka_offset-paths_file.length
    aka_export_path = paths_file[0..aka_negative_offset]
    return aka_export_path
  end
  
  def Helpers.get_script_log_path (paths_file)
    return Helpers.get_aka_export_path(paths_file) + "01-Script_logs/"
  end

  def Helpers.get_av_scan_output_path (paths_file)
    return Helpers.get_aka_export_path(paths_file) + "02-AV_scans_results/"
  end

  def Helpers.get_filter_output_path (paths_file)
    return Helpers.get_aka_export_path(paths_file) + "03-Filter_results/"
  end

  def Helpers.get_autoruns_output_path (paths_file)
    return Helpers.get_aka_export_path(paths_file) + "04-Autoruns_results/"
  end
    
  def Helpers.unzip (zipfile, destination)
    new_dest = destination+File.basename(zipfile)[0..(File.basename(zipfile).length-5)] 
    Dir.mkdir(new_dest)
    new_dest = new_dest+"/"
    Zip::File.open(zipfile) do |zip_file|
      zip_file.each do |entry|
        puts "Extracting #{entry.name}"
        entry_path = File.join(new_dest, entry.name)
        entry.extract(entry_path)
      end
    end
  end
  
  def Helpers.unzip_files (zipfile, destination)
    Zip::File.open(zipfile) do |zip_file|
      zip_file.each do |entry|
        puts "Extracting #{entry.name}"
        entry.extract(File.join(destination, File.basename(entry.name)))
      end
    end
  end
    
  def Helpers.unzip_file (zipfile, filename, destination)
    Zip::File.open(zipfile) do |zip_file|
      zip_file.each do |entry|
        if entry.name.include?(filename) || entry.name.include?(filename.gsub("/","\\"))
          puts "Extracting #{entry.name}"
          entry.extract(File.join(destination, File.basename(filename)))
        end
      end
    end
  end

  def Helpers.get_drives ()
    filesys = WIN32OLE.new("Scripting.FileSystemObject")
    drives = filesys.Drives
    list = []
    drives.each do |drive|
      list << drive.DriveLetter
    end
    return list
  end

  def Helpers.delete_empty_dirs (path)
    Find.find(path) do |item|
      if File.directory?(item)
        if Dir.empty?(item)
          Dir.delete(item)
        end
      end
    end
  end

  def Helpers.delete_diff_files(evidence_path_file)
    file = File.open(evidence_path_file)
    paths = file.readlines.map(&:chomp)
    file.close
    paths.each do |path|
      if File.exist?(path+".diff")
        File.delete(path+".diff")
      end
    end
  end

  def Helpers.make_dir(path)
    unless File.exist?(path)
      Dir.mkdir(path) 
    end
  end

  def Helpers.clean_csv_header(head)
    fixed = ""
	  head.each do |line|
	  	fixed += line.gsub(/[^a-zA-Z0-9\s]/i, '') + ", "
	  end
	  return fixed
  end

end