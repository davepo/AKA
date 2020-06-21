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
echo Please accept the UAC notification if/when prompted.
echo.
timeout /t 5
echo Installing Arsenal driver...
echo.
ArsenalImageMounterCLISetup.exe /install
echo.
echo Setup complete.
pause