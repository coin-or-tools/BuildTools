#! /usr/bin/env python

import os
import sys
import commands
import smtplib
import re
import time

# TODO:
#   If project does not exist, then "svn co".
#   If did "svn co" then get all 3rd party packages.
#   Get some information about the platform and put this in email failure message.
#   Implement Kipp's vpath (delete vpath instead of 'make distclean').
#   Get miplib3 and netlib files with seperate checkout.
#   Break this file up into multiple files so it is manageable.
#   Don't do build if 'svn update' does change anything and prior test was OK.
#     (no need to re-run if nothing has changed since prior run)
#   Allow pw file to be in same directory as script or other locations.
#   Add server and login name to pw file?
#   Build both trunk and latest stable 
#   Build both optimized and debug
#   Implement "cbc -miplib" test for successful run.  JohnF sent JP the criteria
#     to test on in an email dated 10/12/2007 12:01pm

#----------------------------------------------------------------------
# NIGHTLY_BUILD_ROOT_DIR: 
#   directory where code will be checked out and builds
#   done. If the directory does not exist, it will be created.
#----------------------------------------------------------------------
NIGHTLY_BUILD_ROOT_DIR = '/home/jp/COIN'

#----------------------------------------------------------------------
# PASSWORD_FILENAME: name of file containing smtp password
#----------------------------------------------------------------------
PASSWORD_FILENAME = '/home/jp/bin/smtpPwFile'

PROJECTS = ['CoinUtils','DyLP','Clp','SYMPHONY','Vol','Osi','Cgl','Cbc','Ipopt','OS','CppAD']

PROJECT_EMAIL_ADDRS = {}
UNITTEST_DIR = {}
UNITTEST_CMD = {}
ALL_TEST_COMPLETED_SUCCESSFULLY_CMDS = {} 

#PROJECT_EMAIL_ADDRS['CoinUtils'] = 'ladanyi _AT_ us _DOT_ ibm _DOT_ com'
ALL_TEST_COMPLETED_SUCCESSFULLY_CMDS['CoinUtils'] = ['make test']

#PROJECT_EMAIL_ADDRS['DyLP'] = 'lou _AT_ cs _DOT_ sfu _DOT_ ca'
UNITTEST_DIR['DyLP'] = os.path.join('Osi','test')
UNITTEST_CMD['DyLP'] = './unitTest -testOsiSolverInterface -netlibDir=_NETLIBDIR_ -cerr2cout' 
ALL_TEST_COMPLETED_SUCCESSFULLY_CMDS['DyLP'] = ['make test']

#PROJECT_EMAIL_ADDRS['Clp'] = 'jjforre _AT_ us _DOT_ ibm _DOT_ com'
UNITTEST_DIR['Clp'] = os.path.join('Clp','src')
UNITTEST_CMD['Clp'] = './clp -unitTest -netlib dirNetlib=_NETLIBDIR_' 
ALL_TEST_COMPLETED_SUCCESSFULLY_CMDS['Clp'] = ['make test',UNITTEST_CMD['Clp']]

#PROJECT_EMAIL_ADDRS['SYMPHONY'] = 'tkr2 _AT_ lehigh _DOT_ edu'
ALL_TEST_COMPLETED_SUCCESSFULLY_CMDS['SYMPHONY'] = ['make test']

#PROJECT_EMAIL_ADDRS['Vol'] = 'barahon _AT_ us _DOT_ ibm _DOT_ com'

#PROJECT_EMAIL_ADDRS['Osi'] = 'mjs _AT_ ces _DOT_ clemson _DOT_ edu'
UNITTEST_DIR['Osi'] = os.path.join('Osi','test')
UNITTEST_CMD['Osi'] = './unitTest -testOsiSolverInterface' 
UNITTEST_CMD['Osi'] = './unitTest -testOsiSolverInterface -netlibDir=_NETLIBDIR_ -cerr2cout' 
ALL_TEST_COMPLETED_SUCCESSFULLY_CMDS['Osi'] = ['make test',UNITTEST_CMD['Osi']]

#PROJECT_EMAIL_ADDRS['Cgl'] = 'robinlh _AT_ us _DOT_ ibm _DOT_ com'
ALL_TEST_COMPLETED_SUCCESSFULLY_CMDS['Cgl'] = ['make test']

#PROJECT_EMAIL_ADDRS['Cbc'] = 'jjforre _AT_ us _DOT_ ibm _DOT_ com'
ALL_TEST_COMPLETED_SUCCESSFULLY_CMDS['Cbc'] = ['make test']

