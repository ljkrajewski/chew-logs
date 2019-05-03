#!/usr/bin/python3.4

import sys
import re
import os
import pathlib

### Comamnd line args ###

Log = sys.argv[1]

### Constants ###

Alphanum = "[0-9a-zA-Z][0-9a-zA-Z\-\']+[0-9a-zA-Z]"
MacAddress = "[[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}|[0-9a-fA-F]{12}]"
Ip4 = "\d{1,3}[\.|:]\d{1,3}[\.|:]\d{1,3}[\.|:]\d{1,3}"  #Some Avaya formats use colons for delimiters
Word_RegexString = "("+Alphanum+"|"+Ip4+"|"+MacAddress+")+"
WORD_REGEX = re.compile(Word_RegexString)
DRIVE_REGEX = re.compile("([a-zA-Z]:[\\\/])+")

### Globals ###

### Functions ###

def remove_timestamps(Line):
	Newline = re.sub(r"\d{8}-\d{1,2}\:\d{2}\:\d{2}\.\d{6}","_", Line)
	Newline = re.sub(r"\d{1,2}\:\d{2}\:\d{2} (AM|PM)","_", Newline)
	Newline = re.sub(r"\d{2}\:\d{2}\:\d{2}(\.|\,)\d{3}","_", Newline)
	Newline = re.sub(r"\d{1,2}\:\d{2}\:\d{2}","_", Newline)
	Newline = re.sub(r"\d{1,2}\/\d{1,2}\/\d{4}","_", Newline)
	Newline = re.sub(r"\d{2,4}\/\d{2,4}\/\d{2,4}","_", Newline)
	Newline = re.sub(r"\d{2,4}-\d{2,4}-\d{2,4}","_", Newline)
	return Newline

def read_logline(Line):
	global WORD_REGEX
	global DRIVE_REGEX
	global LogResult
	CleanLine = remove_timestamps(Line).lower()
	#print(CleanLine)
	Result = []
	for Item in WORD_REGEX.findall(CleanLine):
		Result = Result + [Item]
		#print(Item[0])
	for Item in DRIVE_REGEX.findall(CleanLine):
		Result = Result + [Item]
	#print(Result)
	
	return Result

####################
### Main Routine ###
####################

WordList = []
CharsSoFar = 0
LogSize = os.path.getsize(Log)
OutFile = Log+".index"
CurrPercent = 0
DotCount = 13

if pathlib.Path(OutFile).exists():
	print(OutFile," exists. Skipping...")
else:
	LogFileObj = open(Log,"r")
	for Line in LogFileObj:
		#print(Line)
		CharsSoFar = CharsSoFar + len(Line)
		PercentComplete = CharsSoFar / LogSize
		if PercentComplete >= CurrPercent:
			print("{:4.2%}".format(PercentComplete)," complete.",end="\r")
			CurrPercent = PercentComplete + 0.001
		LineList = read_logline(Line)
		#print(LineList)
		for Word in LineList:
			if (re.match("^\d+($|s$|ms$)",Word) == None):
				if not Word in WordList:
					WordList = WordList + [Word]
	print("Finished reading log.")
	WordList.sort()
	print("Writing ",OutFile)
	OutFileObj = open(OutFile,"w")
	for Word in WordList:
		OutFileObj.write(Word+'\r\n')
	OutFileObj.close()
	
print("Done.")
