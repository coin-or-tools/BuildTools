#! /usr/bin/env python

from socket import gethostname

#------------------------------------------------------------------------
# Run a an OS command in another process.
# Examples might be 'svn checkout', 'make test'.
# Return: command's return code, stdout messages, & stderr messages
#------------------------------------------------------------------------
def run(cmd) :

  if gethostname()=='math01.watson.ibm.com' :

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


#  run = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
#
#  # Wait for the process to return
#  import thread, threading
#  out, err = [''], ['']
#  #out, err = "", "" 
#  out_ended, err_ended = threading.Event(), threading.Event()
#
#  def getOutput(output, lines, ended_event) :
#    #for i in output.readlines() : lines.append(i)
#    for i in output.readlines() : 
#      lines[0] = lines[0]+i
#    ended_event.set()
#
#  out_thread = thread.start_new_thread(getOutput, (run.stdout, out, out_ended))
#  err_thread = thread.start_new_thread(getOutput, (run.stderr, err, err_ended))
#
#  out_ended.wait()
#  err_ended.wait()
#
#  returncode = run.wait()
#
#  retVal = { 'returnCode':returncode, 'stdout':out[0], 'stderr':err[0] }
#  return retVal