#PROJECT_EMAIL_ADDRS['Ipopt'] = 'andreasw _AT_ us _DOT_ ibm _DOT_ com'
#PROJECT_EMAIL_ADDRS['OS'] = 'kipp _DOT_ martin _AT_ chicagogsb _DOT_ edu'
#PROJECT_EMAIL_ADDRS['CppAD'] = 'bradbell _AT_ washington _DOT_ edu'

#------------------------------------------------------------------------
# Function to send an email message
#------------------------------------------------------------------------
def sendmail(project,cmdMsgs,cmd):
  curDir = os.getcwd()
  smtpserver = 'outgoing.verizon.net'
  #smtpserver = 'gsbims.chicagogsb.edu'
  smtpuser = 'jpfasano'
  
  # Get smpt server password
  if os.path.isfile(PASSWORD_FILENAME) :
    pwFilePtr = open(PASSWORD_FILENAME,'r')
    smtppass  = pwFilePtr.read().strip()
    pwFilePtr.close()
  else :
    writeLogMessage( "Failure reading pwFileName=" + pwFileName )
  sender = unscrambleEmailAddress('jpfasano _AT_ verizon _DOT_ net')
  toAddrs = [unscrambleEmailAddress('jpfasano _AT_ us _DOT_ ibm _DOT_ com')]
  if PROJECT_EMAIL_ADDRS.has_key(project) :
    toAddrs.append(unscrambleEmailAddress(PROJECT_EMAIL_ADDRS[project]))
  session = smtplib.SMTP(smtpserver)
  session.login(smtpuser,smtppass)
  subject = project + " build problem when running '" + cmd +"'"
  msgWHeader = ("From: %s\r\nTo: %s\r\nSubject: %s\r\n\r\n"
       % (sender, ", ".join(toAddrs), subject))
  msgWHeader += "'" + cmd + "' from directory " + curDir + " failed.\n\n"
  msgWHeader += "'" + cmd + "' messages are:\n" 
  msgWHeader += cmdMsgs
  #session.set_debuglevel(1)
  rc = session.sendmail(sender,toAddrs,msgWHeader)
  if rc!={} :
    writeLogMessage( 'session.sendmail rc='  )
    writeLogMessage( rc )
  writeLogMessage( "  email sent regarding "+project+" running '"+cmd+"'" )
  session.quit()

#------------------------------------------------------------------------
# Decrypt email address 
#------------------------------------------------------------------------
def unscrambleEmailAddress( scrambledEmailAddress ) :
  retVal = scrambledEmailAddress
  retVal = retVal.replace(' _AT_ ','@')
  retVal = retVal.replace(' _DOT_ ','.')
  return retVal

#------------------------------------------------------------------------
# Function to Check Return Code from unitTest
#------------------------------------------------------------------------
def didTestFail( rc, project, buildStep ) :
  retVal = 0

  # If the return code is not 0, then failure
  if rc[0] != 0 :
    retVal = 1

  # Many tests write a "Success" message.
  # For test that do this, check for the success message
  if ALL_TEST_COMPLETED_SUCCESSFULLY_CMDS.has_key(project) : 
    if buildStep in ALL_TEST_COMPLETED_SUCCESSFULLY_CMDS[project] :
      # Is the success message contained in the output?
      if rc[1].rfind("All tests completed successfully") == -1 :
        # Success message not found, assume test failed
        retVal = 1

  # Some (project,buildStep) pairs require further checking
  if project=='Clp' and buildStep==UNITTEST_CMD['Clp'] :
    # Build Step is './clp -unitTest -netlib' 
    # Check that last netlib test case ran by looking for message of form
    # '../../Data/Netlib/woodw took 0.47 seconds using algorithm either'
    reexp = r"(.|\n)*\.\.(\\|/)\.\.(\\|/)Data(\\|/)Netlib(\\|/)woodw took (\d*\.\d*) seconds using algorithm either(.|\n)*"
    msgTail = rc[1][len(rc[1])-200:]
    if not re.compile(reexp).match(msgTail,1) :
      # message not found, assume test failed
      retVal = 1

  return retVal

#------------------------------------------------------------------------
# Function for executing svn commands
#------------------------------------------------------------------------
def issueSvnCmd(svnCmd,dir,project) :
  retVal='OK'
  os.chdir(dir)
  writeLogMessage('  '+svnCmd)
  rc=commands.getstatusoutput(svnCmd)
  if rc[0] != 0 :
    sendmail(p,rc[1],svnCmd)
    retVal='Error'
  return retVal

#------------------------------------------------------------------------
# Function to write log messages
#------------------------------------------------------------------------
def writeLogMessage( msg ) :
  logMsg = time.ctime(time.time())+': '
  logMsg += msg
  print logMsg

#------------------------------------------------------------------------
#  Main Program Starts Here  
#------------------------------------------------------------------------

