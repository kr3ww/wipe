@echo off

set handle_path=".\utils\handle.exe"

%handle_path% -p 111 > .handle_output.txt

powershell.exe -ExecutionPolicy Bypass -File ".\wipe.ps1"
