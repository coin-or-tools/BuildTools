#! /usr/bin/env python

import time
import NBuserConfig

#TODO: one could open the logfile once in the beginning, set it to sys.stdout, flush after each message, and close it finally

#------------------------------------------------------------------------
# Function to write log messages
#------------------------------------------------------------------------
def writeMessage( msg ) :
  logMsg = time.ctime(time.time())+': '
  logMsg += msg
  if len(NBuserConfig.LOGFILE) == 0 or NBuserConfig.LOGFILE.isspace() :
    print logMsg
  else :
    logfile=open(NBuserConfig.NIGHTLY_BUILD_ROOT_DIR+'/'+NBuserConfig.LOGFILE, 'a')
    logfile.write(logMsg+'\n')
#    logfile.flush()
    logfile.close()