#------------------------------------------------------------------------
#  If needed create the top level directory
#------------------------------------------------------------------------
# rc=commands.getstatusoutput(NIGHTLY_BUILD_ROOT_DIR)
if not os.path.isdir(NIGHTLY_BUILD_ROOT_DIR) :
  os.makedirs(NIGHTLY_BUILD_ROOT_DIR)
os.chdir(NIGHTLY_BUILD_ROOT_DIR)

#------------------------------------------------------------------------
#  Get the data directories if they don't already exist
#------------------------------------------------------------------------
dataBaseDir=os.path.join(NIGHTLY_BUILD_ROOT_DIR,'Data')
if not os.path.isdir(dataBaseDir) :
  os.makedirs(dataBaseDir)
dataDirs=['Netlib','miplib3']
for d in dataDirs :
  dataDir=os.path.join(dataBaseDir,d)
  if not os.path.isdir(dataDir) :
    svnCmd='svn checkout https://projects.coin-or.org/svn/Data/releases/1.0.0/'+d+' '+d
    if issueSvnCmd(svnCmd,dataBaseDir,'Data')!='OK' :
      sys.exit(1)
    rc=commands.getstatusoutput('find '+d+' -name \*.gz -print | xargs gzip -d')
netlibDir=os.path.join(dataBaseDir,'Netlib')
miplib3Dir=os.path.join(dataBaseDir,'miplib3')

#------------------------------------------------------------------------
# Loop once for each project
#------------------------------------------------------------------------
for p in PROJECTS:
  writeLogMessage( p )
  rc = [0]

  #---------------------------------------------------------------------
  # svn checkout or update the project
  #---------------------------------------------------------------------
  projectBaseDir=os.path.join(NIGHTLY_BUILD_ROOT_DIR,p)
  projectCheckOutDir=os.path.join(projectBaseDir,'trunk')
  if not os.path.isdir(projectBaseDir) :
    os.makedirs(projectBaseDir)
  if not os.path.isdir(projectCheckOutDir) :
    svnCmd='svn checkout https://projects.coin-or.org/svn/'+p+'/trunk trunk'
    if issueSvnCmd(svnCmd,projectBaseDir,p)!='OK' :
      continue
  else :
    svnCmd='svn update'
    if issueSvnCmd(svnCmd,projectCheckOutDir,p)!='OK' :
      continue

  #---------------------------------------------------------------------
  # Should probably run make 'distclean' to do a build from scrath
  # or delete the VPATH directory when there is one
  #---------------------------------------------------------------------


  #---------------------------------------------------------------------
  # Run configure part of buid
  #---------------------------------------------------------------------
  os.chdir(projectCheckOutDir)
  configCmd = os.path.join('.','configure -C')
  writeLogMessage('  '+configCmd)
  rc=commands.getstatusoutput(configCmd)
  
  # Check if configure worked
  if rc[0] != 0 :
    error_msg = rc[1] + '\n\n'
    # Add contents of log file to message
    logFileName = 'config.log'
    if os.path.isfile(logFileName) :
      logFilePtr = open(logFileName,'r')
      error_msg += "config.log contains: \n" 
      error_msg += logFilePtr.read()
      logFilePtr.close()
    sendmail(p,error_msg,configCmd)
    continue

  #---------------------------------------------------------------------
  # Run make part of buid
  #---------------------------------------------------------------------
  writeLogMessage( '  make' )
  rc=commands.getstatusoutput('make')
  
  # Check if make worked
  if rc[0] != 0 :
    sendmail(p,rc[1],'make')
    continue

  #---------------------------------------------------------------------
  # Run 'make test' part of buid
  #---------------------------------------------------------------------
  writeLogMessage( '  make test' )
  rc=commands.getstatusoutput('make test')
  
  # Check if 'make test' worked
  if didTestFail(rc,p,"make test") :
    sendmail(p,rc[1],"make test")
    continue

  #---------------------------------------------------------------------
  # Run unitTest if available and different from 'make test'
  #---------------------------------------------------------------------
  if UNITTEST_CMD.has_key(p) :
    unitTestPath = os.path.join(projectCheckOutDir,UNITTEST_DIR[p])
    os.chdir(unitTestPath)

    unitTestCmd=UNITTEST_CMD[p]
    unitTestCmd=unitTestCmd.replace('_NETLIBDIR_',netlibDir)
    unitTestCmd=unitTestCmd.replace('_MIPLIB3DIR_',miplib3Dir)

    writeLogMessage( '  '+unitTestCmd )
    rc=commands.getstatusoutput(unitTestCmd)
  
    if didTestFail(rc,p,unitTestCmd) :
      sendmail(p,rc[1],unitTestCmd)
      continue

  # For testing purposes only do first successful project
  #break


writeLogMessage( "nightlyBuild.py Finished" )

sys.exit(0)
