#! /usr/bin/env python

import os
import sys
import smtplib
import re 

import NBuserConfig
import NBprojectConfig
import NBlogMessages
import NBemail
import NBosCommand

# TODO:
#   -After "svn co" then get all 3rd party packages.
#   -Get some information about the platform and put this in email failure message.
#   -Implement Kipp's vpath (delete vpath instead of 'make distclean').
#   Break this file up into multiple files so it is manageable.
#   Don't do build if 'svn update' doesn't change anything and prior test was OK.
#     (no need to re-run if nothing has changed since prior run)
#   Build both trunk and latest stable 
#   Build both optimized and debug (or have a set of config-site scripts to test?)
#   Check the testing of the success criteria of each projects "make test" 
#   Implement "cbc -miplib" test for successful run.  JohnF sent JP the criteria
#     to test on in an email dated 10/12/2007 12:01pm



#------------------------------------------------------------------------
# Function to Check Return Code from unitTest
#------------------------------------------------------------------------
def didTestFail( result, project, buildStep ) :
  retVal = 0

  # If the return code is not 0, then failure
  if result['returnCode'] != 0 :
    retVal = 1

  # Many tests write a "Success" message.
  # For test that do this, check for the success message
  if NBprojectConfig.ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS.has_key(project) : 
    if buildStep in NBprojectConfig.ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS[project] :
      # Is the success message contained in the output?
      if result['stderr'].rfind("All tests completed successfully") == -1 and \
         result['stdout'].rfind("All tests completed successfully") == -1 :
        # Success message not found, assume test failed
        retVal = 1

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
      retVal = 1
      
  # Cbc's "make test"
  elif project=='Cbc' and buildStep=='make test' :
    # Check that last the last few lines are of the form
    # 'cbc_clp solved 2 out of 2 and took XX.XX seconds.'
    reexp=r"(.|\n)*cbc_clp solved 2 out of 2 and took (\d*\.\d*) seconds."
    msgTail = result['stdout'][-300:]
    if not re.compile(reexp).match(msgTail,1) :
      # message not found, assume test failed
      retVal = 1

  # Cbc's "./cbc -unitTest dirNetlib=_MIPLIB3DIR_ -miplib"
  elif project=='Cbc' and buildStep==NBprojectConfig.UNITTEST_CMD['Cbc'] :
    if result['returnCode']>=0 and result['returnCode']<=2 :
      # return code is between 0 and 2.
      # Return code between 1 and 44 is the number of test cases that
      # ended because maxnodes limit reached.  John Forrest says if this
      # is less than 3, the OK.
      retVal=0
    else :
      retVal=1

  return retVal

#------------------------------------------------------------------------
# Function for executing svn commands
#------------------------------------------------------------------------
def issueSvnCmd(svnCmd,dir,project) :
  retVal='OK'
  os.chdir(dir)
  NBlogMessages.writeMessage('  '+svnCmd)
  result = NBosCommand.run(svnCmd)
  if result['returnCode'] != 0 :
    NBemail.sendCmdMsgs(project,result,svnCmd)
    retVal='Error'
  return retVal

#------------------------------------------------------------------------
#  Main Program Starts Here  
#------------------------------------------------------------------------

#------------------------------------------------------------------------
#  If needed create the top level directory
#------------------------------------------------------------------------
if not os.path.isdir(NBuserConfig.NIGHTLY_BUILD_ROOT_DIR) :
  os.makedirs(NBuserConfig.NIGHTLY_BUILD_ROOT_DIR)
os.chdir(NBuserConfig.NIGHTLY_BUILD_ROOT_DIR)

#------------------------------------------------------------------------
#  Get the data directories if they don't already exist
#------------------------------------------------------------------------
dataBaseDir=os.path.join(NBuserConfig.NIGHTLY_BUILD_ROOT_DIR,'Data')
if not os.path.isdir(dataBaseDir) :
  os.makedirs(dataBaseDir)
dataDirs=['Netlib','miplib3']
for d in dataDirs :
  dataDir=os.path.join(dataBaseDir,d)
  if not os.path.isdir(dataDir) :
    svnCmd=os.path.join(NBuserConfig.SVNPATH_PREFIX,'svn') + ' checkout https://projects.coin-or.org/svn/Data/releases/1.0.0/'+d+' '+d
    if issueSvnCmd(svnCmd,dataBaseDir,'Data')!='OK' :
      sys.exit(1)
    result=NBosCommand.run('find '+d+' -name \*.gz -print | xargs gzip -d')
netlibDir=os.path.join(dataBaseDir,'Netlib')
miplib3Dir=os.path.join(dataBaseDir,'miplib3')

