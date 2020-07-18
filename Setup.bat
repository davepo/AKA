@setlocal enableextensions
@cd /d "%~dp0"
@echo off
title AKA Setup
echo Current directory: %cd%
echo Installing 'rubyzip' and 'down' gems...
echo.
call gem install 'rubyzip'
echo.
call gem install 'down'
echo.
timeout /t 3
echo Downloading tools...
echo.
ruby retrieve-tools.rb
echo.
timeout /t 3
echo.
echo About to install Arsenal Image Mounter driver.
echo.
echo This will open the GUI application.  
echo 1) When prompted, select the option to INSTALL or UPGRADE the driver.
echo 2) When the driver finishes install, close out of the GUI and this script will continue.
echo.
echo Press any button to continue with Arsenal driver install.
echo.
echo.
pause
cd tools
for /R %%f in (ArsenalImageMounter.exe) do @IF EXIST %%f start /B /wait %%f
echo.
echo Arsenal step complete.
echo.
echo About to setup ClamAV
echo.
cd ..
ruby clamav-setup.rb
echo.
echo About to download CLamAV definitions.
cd tools
for /R %%f in (freshclam.exe) do @IF EXIST %%f start /B /wait %%f
echo.
echo Removing downloaded archive files...
del /q *.zip
echo.
echo.
echo This setup does not contain a verification.
echo.
echo If desired, please manually verifiy the items listed in tools\README.md downloaded to the 'tools' folder.
echo.
echo.
echo.
echo PLEASE REVIEW THE LICENSES FOR ALL EXTERNAL TOOLS TO ENSURE YOUR USE CASE IS NOT IN VIOLATION.
echo.
echo.
echo.
pause