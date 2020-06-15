#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component:  Tool retriever
#Purpose:	This script downloads and unzips
#			the tools to be automated by the 
#           scripts in the scripts folder.
#Developer: Dave Posocco

require 'rubygems'
require 'down'
require 'fileutils'
require_relative './AKA_Ruby_Script_helper'
include Helpers
$stdout.sync=true

if (!File.directory?('./tools'))
    Dir.mkdir('tools')
end

Dir.chdir('./tools')

tempfile = Down.download("https://github.com/ArsenalRecon/Arsenal-Image-Mounter/archive/master.zip")
dir = tempfile.path
tempfile.close
FileUtils.mv(dir, "./arsenal-image-mounter.zip")
Dir.mkdir('aim_cli')
Helpers.unzip_file('./arsenal-image-mounter.zip', 'ArsenalImageMounterCLISetup.exe', './')
Helpers.unzip_file('./arsenal-image-mounter.zip', 'aim_cli.exe', './aim_cli/')
Helpers.unzip_file('./arsenal-image-mounter.zip', 'x64.zip', './aim_cli/')
Helpers.unzip_files('./aim_cli/x64.zip', './aim_cli/')

tempfile = Down.download("https://github.com/keydet89/RegRipper2.8/archive/master.zip")
dir = tempfile.path
tempfile.close
FileUtils.mv(tempfile.path, "./RegRipper2.8.zip")
Helpers.unzip('./RegRipper2.8.zip', './')

tempfile = Down.download("https://f001.backblazeb2.com/file/EricZimmermanTools/EvtxExplorer.zip")
dir = tempfile.path
filename = tempfile.original_filename
tempfile.close
FileUtils.mv(tempfile.path, "./#{tempfile.original_filename}")
Helpers.unzip('./EvtxExplorer.zip', './')

tempfile = Down.download("https://f001.backblazeb2.com/file/EricZimmermanTools/JLECmd.zip")
dir = tempfile.path
filename = tempfile.original_filename
tempfile.close
FileUtils.mv(tempfile.path, "./#{tempfile.original_filename}")
Helpers.unzip('./JLECmd.zip', './')

tempfile = Down.download("https://f001.backblazeb2.com/file/EricZimmermanTools/LECmd.zip")
dir = tempfile.path
filename = tempfile.original_filename
tempfile.close
FileUtils.mv(tempfile.path, "./#{tempfile.original_filename}")
Helpers.unzip('./LECmd.zip', './')

tempfile = Down.download("https://f001.backblazeb2.com/file/EricZimmermanTools/MFTECmd.zip")
dir = tempfile.path
filename = tempfile.original_filename
tempfile.close
FileUtils.mv(tempfile.path, "./#{tempfile.original_filename}")
Helpers.unzip('./MFTECmd.zip', './')

tempfile = Down.download("https://f001.backblazeb2.com/file/EricZimmermanTools/PECmd.zip")
dir = tempfile.path
filename = tempfile.original_filename
tempfile.close
FileUtils.mv(tempfile.path, "./#{tempfile.original_filename}")
Helpers.unzip('./PECmd.zip', './')

tempfile = Down.download("https://github.com/sleuthkit/sleuthkit/releases/download/sleuthkit-4.9.0/sleuthkit-4.9.0-win32.zip")
dir = tempfile.path
filename = tempfile.original_filename
tempfile.close
FileUtils.mv(tempfile.path, "./#{tempfile.original_filename}")
Helpers.unzip('./sleuthkit-4.9.0-win32.zip', './')