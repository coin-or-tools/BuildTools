#! /usr/bin/env python

import os
import sys
import commands
import smtplib
import re 
import time

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

#----------------------------------------------------------------------
# NIGHTLY_BUILD_ROOT_DIR: 
#   directory where code will be checked out and builds
#   done. If the directory does not exist, it will be created.
#----------------------------------------------------------------------
NIGHTLY_BUILD_ROOT_DIR = '/home/jp/COIN'

#----------------------------------------------------------------------
# Values for sending mail:
#  SMTP_SERVER_NAME: name of smtp server. For gmail server 
#                 this is smtp.gmail.com
#  SMTP_SERVER_PORT: port number of the smtp server. This is typically 25,
#                 but for gmail server it is 587.
#  SMTP_SSL_SERVER: 0 or 1. If 1 then SMTP uses SSL (sometimes called startltls).
#                 For gmail this is 1.
#  SMTP_USER_NAME: name of authorized user on server. If using gmail server
#                 this is gmail_userid@gmail.com which is coded as
#                 'gmail_userid _AT_ gmail _DOT_ com.  
#  SMTP_PASSWORD_FILENAME: name of file containing smtp user's password
#  SENDER_EMAIL_ADDR: email sent by this script will be from this address
#  MY_EMAIL_ADDR: All problems detected by the script will be sent to
#                 this email address. The intention is for this to be
#                 the email address of the person running this script
#  SEND_MAIL_TO_PROJECT_MANAGER: 0 or 1. If 1 then any problems
#                 detected are sent to MY_EMAIL_ADDRESS and the
#                 project manager.
#----------------------------------------------------------------------
#SMTP_SERVER_NAME = 'outgoing.verizon.net'
#SMTP_SERVER_PORT = 25
#SMTP_SSL_SERVER = 0
#SMTP_USER_NAME = 'jpfasano'

SMTP_SERVER_NAME = 'smtp.gmail.com'
SMTP_SERVER_PORT = 587
SMTP_SSL_SERVER = 1
SMTP_USER_NAME = 'jpfasano _AT_ gmail _DOT_ com'
SMTP_PASSWORD_FILENAME = '/home/jp/bin/smtpPwFile'

SENDER_EMAIL_ADDR='jpfasano _AT_ verizon _DOT_ net'
MY_EMAIL_ADDR='jpfasano _AT_ us _DOT_ ibm _DOT_ com'
SEND_MAIL_TO_PROJECT_MANAGER=0
#SMTP_SERVER_NAME = 'gsbims.chicagogsb.edu'


#----------------------------------------------------------------------
# List of Projects to be processed by script
#----------------------------------------------------------------------
PROJECTS = ['CoinUtils','DyLP','Clp','SYMPHONY','Vol','Osi','Cgl','Cbc','Ipopt','OS','CppAD']
#PROJECTS = ['CppAD']

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS = {}
UNITTEST_DIR = {}
UNITTEST_CMD = {}
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS = {} 

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['CoinUtils'] = 'ladanyi _AT_ us _DOT_ ibm _DOT_ com'
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS['CoinUtils'] = ['make test']

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['DyLP'] = 'lou _AT_ cs _DOT_ sfu _DOT_ ca'
UNITTEST_DIR['DyLP'] = os.path.join('Osi','test')
UNITTEST_CMD['DyLP'] = './unitTest -testOsiSolverInterface -netlibDir=_NETLIBDIR_ -cerr2cout' 
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS['DyLP'] = ['make test']

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Clp'] = 'jjforre _AT_ us _DOT_ ibm _DOT_ com'
UNITTEST_DIR['Clp'] = os.path.join('Clp','src')
UNITTEST_CMD['Clp'] = './clp -unitTest -netlib dirNetlib=_NETLIBDIR_' 
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS['Clp'] = ['make test',UNITTEST_CMD['Clp']]

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['SYMPHONY'] = 'tkr2 _AT_ lehigh _DOT_ edu'
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS['SYMPHONY'] = ['make test']

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Vol'] = 'barahon _AT_ us _DOT_ ibm _DOT_ com'

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Osi'] = 'mjs _AT_ ces _DOT_ clemson _DOT_ edu'
UNITTEST_DIR['Osi'] = os.path.join('Osi','test')
UNITTEST_CMD['Osi'] = './unitTest -testOsiSolverInterface' 
UNITTEST_CMD['Osi'] = './unitTest -testOsiSolverInterface -netlibDir=_NETLIBDIR_ -cerr2cout' 
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS['Osi'] = ['make test',UNITTEST_CMD['Osi']]

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Cgl'] = 'robinlh _AT_ us _DOT_ ibm _DOT_ com'
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS['Cgl'] = ['make test']

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Cbc'] = 'jjforre _AT_ us _DOT_ ibm _DOT_ com'
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS['Cbc'] = ['make test']

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Ipopt'] = 'andreasw _AT_ us _DOT_ ibm _DOT_ com'

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['OS'] = 'kipp _DOT_ martin _AT_ chicagogsb _DOT_ edu'

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['CppAD'] = 'bradbell _AT_ washington _DOT_ edu'

