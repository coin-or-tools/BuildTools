#! /usr/bin/env python

import os
import sys
#import distutils.dir_util

import NBuserConfig
import NBprojectConfig
import NBlogMessages
import NBemail
import NBosCommand
import NBsvnCommand
import NBcheckResult

# TODO:
#   -Get some information about the platform and put this in email failure message.
#   -In userConfig allow one to optionally do a clean checkout and/or config
#   -Don't do build if 'svn update' doesn't change anything and prior test was OK.
#     (no need to re-run if nothing has changed since prior run)
#   -Skip make of project that depend on a project which make had been failing. (Similar for configure.)
#    But also tell project managers of skiped project that their project was skipped.
#   -Store output of get.XXX calls, make, make test, configures... in some files.
#   -Allow a fine configuration of which build tests to run per project.
#   -Move actual [get project, configure, make, tests] part into an extra file.


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
    if NBsvnCommand.run(svnCmd,dataBaseDir,'Data')!='OK' :
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
  # Loop once for each version of the project to be checked out.
  # The supported types are trunk & latestStable
  #---------------------------------------------------------------------
  projectVersions=[]
  if 'latestStable' in NBuserConfig.PROJECT_VERSIONS :
    lsv = NBsvnCommand.latestStableVersion(p)
    projectVersions.append(['stable'+lsv,'stable/'+lsv])
  if 'trunk' in NBuserConfig.PROJECT_VERSIONS :
    projectVersions.append(['trunk','trunk'])
  for projectVersion in projectVersions :
    #---------------------------------------------------------------------
    # svn checkout or update the project
    #---------------------------------------------------------------------
    projectBaseDir=os.path.join(NBuserConfig.NIGHTLY_BUILD_ROOT_DIR,p)
    projectCheckOutDir=os.path.join(projectBaseDir,projectVersion[0])
    if not os.path.isdir(projectBaseDir) :
      os.makedirs(projectBaseDir)
    if not os.path.isdir(projectCheckOutDir) :
      svnCmd=os.path.join(NBuserConfig.SVNPATH_PREFIX,'svn') +\
             ' checkout https://projects.coin-or.org/svn/'+p+'/'+projectVersion[1]+' '+projectVersion[0]
      if NBsvnCommand.run(svnCmd,projectBaseDir,p)!='OK' :
        continue
    else :
      svnCmd=os.path.join(NBuserConfig.SVNPATH_PREFIX,'svn') + ' update'
      if NBsvnCommand.run(svnCmd,projectCheckOutDir,p)!='OK' :
        continue

    #---------------------------------------------------------------------
    # If there are third party apps, then get these apps
    #---------------------------------------------------------------------
    if NBuserConfig.DOWNLOAD_3RD_PARTY :
      thirdPartyBaseDir=os.path.join(projectCheckOutDir,'ThirdParty')
      if os.path.isdir(thirdPartyBaseDir) :
        thirdPartyDirs = os.listdir(thirdPartyBaseDir)
        for d in thirdPartyDirs :
          thirdPartyDir=os.path.join(thirdPartyBaseDir,d)
          install3rdPartyCmd=os.path.join(".","get."+d)
          os.chdir(thirdPartyDir)
          # If the install command has been updated since the last
          # install, then do a new install
          if NBosCommand.newer(install3rdPartyCmd,'NBinstalldone') :
            if os.path.isfile('NBinstalldone') :
              os.remove('NBinstalldone')
          if not os.path.isfile('NBinstalldone') :
            if os.path.isfile(install3rdPartyCmd) :
              NBlogMessages.writeMessage('  '+install3rdPartyCmd)
              NBosCommand.run(install3rdPartyCmd)
              f=open('NBinstalldone','w')
              f.close()
          else :
            NBlogMessages.writeMessage('  skipped anew download of '+d)
    
    #---------------------------------------------------------------------
    # Loop once for each type of build to be done.
    # Debug, use third party code, ...
    # vpath and options to configure must be set for the buildType
    #---------------------------------------------------------------------
    buildtypes=NBprojectConfig.PROJECT_CONFIG_LINES[p]

    print buildtypes
    
    for buildType, configLine in buildtypes.iteritems() :
    
      #---------------------------------------------------------------------
      # Setup the directory where the build will be done and the configure
      # command options
      #---------------------------------------------------------------------
      vpathDir=projectVersion[0]+'-'+buildType
      configOptions='-C '+NBuserConfig.CONFIGURE_FLAGS+' '+configLine

      print 'HERE ARE THE CONFIG OPTIONS SO FAR'
      print configOptions


