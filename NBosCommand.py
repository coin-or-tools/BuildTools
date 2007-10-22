#! /usr/bin/env python

from socket import gethostname
import sys
import os
import re

#------------------------------------------------------------------------
# newer(source, target)
# Return true if source exists and is more recently modified than target,
# or if source exists and target doesn't.
# Return false if both exist and target is the same age or newer than source.
# Raise DistutilsFileError if source does not exist.
#------------------------------------------------------------------------
def newer(source,target) :
  if sys.version[:6]<'2.5.0' :
    # Version of python being used does not have distutils
    if not os.path.isfile(source) : sys.exit(1)
    if os.name!="posix" :
      # Always assume target is out of date
      return True
    else :
      # running on posix so should be able to use ls command
      if not os.path.isfile(target) : return True
      statsource = os.stat(source)
      stattarget = os.stat(target)
      return statsource.st_mtime > stattarget.st_mtime
#      lsSource=run("ls --full-time "+source)
#      lsTarget=run("ls --full-time "+target)
      #-rwxrwxrwx 1 jpf4 None 12309 2007-10-21 16:13:47.395793600 -0400 nightlyBuild.py
#      rexBase=r"(-|r|w|x){10} . (.+) (.+) (.+) (\d\d\d\d-\d\d-\d\d .+) "
#      rexSource=rexBase+source
#      rexTarget=rexBase+target
#      timeSource=(re.findall(rexSource,lsSource['stdout']))[0][4]
#      timeTarget=(re.findall(rexTarget,lsTarget['stdout']))[0][4]
#      return timeSource > timeTarget
      
  else :
    import distutils.dep_util 
    return distutils.dep_util.newer(source,target)


#------------------------------------------------------------------------
# Run an OS command in another process.
# Examples might be 'svn checkout', 'make test'.
# Return: command's return code, stdout messages, & stderr messages
#------------------------------------------------------------------------
def run(cmd) :

  if sys.version[:6]<'2.4.0' :

    # this machine has a back level of python, so must use an older
    # techniques to implement this function.  This implementation
    # runs the command in the same process as the script.
    # This has the problem that if the command crashes, it will bring
    # down the script. Another problem is that stderr and stdout are
    # mingled together

    import commands
    result = commands.getstatusoutput(cmd)
    retVal = { 'returnCode':result[0], 'stdout':result[1], 'stderr':'' }
    return retVal

  else :

    import subprocess
 
    p=subprocess.Popen(cmd,shell=True,\
                       stdout=subprocess.PIPE,\
                       stderr=subprocess.PIPE)
    cmdStdout,cmdStderr=p.communicate()
    cmdRc=p.returncode
    retVal = { 'returnCode':cmdRc, 'stdout':cmdStdout, 'stderr':cmdStderr }
    return retVal 