#------------------------------------------------------------------------
# Send email typically about an error.
#  project: coin project name
#  cmd: command being exucuted. perhaps: "svn update", "./configure", 
#       "make".
#  cmdMsgs: the messages generated by cmd.  This will typically contain
#       errors issued by cmd.
#------------------------------------------------------------------------
def sendEmailCmdMsgs(project,cmdMsgs,cmd):
  curDir = os.getcwd()
  
  toAddrs = [unscrambleEmailAddress(MY_EMAIL_ADDR)]
  if PROJECT_EMAIL_ADDRS.has_key(project) and SEND_MAIL_TO_PROJECT_MANAGER:
    toAddrs.append(unscrambleEmailAddress(PROJECT_EMAIL_ADDRS[project]))

  subject = project + " build problem when running '" + cmd +"'"

  emailMsg  = "'" + cmd + "' from directory " + curDir + " failed.\n\n"
  emailMsg += "'" + cmd + "' messages are:\n" 
  emailMsg += cmdMsgs
  sendEmail(toAddrs,subject,emailMsg)
  writeLogMessage( "  email sent regarding "+project+" running '"+cmd+"'" )

#------------------------------------------------------------------------
# Send email 
#------------------------------------------------------------------------
def sendEmail(toAddrs,subject,message):

  sender = unscrambleEmailAddress(SENDER_EMAIL_ADDR)  
  msgWHeader = ("From: %s\r\nTo: %s\r\nSubject: %s\r\n\r\n"
       % (sender, ", ".join(toAddrs), subject))
  msgWHeader += message
  
  # Get smpt server password
  if os.path.isfile(SMTP_PASSWORD_FILENAME) :
    pwFilePtr = open(SMTP_PASSWORD_FILENAME,'r')
    smtppass  = pwFilePtr.read().strip()
    pwFilePtr.close()
  else :
    writeLogMessage( "Failure reading pwFileName=" + SMTP_PASSWORD_FILENAME )
    print cmdMsgs
    sys.exit(1)
    
  session = smtplib.SMTP(SMTP_SERVER_NAME,SMTP_SERVER_PORT)
  #session.set_debuglevel(1)
  if SMTP_SSL_SERVER==1 :
    session.ehlo('x')
    session.starttls()
    session.ehlo('x')  
  session.login(unscrambleEmailAddress(SMTP_USER_NAME),smtppass)

  rc = session.sendmail(sender,toAddrs,msgWHeader)
  if rc!={} :
    writeLogMessage( 'session.sendmail rc='  )
    writeLogMessage( rc )
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
  if ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS.has_key(project) : 
    if buildStep in ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS[project] :
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
    sendEmailCmdMsgs(project,rc[1],svnCmd)
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
    sendEmailCmdMsgs(p,error_msg,configCmd)
    continue

  #---------------------------------------------------------------------
  # Run make part of buid
  #---------------------------------------------------------------------
  writeLogMessage( '  make' )
  rc=commands.getstatusoutput('make')
  
  # Check if make worked
  if rc[0] != 0 :
    sendEmailCmdMsgs(p,rc[1],'make')
    continue

  #---------------------------------------------------------------------
  # Run 'make test' part of buid
  #---------------------------------------------------------------------
  writeLogMessage( '  make test' )
  rc=commands.getstatusoutput('make test')
  
  # Check if 'make test' worked
  if didTestFail(rc,p,"make test") :
    sendEmailCmdMsgs(p,rc[1],"make test")
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
      sendEmailCmdMsgs(p,rc[1],unitTestCmd)
      continue

  # For testing purposes only do first successful project
  #break


writeLogMessage( "nightlyBuild.py Finished" )

sys.exit(0)


# START KIPP
#----------------------------------------------------------------------
# CONFIG FILE PATH: 
#   path to the config file for the build
#   done. If the directory does not exist, it will be created.
#   this should have all of the user specific data
#   it should have values for
#   NIGHTLY_BUILD_ROOT
#   SMTP_SERVER_NAME
#   SMTP_SERVER_PORT 
#   SMTP_SSL_SERVER 
#   SMTP_USER_NAME
#   SMTP_PASSWORD_FILENAME = '/home/jp/bin/smtpPwFile'
#   SENDER_EMAIL_ADDR='jpfasano _AT_ verizon _DOT_ net'
#   MY_EMAIL_ADDR='jpfasano _AT_ us _DOT_ ibm _DOT_ com'
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
  #writeLogMessage( "Failure reading pwFileName=" + CONFIG_FILENAME )
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
#   SMTP_SERVER_NAME
#   SMTP_SERVER_PORT 
#   SMTP_SSL_SERVER 
#   SMTP_USER_NAME
#   SMTP_PASSWORD_FILENAME 
#   SENDER_EMAIL_ADDR
#   MY_EMAIL_ADDR
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
  #writeLogMessage( "Failure reading pwFileName=" + CONFIG_FILENAME )
  #print cmdMsgs
  sys.exit( 1)
sys.exit( 0)

# END KIPP