#      if "ThirdParty" in buildType :
#        vpathDir += "ThirdParty"
#      else :
#        vpathDir += "NoThirdParty"
#        thirdPartyBaseDir=os.path.join(projectCheckOutDir,'ThirdParty')
#        if os.path.isdir(thirdPartyBaseDir) :
#          thirdPartyDirs = os.listdir(thirdPartyBaseDir)
#          skipOptions=''
#          for d in thirdPartyDirs :
#            skipOptions+=' ThirdParty/'+d
#          configOptions+=' COIN_SKIP_PROJECTS="'+skipOptions+'"'

# Added by Kipp -- Sunday, Oct 21
      print buildType
      print configLine
      if "NoThirdParty" in buildType :
        skipOptions=''
        thirdPartyBaseDir=os.path.join(projectCheckOutDir,'ThirdParty')
        if os.path.isdir(thirdPartyBaseDir) :
          thirdPartyDirs = os.listdir(thirdPartyBaseDir)
          for d in thirdPartyDirs :
            skipOptions+=' ThirdParty/'+d
        configOptions+=' COIN_SKIP_PROJECTS="'+skipOptions+'"'
# End Kipp


      fullVpathDir = os.path.join(projectBaseDir,vpathDir)
      #TODO: if (MAKE_CLEAN) : distutils.dir_util.remove_tree(fullVpathDir)
      if not os.path.isdir(fullVpathDir) : os.mkdir(fullVpathDir)
      NBlogMessages.writeMessage("  build "+buildType+" in "+fullVpathDir)

      #---------------------------------------------------------------------
      # Run configure part of build (only if config has not previously 
      # ran successfully).
      #---------------------------------------------------------------------
      os.chdir(fullVpathDir)
      configCmd = os.path.join('.',projectCheckOutDir,"configure "+configOptions)
      if NBcheckResult.didConfigRunOK() :
        NBlogMessages.writeMessage("  '"+configCmd+"' previously ran. Not rerunning")
      else :
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
      didMakeTestFail=NBcheckResult.didTestFail(result,p,"make test")
      if didMakeTestFail :
        result['make test']=didMakeTestFail
        NBemail.sendCmdMsgs(p,result,"make test")
        continue

      #---------------------------------------------------------------------
      # Run unitTest if available and different from 'make test'
      #---------------------------------------------------------------------
      if NBprojectConfig.UNITTEST_CMD.has_key(p) :
        unitTestPath = os.path.join(fullVpathDir,NBprojectConfig.UNITTEST_DIR[p])
        os.chdir(unitTestPath)

        unitTestCmdTemplate=NBprojectConfig.UNITTEST_CMD[p]
        unitTestCmd=unitTestCmdTemplate.replace('_NETLIBDIR_',netlibDir)
        unitTestCmd=unitTestCmd.replace('_MIPLIB3DIR_',miplib3Dir)

        NBlogMessages.writeMessage( '  '+unitTestCmd )
        result=NBosCommand.run(unitTestCmd)
      
        didUnitTestFail=NBcheckResult.didTestFail(result,p,unitTestCmdTemplate)
        if didUnitTestFail :
          result['unitTest']=didUnitTestFail
          NBemail.sendCmdMsgs(p,result,unitTestCmd)
          continue

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
