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
timeout /t 2
echo.
cd tools
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
timeout /t 2
echo.
echo This setup does not contain a verification.
echo.
echo If desired, please manually verifiy the items listed in tools\README.md downloaded to the 'tools' folder.
echo.
pause
