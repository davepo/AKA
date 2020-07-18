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

url_list = [
    "https://rubygems.org/downloads/rubyzip-2.3.0.gem",
    "https://rubygems.org/downloads/down-5.1.1.gem",
    "https://github.com/ArsenalRecon/Arsenal-Image-Mounter/archive/master.zip",
    "https://github.com/keydet89/RegRipper2.8/archive/master.zip",
    "https://f001.backblazeb2.com/file/EricZimmermanTools/EvtxExplorer.zip",
    "https://f001.backblazeb2.com/file/EricZimmermanTools/JLECmd.zip",
    "https://f001.backblazeb2.com/file/EricZimmermanTools/LECmd.zip",
    "https://f001.backblazeb2.com/file/EricZimmermanTools/PECmd.zip",
    "https://github.com/jschicht/Mft2Csv/archive/master.zip",
    "https://github.com/jschicht/RawCopy/archive/master.zip",
    "https://github.com/jschicht/ExtractUsnJrnl/archive/master.zip",
    "https://github.com/jschicht/UsnJrnl2Csv/archive/master.zip",
    "https://download.sysinternals.com/files/Autoruns.zip",
    "https://arsenalrecon.com/download/28756/",
    "https://www.clamav.net/downloads/production/clamav-0.102.4-win-x64-portable.zip"
]

url_list.each do |url|
    tempfile = Down.download(url)
    dir = tempfile.path
    tempfile.close

    case url
    when /rubyzip-/
        FileUtils.mv(tempfile.path, "./rubyzip.gem")
    when /down-/
        FileUtils.mv(tempfile.path, "./down.gem")
    when /Arsenal-Image-Mounter\/archive\/master.zip/
        FileUtils.mv(dir, "./arsenal-image-mounter.zip")
        Dir.mkdir('aim_ll')
        #Helpers.unzip_file('./arsenal-image-mounter.zip', 'ArsenalImageMounterCLISetup.exe', './')
        Helpers.unzip_file('./arsenal-image-mounter.zip', 'x64.zip', './aim_ll/')
        Helpers.unzip_file('./arsenal-image-mounter.zip', 'aim_ll.zip', './aim_ll/')
        Helpers.unzip_files('./aim_ll/x64.zip', './aim_ll/')
        Helpers.unzip_file('./aim_ll/aim_ll.zip', 'x64/aim_ll.exe','./aim_ll/')
        Helpers.unzip_file('./aim_ll/aim_ll.zip', 'x64/aimapi.dll','./aim_ll/')
        Helpers.unzip_file('./aim_ll/aim_ll.zip', 'x64/imdisk.cpl','./aim_ll/')
    when /RegRipper/
        FileUtils.mv(tempfile.path, "./RegRipper2.8.zip")
        Helpers.unzip('./RegRipper2.8.zip', './')
    when /Mft2Csv/
        FileUtils.mv(tempfile.path, "./mft2csv.zip")
        Helpers.unzip('./mft2csv.zip', './')
    when /RawCopy/
        FileUtils.mv(tempfile.path, "./RawCopy.zip")
        Helpers.unzip('./RawCopy.zip', './')
    when /ExtractUsnJrnl/
        FileUtils.mv(tempfile.path, "./ExtractUsnJrnl.zip")
        Helpers.unzip('./ExtractUsnJrnl.zip', './')
    when /UsnJrnl2Csv/
        FileUtils.mv(tempfile.path, "./UsnJrnl2Csv.zip")
        Helpers.unzip('./UsnJrnl2Csv.zip', './')
    else
        FileUtils.mv(tempfile.path, "./#{tempfile.original_filename}")
        Helpers.unzip("./#{tempfile.original_filename}", './')
    end
end