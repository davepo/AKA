# AKA

## Overview

AKA uses a custom EnPack (AKA_Triage_Tool.EnPack) for OpenText Encase or a standalone Ruby script (aka.rb) to automatically exports useful DFIR artifacts from evidence images and then triggers a set of Ruby scripts to automate parsing and filtering those artifacts with additional tools.  It also mounts the associated evidence files as read-only and AV scans them with Windows Defender.  

AKA isn't trying to reinvent the wheel, it's just providing an axle for a bunch of free/opensource wheels built by much smarter wheel makers to rotate on.

## Aside

AKA was created for my freinds and myself.  I develop/maintain it in my spare time.  

I am fully aware AKA reproduces some tasks that Encase and other DFIR suites are already capable of, that there are projects in PowerShell and Python that do somthing similar.  That's cool.  Also, I'm just an ad-hoc programmer and understant that my code is not optimal and probably doesn't follow coding standards.

If this project is useful to you, great.  If not, don't use it.  Feel free to offer constructive critisism and request additions or filters *(custom csv filters are in the works, but not yet ready)* be added for any free/opensource tools.

## Requirements

1) A Windows system. (I've only tested this on up-to-date Windows 10 x64 systems.)

2) Ruby, which can be downloaded and installed from here: https://rubyinstaller.org/

##### Note: To use the custom Enpack
AKA_Triage_Tool.EnPack requires a licensed Encase version 8.XX and Ruby.  

## Installation and Use Instructions

### 1) Main Files Setup
a) Download and install Ruby.

b) Clone this repository to your system.

### 2) Tools Setup

#### Option 1 (Automatic) 
1) Run the 'setup.bat' file **as Administrator**.

#### Option 2 (Manual)
1) Download and extract each the tools from the README.md file in the 'tools' folder, into the 'tools' folder.  It is fine if the executables are in subdirectories, but they cannot be in zipped archives.
2) Download and install the Ruby Gem's 'rubyzip' and 'down' from rubygems.org.
3) Install the Arsenal Image Mounter driver with the 'ArsenalImageMounterCLISetup.exe' file from their main repository.
4) Extract the libewf x64 dlls from the Arsenal Image Mounter main repository into the same location as the aim_cli.exe file.

### 3) Use

#### Option 1 (The Encase EnPack)
1) In Encase: Create a case and add your evidence files.
2) In Encase: From the Enscript menu, select 'Run' then navigate to and select the 'AKA_Triage_Tool.EnPack'.  
   *After the first run, it will appear in your Enscripts menu.*
3) Make your selections and follow the prompts.
4) Monitor the 'Consoles' tab and the active command prompt windows.  This will let you know the current status.
   * The external tools will run in a command prompt that will appear during processing.  
   * Each mounted image will spawn as a process in their own command prompt.
   * Do not close the windows until everything is complete.
5) When the external process complete, an image will pop-up letting you know. At this point you can confirm the main command prompt has completed.  
   * If so, you can close the window, end the mounted image processes, and then close those windows
   * At this point your free to explor the 'AKA_Exports' results folder, which will be located in the Encase case file's exports folder.
6) When the remaining Encase options complete, a dialog will appear to let you know.

#### Option 2 (Standalone)
1) Open an administrator command prompt or powershell terminal. **This must be an Administrator Terminal**
2) Run 'aka.rb', for example: _' ruby aka.rb win10 "C:\evidence\image.e01" "C:\case\output\" '_
   * Access help with _' ruby aka.rb -h '_
3) When all of the operations are complete, an image will appear to let you know.

'aka.rb' help contents:

_AKA Standalone Launcher Help_

_Usage:_
_aka.rb {System} {Evidence} {Output}_

_'System' is the evidence operating system_
    _-Currently supported: {win10}_
_'Evidence' should be the full path to an E01 or Raw image file._
_'Output' is the directory you would like the 'AKA_Export' folder created in._

_Example:_
   _aka.rb win10 "Drive:\Path\To\Evidence.e01" "Drive:\Path\To\Store\Output\"_
