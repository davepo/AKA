# AKA

## Overview

This is a project that uses a custom EnPack for OpenText Encase that automatically exports useful DFIR artifacts and then uses a set of Ruby scripts to automate parsing and filtering those artifacts with additional tools.

It currently requires a licensed Encase version 8.XX and Ruby.

Ruby can be downloaded and installed from here:
https://rubyinstaller.org/

This project was created and is maintained for myself and my friends.  I am fully aware that it reproduces some tasks that Encase is already capable of.  Also, I am just an ad-hoc programmer, so I am aware that my code is not optimal and probably doesn't follow coding standards.

If this project is useful to you, great.  If not, don't use it.  Feel free to offer constructive critisism and request scripts or filters be added for any additional tools.

## Installation

1) Install Ruby
2) Clone the repository to your Encase Enscripts folder.
3) Download the tools from the README.md file in the 'tools' folder, into the 'tools' folder.  It is fine if the executables are in subdirectories, but they cannot be in zipped archives.
4) In Encase: Create a case and add your evidence files.
5) In Encase: From the Enscript menu, select 'Run' then navigate to and select the 'AKA_Triage_Tool.EnPack'.  After the first run, it will appear in your Enscripts menu.
6) Make your selections and follow the prompts.
7) Monitor the 'Consoles' tab.  This will let you know the current status. Note: The external tools will run in a command prompt that will appear during processing.  Do not close this window until everything is complete.
8) When everything is complete, a dialog will appear to let you know.  At this point, you can safely close the opened command prompt.
