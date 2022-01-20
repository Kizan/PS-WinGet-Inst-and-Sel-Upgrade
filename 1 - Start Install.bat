::Set Powershell environment and then install Apps

%~dp0elevate powershell.exe -ExecutionPolicy Bypass -Command "Set-Executionpolicy -Executionpolicy Bypass -Scope LocalMachine -Force"

Powershell.exe -Executionpolicy Bypass -File "%~dp0WinGet Apps.ps1"

pause
