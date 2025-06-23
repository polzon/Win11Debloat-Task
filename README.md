Script to periodically run the fantastic Win11Debloat program on Windows 11.

Original Win11Debloat repo: https://github.com/Raphire/Win11Debloat/

When the script runs, it will check if the Win11Debloat program exists.
If not, it will clone the latest script and copy this repo's "SavedSettings"
as my personal preferred settings, then run those as default.

# Usage

- Open Task Scheduler on Windows.
- Import win11-debloater-task.xml as a task.
- Customize triggers as needed, the default is to run every 2 weeks.
