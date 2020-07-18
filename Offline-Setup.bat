@setlocal enableextensions
@cd /d "%~dp0"
@echo off
title AKA Setup
echo Current directory: %cd%
echo Changing to 'tools' directory...
cd tools
echo Current directory: %cd%
echo Installing 'rubyzip' and 'down' gems...
echo.
call gem install --force --local *.gem
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
for /R %%f in (ArsenalImageMounter.exe) do @IF EXIST %%f start /B /wait %%f
echo.
echo Arsenal step complete.
echo.
echo Setup complete.
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