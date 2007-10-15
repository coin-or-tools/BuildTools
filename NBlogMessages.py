#! /usr/bin/env python

import time


#------------------------------------------------------------------------
# Function to write log messages
#------------------------------------------------------------------------
def writeLogMessage( msg ) :
  logMsg = time.ctime(time.time())+': '
  logMsg += msg
  print logMsg
