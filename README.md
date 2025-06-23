Script to periodically run the fantastic Win11Debloat program on Windows 11.

Original Win11Debloat repo: https://github.com/Raphire/Win11Debloat/

When the script runs, it will check if the Win11Debloat program exists.
If not, it will clone the latest script and copy this repo's "SavedSettings"
as my personal preferred settings, then run those as default.

# Usage

- Run 'run-service.ps1' inside of powershell.
- It will prompt you to run as admin, this is neccesary to install itself as a task and also for the Win11Debloat script.
