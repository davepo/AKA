# AKA

## Overview

AKA *(in it's current iteration)* uses a custom EnPack for OpenText Encase to automatically exports useful DFIR artifacts and then triggers a set of Ruby scripts to automate parsing and filtering those artifacts with additional tools.  AKA isn't trying to reinvent the wheel, it's just providing an axle for a bunch of free/opensource wheels built by much smarter wheel makers to rotate on.

## Aside

AKA was created for my freinds and myself.  I develop/maintain it in my spare time.  

I am fully aware AKA reproduces some tasks that Encase and other DFIR suites are already capable of, that there are projects in PowerShell and Python that do somthing similar.  That's cool.  Also, I'm just an ad-hoc programmer and understant that my code is not optimal and probably doesn't follow coding standards.

If this project is useful to you, great.  If not, don't use it.  Feel free to offer constructive critisism and request additions or filters *(custom csv filters are in the works, but not yet ready)* be added for any free/opensource tools.

## Requirements

At present, AKA requires a licensed Encase version 8.XX and Ruby.  *A standalone, Ruby based, version is in the works, but not yet ready.*

Ruby can be downloaded and installed from here:
https://rubyinstaller.org/

## Installation

1) Download and install Ruby...
2) Clone the repository to your Encase Enscripts folder.
3) Download the tools from the README.md file in the 'tools' folder, into the 'tools' folder.  It is fine if the executables are in subdirectories, but they cannot be in zipped archives.
4) In Encase: Create a case and add your evidence files.
5) In Encase: From the Enscript menu, select 'Run' then navigate to and select the 'AKA_Triage_Tool.EnPack'.  After the first run, it will appear in your Enscripts menu.
6) Make your selections and follow the prompts.
7) Monitor the 'Consoles' tab.  This will let you know the current status. Note: The external tools will run in a command prompt that will appear during processing.  Do not close this window until everything is complete.
8) When everything is complete, a dialog will appear to let you know.  At this point, you can safely close the opened command prompt.
