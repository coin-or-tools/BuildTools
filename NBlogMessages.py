#! /usr/bin/env python

import time
import NBuserParameters

#TODO: one could open the logfile once in the beginning, set it to sys.stdout, flush after each message, and close it finally

#------------------------------------------------------------------------
# Function to write log messages
#------------------------------------------------------------------------
def writeMessage( msg ) :
  logMsg = time.ctime(time.time())+': '
  logMsg += msg
  if NBuserParameters.LOGPRINT :
    print logMsg
  if len(NBuserParameters.LOGFILE) > 0 and not NBuserParameters.LOGFILE.isspace() :
    logfile=open(NBuserParameters.NIGHTLY_BUILD_ROOT_DIR+'/'+NBuserParameters.LOGFILE, 'a')
    logfile.write(logMsg+'\n')
#    logfile.flush()
    logfile.close()
