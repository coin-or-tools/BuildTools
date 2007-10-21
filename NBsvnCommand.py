#! /usr/bin/env python

import os
import urllib2
import re

import NBlogMessages
import NBemail
import NBosCommand

#------------------------------------------------------------------------
# Function for executing svn commands
#  svnCmd: String representing svn command
#  dir: Directory where command is to be run from
#  project: Coin project running the command (this is used to provide
#           a better message if an error is detected
#------------------------------------------------------------------------
def run(svnCmd,dir,project) :
  retVal='OK'
  os.chdir(dir)
  NBlogMessages.writeMessage('  '+svnCmd)
  result = NBosCommand.run(svnCmd)
  if result['returnCode'] != 0 :
    NBemail.sendCmdMsgs(project,result,svnCmd)
    retVal='Error'
  return retVal


#------------------------------------------------------------------------
# Function which returns the latest stable version of a project
#------------------------------------------------------------------------
def latestStableVersion(project) :
  url='https://projects.coin-or.org/svn/'+project+'/stable'
  handle=urllib2.urlopen(url)
  html=handle.read()
  handle.close()

  # In html code find the latest version number
  #   <li><a href="3.2/">3.2/</a></li>
  #   <li><a href="3.3/">3.3/</a></li>
  r=r'<li><a href="(\d*\.\d*)/">(\d*\.\d*)/</a></li>'
  findResult=re.findall(r,html)
  latestStableVersionRepeated2Times = findResult[-1:][0]
  latestStableVersion=latestStableVersionRepeated2Times[0]
  return latestStableVersion
  
  
  
