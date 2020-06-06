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
echo Please accept the UAC notification if/when prompted.
echo.
timeout /t 5
echo Installing Arsenal driver...
echo.
cd tools
ArsenalImageMounterCLISetup.exe /install
echo.
echo Setup complete.
echo.
echo This setup does not contain a verification.
echo.
echo If desired, please manually verifiy the items listed in tools\README.md downloaded to the 'tools' folder.
echo.
pause