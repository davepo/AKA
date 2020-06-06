# AKA

## Overview

AKA *(in it's current iteration)* uses a custom EnPack for OpenText Encase to automatically exports useful DFIR artifacts and then triggers a set of Ruby scripts to automate parsing and filtering those artifacts with additional tools.  It also mounts the associated evidence files as read-only and AV scans them with Windows Defender.  

AKA isn't trying to reinvent the wheel, it's just providing an axle for a bunch of free/opensource wheels built by much smarter wheel makers to rotate on.

## Aside

AKA was created for my freinds and myself.  I develop/maintain it in my spare time.  

I am fully aware AKA reproduces some tasks that Encase and other DFIR suites are already capable of, that there are projects in PowerShell and Python that do somthing similar.  That's cool.  Also, I'm just an ad-hoc programmer and understant that my code is not optimal and probably doesn't follow coding standards.

If this project is useful to you, great.  If not, don't use it.  Feel free to offer constructive critisism and request additions or filters *(custom csv filters are in the works, but not yet ready)* be added for any free/opensource tools.

## Requirements

At present, AKA requires a licensed Encase version 8.XX and Ruby.  *A standalone, Ruby based, version is in the works, but not yet ready.*

Ruby can be downloaded and installed from here:
https://rubyinstaller.org/

I've only tested this on up-to-date Windows 10 x64 systems.

## Installation and Use Instructions

### 1) Main Files Setup
a) Download and install Ruby.

b) Clone the repository to your Encase Enscripts folder. 
*It should work from any location, but this is the most convinient. It has not been tested in other locations.*

### 2) Tools Setup

#### Option 1 (Automatic) 
a) Run the 'setup.bat' file **as Administrator**.

#### Option 2 (Manual)
a) Download and extract each the tools from the README.md file in the 'tools' folder, into the 'tools' folder.  It is fine if the executables are in subdirectories, but they cannot be in zipped archives.
b) Install the Ruby Gem's 'rubyzip' and 'down' from rubygems.org.
c) Install the Arsenal Image Mounter driver with the ArsenalImageMounterCLISetup.exe file from their main repository.
d) Extract the libewf x64 dlls from the Arsenal Image Mounter main repository into the same location as the aim_cli.exe file.

### 3) Use
a) In Encase: Create a case and add your evidence files.
b) In Encase: From the Enscript menu, select 'Run' then navigate to and select the 'AKA_Triage_Tool.EnPack'.  
*After the first run, it will appear in your Enscripts menu.*
c) Make your selections and follow the prompts.
d) Monitor the 'Consoles' tab.  This will let you know the current status.
*The external tools will run in a command prompt that will appear during processing.  
*Each mounted image will spawn as a process in their own command prompt.
*Do not close this window until everything is complete.*
e) When the external process complete, an image will pop-up letting you know. At this point you can confirm the main command prompt has completed.  
*If so, you can close the window, end the mounted image processes, and then close those windows
*At this point your free to explor the 'AKA_Exports' results folder, which will be located in the Encase case file's exports folder.*
f) When the remaining Encase options complete, a dialog will appear to let you know.
