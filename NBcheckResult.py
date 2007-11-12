#! /usr/bin/env python

#------------------------------------------------------------------------
# This file is distributed under the Common Public License.
# It is part of the BuildTools project in COIN-OR (www.coin-or.org)
#------------------------------------------------------------------------

import re 
import os 

import NBprojectConfig

#------------------------------------------------------------------------
# Determine if a projects "make test" or unitTest ran successfully.
# Since projects are not consistent in how they report success,
# this function has specialized code for some projects.
#------------------------------------------------------------------------

# Assume result is always correct
def anythingGoes( result, project ) :
  retVal = None
  return retVal

# Is the rc=0?
def rc0( result, project ) :
  retVal = None
  # If the return code is not 0, then failure
  if result['returnCode'] != 0 :
    retVal = "Non-zero return code of "+str(result['returnCode'])
  return retVal  
    
# Is 0<=rc<=2?
def rc0to2( result, project ) :
  retVal = None
  # If the return code is not 0, then failure
  if 0>result['returnCode'] or result['returnCode']>2 :
    retVal = "Return code out of range. Expected: 0<=rc<=2. rc="+str(result['returnCode'])
  return retVal

# Was the standard success message written?
def standardSuccessMessage(result,project) :
  retVal = None
  # Is the success message contained in the output?
  if result['stderr'].rfind("All tests completed successfully") == -1 and \
     result['stdout'].rfind("All tests completed successfully") == -1 :
    # Success message not found, assume test failed
    retVal = "The output does not contain the message: 'All tests completed successfully'"
  return retVal

# Was "*** Done! ***" written at end?
def endWithStarDoneStar(result,project) :
  retVal = None
  # Is the success message contained in the output?
  if result['stdout'][-200:].rfind("*** Done! ***") == -1 :
    # Success message not found, assume test failed
    retVal = "The output does not end with the message: '*** Done! ***'"
  return retVal  

# Was woodw the last netlib problem run?
# Check that last netlib test case ran by looking for message of form
# '../../Data/Netlib/woodw took 0.47 seconds using algorithm either'
def endWithWoodw(result,project) :
  retVal = None
  reexp = r"(.|\n)*(\\|/)Data(\\|/)Netlib(\\|/)woodw took (\d*\.\d*) seconds using algorithm either(.|\n)*"
  msgTail = result['stdout'][-200:]
  if not re.compile(reexp).match(msgTail,1) :
    # message not found, assume test failed
    retVal = "Did not complete the woodw testcase"
  return retVal

# Did Cbc 'make test' write its success message?
# Check that last the last few lines are of the form
# 'cbc_clp solved 2 out of 2 and took XX.XX seconds.'
def cbcMakeTestSuccessMessage(result,project) :
  retVal=None
  reexp=r"(.|\n)*cbc_clp solved 2 out of 2 and took (\d*\.\d*) seconds."
  msgTail = result['stdout'][-300:]
  if not re.compile(reexp).match(msgTail,1) :
    # message not found, assume test failed
    retVal = "Did not display message 'cbc_clp solved 2 out of 2 and took XX.XX seconds.'" 
  return retVal

# Messages must not contain:
# "*** xxxSolverInterface testing issue: whatever the problem is"
def noSolverInterfaceTestingIssueMessage(result,project):
  retVal = None
  reexp=r'.*\*\*.+SolverInterface testing issue:.*'
  if re.compile(reexp).match(result['stderr'],1) :
    # message found, assume test failed
    retVal = "Issued message: 'SolverInterface tessting issue:'"
  if re.compile(reexp).match(result['stdout'],1) :
    # message found, assume test failed
    retVal = "Issued message: 'SolverInterface tessting issue:'"
  return retVal
      

# Look for pattern "<solver> solved NN out of 90 and took nnn.xx seconds"
def OsiUnitTestSuccessMessages(result,project):
  retVal = None
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
