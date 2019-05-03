# Requires Cygwin with Python3.4

#In the batch file,
# - Add after "@echo off": 
#     set WD="V:\CIAU\ITSP\Tools\log redaction"
# - Replace "echo %* > %TEMP%\params.txt" with: 
#     echo %WD% %* > %TEMP%\params.txt

param (

  [Parameter(Mandatory=$true)]
  [string] $WorkingDir,

  [Parameter(Mandatory=$true)]
  [string] $LogDir,

  [Parameter(Mandatory=$false)]
  [switch] $recurse  

)

function convert-dir {
  param ( $Log )

  $newlog = $Log.ToLower()
  $newlog = $newlog -replace "\\","/" 
  $newlog = $newlog -replace ":/","/"
  """/cygdrive/$newlog"""
}

function chew-log {
  param ( $Log )

  #Run the Python script
  $logDir = convert-dir($Log)
  $dosDir =$([regex]"^(.*)\\.*$").matches($log).groups[1].value
  write-host "Running chew-log on $Log..."
  $args = "$CygwinWorkingDir/chew-log.py $logDir"
  Start-Process -FilePath "C:\Cygwin\bin\mintty.exe" -ArgumentList $args -Wait
  if (!(test-path "$Log.index")) {
      $MyFile = Get-Content $Log
      [System.IO.File]::WriteAllLines("$dosDir\temp.txt", $MyFile)
      $tempargs = "$CygwinWorkingDir/chew-log.py $(convert-dir("$dosDir\temp.txt"))"
      Start-Process -FilePath "C:\Cygwin\bin\mintty.exe" -ArgumentList $tempargs -Wait
      rename-item -Force "$dosDir\temp.txt.index" "$Log.index"
	  remove-item -Force "$dosDir\temp.txt"
  }
}

### Main routine ###
write-host "Working Dir = $WorkingDir"
$CygwinWorkingDir = convert-dir $WorkingDir
$IsDirectory = (get-item $LogDir) -is [System.IO.DirectoryInfo]
if (!$IsDirectory) {
    chew-log "$LogDir"
    $args = "$CygwinWorkingDir/remove-words.py $(convert-dir "$LogDir.index") $CygwinWorkingDir"
    Start-Process -FilePath "C:\Cygwin\bin\mintty.exe" -ArgumentList $args -Wait
} elseif ($IsDirectory) {
    if ($recurse) {
	  gci -recurse "$LogDir" -Exclude "filelist.index" | select Fullname, Length, LastWriteTime | out-file "$LogDir\filelist.index" -encoding ascii
      gci -recurse "$LogDir" -Exclude "*.index" | sort -Property Length |% { chew-log $_.FullName }
      gci -recurse "$LogDir\*.index" -Exclude "filelist.index" |% { get-content $_.FullName -Raw | Out-File -Append -Encoding ascii "$LogDir\summary.txt" }
    } else {
	  gci "$LogDir" -Exclude "filelist.index" | select Name, Length, LastWriteTime | out-file "$LogDir\filelist.index" -encoding ascii
      gci "$LogDir" -Exclude "*.index" | sort -Property Length |% { chew-log $_.FullName }
      gci "$LogDir\*.index" -Exclude "filelist.index" |% { get-content $_.FullName -Raw | Out-File -Append -Encoding ascii "$LogDir\summary.txt" }
    }
    chew-log "$LogDir\summary.txt"
    $args = "$CygwinWorkingDir/remove-words.py $(convert-dir "$LogDir\summary.txt.index") $CygwinWorkingDir"
    Start-Process -FilePath "C:\Cygwin\bin\mintty.exe" -ArgumentList $args -Wait
} else {
    write-host "Argument outside universe of discourse (not a file or directory)."
}
write-host "Done"