#------------------------------------------------------------------------
# Loop once for each project
#------------------------------------------------------------------------
for p in NBuserConfig.PROJECTS:
  NBlogMessages.writeMessage( p )

  #---------------------------------------------------------------------
  # svn checkout or update the project
  #---------------------------------------------------------------------
  projectBaseDir=os.path.join(NBuserConfig.NIGHTLY_BUILD_ROOT_DIR,p)
  projectCheckOutDir=os.path.join(projectBaseDir,'trunk')
  if not os.path.isdir(projectBaseDir) :
    os.makedirs(projectBaseDir)
  if not os.path.isdir(projectCheckOutDir) :
    svnCmd=os.path.join(NBuserConfig.SVNPATH_PREFIX,'svn') + ' checkout https://projects.coin-or.org/svn/'+p+'/trunk trunk'
    if issueSvnCmd(svnCmd,projectBaseDir,p)!='OK' :
      continue
  else :
    svnCmd=os.path.join(NBuserConfig.SVNPATH_PREFIX,'svn') + ' update'
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
  NBlogMessages.writeMessage('  '+configCmd)
  result=NBosCommand.run(configCmd)
  
  # Check if configure worked
  if result['returnCode'] != 0 :
    error_msg = result
    # Add contents of log file to message
    logFileName = 'config.log'
    if os.path.isfile(logFileName) :
      logFilePtr = open(logFileName,'r')
      error_msg['config.log']  = "config.log contains: \n" 
      error_msg['config.log'] += logFilePtr.read()
      logFilePtr.close()
    NBemail.sendCmdMsgs(p,error_msg,configCmd)
    continue

  #---------------------------------------------------------------------
  # Run make part of build
  #---------------------------------------------------------------------
  NBlogMessages.writeMessage( '  make' )
  result=NBosCommand.run('make')
  
  # Check if make worked
  if result['returnCode'] != 0 :
    NBemail.sendCmdMsgs(p,result,'make')
    continue

  #---------------------------------------------------------------------
  # Run 'make test' part of build
  #---------------------------------------------------------------------
  NBlogMessages.writeMessage( '  make test' )
  result=NBosCommand.run('make test')
  
  # Check if 'make test' worked
  if didTestFail(result,p,"make test") :
    NBemail.sendCmdMsgs(p,result,"make test")
    continue

  #---------------------------------------------------------------------
  # Run unitTest if available and different from 'make test'
  #---------------------------------------------------------------------
  if NBprojectConfig.UNITTEST_CMD.has_key(p) :
    unitTestPath = os.path.join(projectCheckOutDir,NBprojectConfig.UNITTEST_DIR[p])
    os.chdir(unitTestPath)

    unitTestCmdTemplate=NBprojectConfig.UNITTEST_CMD[p]
    unitTestCmd=unitTestCmdTemplate.replace('_NETLIBDIR_',netlibDir)
    unitTestCmd=unitTestCmd.replace('_MIPLIB3DIR_',miplib3Dir)

    NBlogMessages.writeMessage( '  '+unitTestCmd )
    result=NBosCommand.run(unitTestCmd)
  
    if didTestFail(result,p,unitTestCmdTemplate) :
      NBemail.sendCmdMsgs(p,result,unitTestCmd)
      continue

  # For testing purposes only do first successful project
  #break


NBlogMessages.writeMessage( "nightlyBuild.py Finished" )

sys.exit(0)


# START KIPP
#----------------------------------------------------------------------
# CONFIG FILE PATH: 
#   path to the config file for the build
#   done. If the directory does not exist, it will be created.
#   this should have all of the user specific data
#   it should have values for
#   NIGHTLY_BUILD_ROOT
#   NBuserConfig.SMTP_SERVER_NAME
#   NBuserConfig.SMTP_SERVER_PORT 
#   NBuserConfig.SMTP_SSL_SERVER 
#   NBuserConfig.SMTP_USER_NAME
#   NBuserConfig.SMTP_PASSWORD_FILENAME = '/home/jp/bin/smtpPwFile'
#   NBuserConfig.SENDER_EMAIL_ADDR='jpfasano _AT_ verizon _DOT_ net'
#   NBuserConfig.MY_EMAIL_ADDR='jpfasano _AT_ us _DOT_ ibm _DOT_ com'
#   
#----------------------------------------------------------------------

CONFIG_FILE_PATH = '/Users/kmartin/Documents/files/configDir/'
CONFIG_FILENAME = 'config.txt'


# Get configFile data

configFile = os.path.join(os.path.dirname( CONFIG_FILE_PATH),
                                 os.path.basename(CONFIG_FILENAME ))
if os.path.isfile(  configFile) :
  pwFilePtr = open(configFile ,'r')
  d = pwFilePtr.readlines()
  # do pwFilePtr.read() to get a string object
  # we have a list object
  print d[0]
  print d[1]
  # make a dictionary
  config_dic = {}

  #smtppass  = pwFilePtr.read().strip()
  pwFilePtr.close()
else :
  #NBlogMessages.writeMessage( "Failure reading pwFileName=" + CONFIG_FILENAME )
  #print cmdMsgs
  sys.exit( 1)
sys.exit( 0)



# START KIPP
#----------------------------------------------------------------------
#   path to the config file for the build
#   get the user dependent variables
# CONFIG FILE PATH: 
#   it should have values for
#   NIGHTLY_BUILD_ROOT
#   NBuserConfig.SMTP_SERVER_NAME
#   NBuserConfig.SMTP_SERVER_PORT 
#   NBuserConfig.SMTP_SSL_SERVER 
#   NBuserConfig.SMTP_USER_NAME
#   NBuserConfig.SMTP_PASSWORD_FILENAME 
#   NBuserConfig.SENDER_EMAIL_ADDR
#   NBuserConfig.MY_EMAIL_ADDR
#   
#----------------------------------------------------------------------

CONFIG_FILE_PATH = '/Users/kmartin/Documents/files/configDir/'
CONFIG_FILENAME = 'config.txt'


# Get configFile data

configFile = os.path.join(os.path.dirname( CONFIG_FILE_PATH),
                                 os.path.basename(CONFIG_FILENAME ))
if os.path.isfile(  configFile) :
  pwFilePtr = open(configFile ,'r')
  d = pwFilePtr.readlines()
  # do pwFilePtr.read() to get a string object
  # we have a list object
  print d[0]
  print d[1]
  # make a dictionary
  config_dic = {}

  #smtppass  = pwFilePtr.read().strip()
  pwFilePtr.close()
else :
  #NBlogMessages.writeMessage( "Failure reading pwFileName=" + CONFIG_FILENAME )
  #print cmdMsgs
  sys.exit( 1)
sys.exit( 0)

# END KIPP
