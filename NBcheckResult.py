#! /usr/bin/env python

import re 
import os 

import NBprojectConfig


#------------------------------------------------------------------------
# Determine if a projects "make test" or unitTest ran successfully.
# Since projects are not consistent in how they report success,
# this function has specialized code for some projects.
#------------------------------------------------------------------------
def didTestFail( result, project, buildStep ) :
  retVal = None

  # If the return code is not 0, then failure
  if result['returnCode'] != 0 :
    retVal = "Non-zero return code of "+result['returnCode']

  # Many tests write a "Success" message.
  # For test that do this, check for the success message
  if NBprojectConfig.ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS.has_key(project) : 
    if buildStep in NBprojectConfig.ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS[project] :
      # Is the success message contained in the output?
      if result['stderr'].rfind("All tests completed successfully") == -1 and \
         result['stdout'].rfind("All tests completed successfully") == -1 :
        # Success message not found, assume test failed
        retVal = "The output does not contain the messages: 'All tests completed successfully'"

  #---------------------------------------------------------------------
  # Some (project,buildStep) pairs require further checking
  # to determine if they were successful
  #---------------------------------------------------------------------
  # Clp's "./clp -unitTest dirNetlib=_NETLIBDIR_ -netlib"
  if project=='Clp' and buildStep==NBprojectConfig.UNITTEST_CMD['Clp'] :
    # Check that last netlib test case ran by looking for message of form
    # '../../Data/Netlib/woodw took 0.47 seconds using algorithm either'
    reexp = r"(.|\n)*(\\|/)Data(\\|/)Netlib(\\|/)woodw took (\d*\.\d*) seconds using algorithm either(.|\n)*"
    msgTail = result['stdout'][-200:]
    if not re.compile(reexp).match(msgTail,1) :
      # message not found, assume test failed
      retVal = "Did not complete the woodw testcase"
      
  # Cbc's "make test"
  elif project=='Cbc' and buildStep=='make test' :
    # Check that last the last few lines are of the form
    # 'cbc_clp solved 2 out of 2 and took XX.XX seconds.'
    reexp=r"(.|\n)*cbc_clp solved 2 out of 2 and took (\d*\.\d*) seconds."
    msgTail = result['stdout'][-300:]
    if not re.compile(reexp).match(msgTail,1) :
      # message not found, assume test failed
      retVal = "Did not dispaly message 'cbc_clp solved 2 out of 2 and took XX.XX seconds.'" 

  # Cbc's "./cbc -unitTest dirNetlib=_MIPLIB3DIR_ -miplib"
  elif project=='Cbc' and buildStep==NBprojectConfig.UNITTEST_CMD['Cbc'] :
    if result['returnCode']>=0 and result['returnCode']<=2 :
      # return code is between 0 and 2.
      # Return code between 1 and 44 is the number of test cases that
      # ended because maxnodes limit reached.  John Forrest says if this
      # is less than 3, the OK.
      retVal=None
    else :
      retVal = "Return code of "+result['returnCode']+" which is > 2."

  # DyLP's "make test"
  # DyLP's "./unitTest -testOsiSolverInterface -netlibDir=_NETLIBDIR_"
  # Osi's "make test"
  # Osi's "./unitTest -testOsiSolverInterface -netlibDir=_NETLIBDIR_"
  elif project=='DyLP' and buildStep=='make test' or \
       project=='DyLP' and buildStep==NBprojectConfig.UNITTEST_CMD['Osi'] or \
       project=='Osi'  and buildStep=='make test' or \
       project=='Osi'  and buildStep==NBprojectConfig.UNITTEST_CMD['Osi'] :
    # Messages should not contain:
    # "*** xxxSolverInterface testing issue: whatever the problem is"
    reexp=r'.*\*\*.+SolverInterface testing issue:.*'
    if re.compile(reexp).match(result['stderr'],1) :
      # message found, assume test failed
      retVal = "Issued message: 'SolverInterface tessting issue:'"
    if re.compile(reexp).match(result['stdout'],1) :
      # message found, assume test failed
      retVal = "Issued message: 'SolverInterface tessting issue:'"

    if project=='Osi'  and buildStep==NBprojectConfig.UNITTEST_CMD['Osi'] :

      # Look for pattern "<solver> solved NN out of 90 and took nnn.xx seconds"
      r=r'((.+) solved (\d+) out of 90 and took (\d*\.\d*) seconds)'
      osisSummaryResult=re.findall(r,result['stdout'][-800:])
      expectedOsis=['clp','sym','dylp','cbcclp']
      for osi in osisSummaryResult :
        if osi[1] in expectedOsis: expectedOsis.remove(osi[1])
        numSolved = int(osi[2])
        # Sym only solves 89 of the 90
        if osi[1]=='sym':
          if numSolved<89 :
            retVal=osi[1]+\
                 " only solved "\
                 +osi[2]\
                 +" out of 90 in "\
                 +osi[3]+" seconds"
        elif numSolved<90 :
          retVal=osi[1]+\
                 " only solved "\
                 +osi[2]+\
                 " out of 90 in "\
                 +osi[3]+" seconds"
      if len(expectedOsis)!=0 :
        retVal="Osi "+expectedOsis[0]+" did not report number solved"

  return retVal

#-------------------------------------------------------------------------
#
# Determine if config needs to be run.
# If there is a config.log file and it indicates that it ran successfully
# then config should not need to be rerun.
#
#-------------------------------------------------------------------------
def didConfigRunOK( ) :
  retVal=1
  logFileName='config.log'
  if not os.path.isfile(logFileName) :
    retVal=0
  else :
    # Read logfile
    logFilePtr = open(logFileName,'r')
    logfile = logFilePtr.read()
    logFilePtr.close()

    # If logfile does not contain "configure: exit 0" then assume
    # that configure needs to be rerun
    if logfile.rfind("configure: exit 0") == -1 :
      retVal=0

  return retVal
