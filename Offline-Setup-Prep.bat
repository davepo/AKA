@setlocal enableextensions
@cd /d "%~dp0"
@echo off
title AKA Setup
echo Current directory: %cd%
echo Downloading tools...
echo.
ruby retrieve-tools.rb
echo.
timeout /t 2
echo.
cd tools
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