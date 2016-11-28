#!/usr/bin/env python3

#This is a simple script which walks the trees in the TCCD/data folder
#to find and list all the folders containing files that need to be 
#dealt with in various ways. These lists are saved into text files 
#which can be read and used by the build process.

#Author Martin Holmes. November 2016.

import os
import sys
import re
import shutil

print("=====================================================================")
print("Parsing the folder structure to discover the locations of key files.")
print("=====================================================================")
print()

def getScriptPath():
  return os.path.dirname(os.path.realpath(sys.argv[0]))

#root location is the folder containing this file.
dirRoot = getScriptPath()

#data directory is relative to working dir
dirData = os.path.abspath(dirRoot + '../../../data')

#regex for TEI file names
reTeiFile = re.compile("^((lg.+\d\d\d\d-\d\d-\d\d)|(personography)|(taxonomies)).xml$")

#regex for original HOCR folders
reOrigHocr = re.compile("hocr_orig$")

#regex for edited HOCR files
reEditedHocr = re.compile("hocr_edited$")

print("Data directory is at " + dirData)
print("Script directory is at " + dirRoot)

#Not actually just province folders; also schemas and personography folders.
provinceFolders = ["AB_SK", "BC", "Indigenous_Voices", "Man", "Nfld", "NS", "Ont_Que", "PEI", "personography", "schemas"]

#Function for creating an XSLT collection file from a list of files.

def writeCollection(fileList, fileName):
  f = open(dirRoot + '/' + fileName, 'w')
  f.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
  f.write("<collection>\n")
  for i in fileList:
    f.write("   <doc href=\"" + i + "\"/>\n")
  f.write("</collection>")
  
def writeList(fileList, fileName):
  f = open(dirRoot + '/' + fileName, 'w')
  for i in fileList:
    #f.write("**/" + os.path.basename(i).replace(".", "\.") + "\n")
    f.write(i + "\n")

print("=====================================================================")
print("Walking the data directory to list all the TEI files...")

teiFiles = []
for dirpath, subdirs, files in os.walk(dirData):
    for f in files:
        if re.match(reTeiFile, f):
            teiFiles.append(os.path.join(dirpath, f))
            
writeCollection(teiFiles, 'teiFiles.xml')
writeList(teiFiles, 'teiFiles.txt')

print("Done.")
print("=====================================================================")
print()

print("=====================================================================")
print("Listing all the original HOCR files...")

origHocrFiles = []
for fldr in provinceFolders:
  for dirpath, subdirs, files in os.walk(dirData + '/' + fldr):
      for f in files:
          if re.search(reOrigHocr, dirpath):
              origHocrFiles.append(os.path.join(dirpath, f))
 
writeCollection(origHocrFiles, 'origHocrFiles.xml')

print("Done.")
print("=====================================================================")
print()

print("=====================================================================")
print("Listing all the edited HOCR files...")

editedHocrFiles = []
for fldr in provinceFolders:
  for dirpath, subdirs, files in os.walk(dirData + '/' + fldr):
    for f in files:
      if re.search(reEditedHocr, dirpath):
        editedHocrFiles.append(os.path.join(dirpath, f))
      
            
writeCollection(editedHocrFiles, 'editedHocrFiles.xml')

print("Done.")
print("=====================================================================")
print()

