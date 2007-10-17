#! /usr/bin/env python

import os

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
