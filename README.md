# chew-logs
DOS/PowerShell/Python scripts for creating digests of large file collections (like logs or source code)

Using log redaction scripts
---------------------------

Requires Cygwin with Python3.

Uses four files in the same directory:
- chew-dir_py.bat
- chew-log.py
- remove-words.py
- find-names.ps1
- words-no_names-sorted.txt

To make updates/edits to the script, you'll also need:
- chew-dir_py.ps1 (the PowerShell script used to make chew-dir_py.bat)
- Convert-to-batch_min.ps1 (the script that makes the batch file)

To use:
1) Edit 'chew-dir_py.bat'. Replace "C:\PATH_TO\FILES" with the path
you extracted the files to. (NO UNC PATHS!)
2) (Optional) Create a shortcut to 'chew-dir_py.bat' on your desktop. Set the "Start in:" field
to the scripts directory (Again, no UNC paths!)
3) Drag-and-drop the file/directory of files onto that shortcut and wait for script to
finish.

- or if your logs are stored in nested directories -

3a) Open a command prompt. CD to the scripts directory.
3b) Type
	chew-dir_py.bat "V:\logs\dir_you_put_them" -recurse

When done, you will have either 'summary.txt.idx-filtered.txt' (if parsing a directory)
or '<log filename>.idx-filtered.txt' (if parsing an individual file). Review this file
for sensitive content.
