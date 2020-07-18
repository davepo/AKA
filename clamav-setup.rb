#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component:  ClamAV setup
#Purpose:	This script sets up the 
#            portable ClamAV scanner
#            and downloads the current definitions.
#Developer: Dave Posocco

require 'rubygems'
require 'down'
require 'fileutils'
require_relative './AKA_Ruby_Script_helper'
include Helpers
$stdout.sync=true

proc_dir = __dir__
tools_dir = File.join(proc_dir, "/tools")
Dir.chdir(tools_dir)

clam_exe = "clamscan.exe"
clam_full_path = Helpers.find_exe_path(clam_exe, tools_dir)
clam_dir = clam_full_path.gsub(clam_exe,"")
clam_dir.chop!

conf_dir = File.join(clam_dir, "/conf_examples")

freshclam_conf_sample = File.join(conf_dir, "/freshclam.conf.sample")
clamd_conf_sample = File.join(conf_dir, "/clamd.conf.sample")

Helpers.export_file_as(freshclam_conf_sample, "freshclam.conf", clam_dir)
Helpers.export_file_as(clamd_conf_sample, "clamd.conf", clam_dir)

freshclam_conf = File.join(clam_dir, "/freshclam.conf")
clamd_conf = File.join(clam_dir, "/clamd.conf")

text = File.read(freshclam_conf)
replace = text.gsub("Example", "# Example")
File.write(freshclam_conf, replace)

text = File.read(clamd_conf)
replace = text.gsub("Example", "# Example")
File.write(clamd_conf, replace)