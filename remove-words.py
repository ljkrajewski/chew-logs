#!/usr/bin/python3.4

import sys

LogFile = sys.argv[1]
WD = sys.argv[2]

### Constants ###

DICTIONARY_FILE = WD + "/words-no_names-sorted.txt"
OutFile = LogFile + "-filtered.txt"
#print ("Working Directory = ",WD)
#input()

####################
### Main Routine ###
####################

DictFileObj = open(DICTIONARY_FILE, "r")
LogFileObj = open(LogFile, "r")
OutFileObj = open(OutFile, "w")

DictWord = DictFileObj.readline().strip()
LogWord = LogFileObj.readline().strip()
while (DictWord != "") and (LogWord != ""):
	if LogWord == DictWord:
		DictWord = DictFileObj.readline().strip()
		LogWord = LogFileObj.readline().strip()
	elif LogWord <= DictWord:
		OutFileObj.write(LogWord+'\r\n')
		LogWord = LogFileObj.readline().strip()
	elif LogWord >= DictWord:
		DictWord = DictFileObj.readline().strip()
while LogWord != "":
	OutFileObj.write(LogWord+'\r\n')
	LogWord = LogFileObj.readline().strip()
DictFileObj.close()
LogFileObj.close()
OutFileObj.close()
