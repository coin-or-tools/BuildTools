#!/usr/bin/env python

#------------------------------------------------------------------------
# This file is distributed under the Common Public License.
# It is part of the BuildTools project in COIN-OR (www.coin-or.org)
#------------------------------------------------------------------------

import os
import sys
from socket import gethostname
import NBprojectConfig
import NBlogMessages
import NBemail
import NBosCommand
import NBsvnCommand
import NBcheckResult
import NBbuildConfig


execfile('NBuserParametersDefault.py')
execfile('NBuserParameters.py')





# TODO:
#   -In userConfig allow one to optionally do a clean checkout and/or config
#   -Reduce size of email messages.
#   -Get working on windows


#------------------------------------------------------------------------
#  Main Program Starts Here
#------------------------------------------------------------------------

#------------------------------------------------------------------------
#  If needed create the top level directory
#------------------------------------------------------------------------
if not os.path.isdir( NIGHTLY_BUILD_ROOT_DIR) :
  os.makedirs(NIGHTLY_BUILD_ROOT_DIR)
os.chdir( NIGHTLY_BUILD_ROOT_DIR)

#------------------------------------------------------------------------
#  If needed open the logfile
#------------------------------------------------------------------------

if len(LOGFILE) > 0 and not LOGFILE.isspace() :
  NBlogMessages.openLogFile()

#------------------------------------------------------------------------
#  Get the data directories if they don't already exist
#------------------------------------------------------------------------
dataBaseDir=os.path.join(NIGHTLY_BUILD_ROOT_DIR,'Data')
if not os.path.isdir(dataBaseDir) :
  os.makedirs(dataBaseDir)
dataDirs=['Netlib','miplib3','Sample']
for d in dataDirs :
  dataDir=os.path.join(dataBaseDir,d)
  if not os.path.isdir(dataDir) :
    svnCmd='svn checkout https://projects.coin-or.org/svn/Data/releases/1.0.4/'+d+' '+d
    svnResult=NBsvnCommand.run(svnCmd,dataBaseDir,'Data')
    if svnResult['returnCode'] != 0 :
      sys.exit(1)
    result=NBosCommand.run('find '+d+' -name \*.gz -print | xargs gzip -d')
netlibDir=os.path.join(dataBaseDir,'Netlib')
miplib3Dir=os.path.join(dataBaseDir,'miplib3')
sampleDir=os.path.join(dataBaseDir,'Sample')

#------------------------------------------------------------------------
# Define loop invariant configuration values
#------------------------------------------------------------------------
configuration={}
configuration['rootDir']=NIGHTLY_BUILD_ROOT_DIR
configurations = set("")

#------------------------------------------------------------------------
# Define how code is is to be built. Choices are:
# msSoln: use microsoft compiler with a solution (sln) file.
# unixConfig: use sequence "./configure", "make", "make test"
#------------------------------------------------------------------------
if sys.platform=='win32' :
  configuration['buildMethod']='msSln'
else :
  configuration['buildMethod']='unixConfig'

#------------------------------------------------------------------------
# Loop once for each project (get code, compile & link, and test).
#------------------------------------------------------------------------
for p in PROJECTS :

  configuration['project']=p

  #------------------------------------------------------------------------
  # Loop once for each build configuration of p
  #------------------------------------------------------------------------
  buildConfigs = BUILDS[p]
  for bc in buildConfigs:

    #--------------------------------------------------------------------
    # Does build reference another project's build configuration.
    # If yes, then build p as specified by the reference project.
    #--------------------------------------------------------------------
    if 'Reference' in bc :
      referencedConfigs = BUILDS[ bc['Reference'] ]
      for c in referencedConfigs :
        buildConfigs.append(c)
      continue

    #--------------------------------------------------------------------
    # Setup subversion verion
    #--------------------------------------------------------------------
    if 'SvnVersion' not in bc :
      print 'Error. BUILDS does not contain SvnVersion'
      print '       Project is '+p
      print '       BuildConfig is '+str(bc)
      sys.exit(1)
    if bc['SvnVersion']=='latestStable' :
      lsv=NBsvnCommand.latestStableVersion(p)
      if not lsv :
        print 'Error. BUILDS configured to use lastest stable svn version'
        print '       Project does not have a stable version'
        print '       Project is '+p
        print '       BuildConfig is '+str(bc)
        sys.exit(1)
      configuration['svnVersion']='stable/'+lsv
    elif bc['SvnVersion']=='latestRelease' :
      lrv=NBsvnCommand.latestReleaseVersion(p)
      if not lrv :
        print 'Error. BUILDS configured to use lastest release svn version'
        print '       Project does not have a release version'
        print '       Project is '+p
        print '       BuildConfig is '+str(bc)
        sys.exit(1)
      configuration['svnVersion']='releases/'+lrv
    else:
      configuration['svnVersion']=bc['SvnVersion']

    #--------------------------------------------------------------------
    # Make sure optlevel specified
    #--------------------------------------------------------------------
    if 'OptLevel' not in bc :
      print 'Error. BUILDS does not contain OptLevel'
      print '       Project is '+p
      print '       BuildConfig is '+str(bc)
      sys.exit(1)
    elif bc['OptLevel']!="Debug" and bc['OptLevel']!="Default" :
      print 'Error. BUILDS has unrecognized OptLevel'
      print '       Project is '+p
      print '       BuildConfig is '+str(bc)
      print '       Expected OptLevel: Debug or Default'
      sys.exit(1)

    #--------------------------------------------------------------------
    # Process Parameters that are used by unix configure style build
    #--------------------------------------------------------------------
    if configuration['buildMethod']=='unixConfig' :
      #--------------------------------------------------------------------
      # Doing a unix config type build.  Grab unix config parms
      #--------------------------------------------------------------------

      #--------------------------------------------------------------------
      # Setup usage of 3rd Party code
      #--------------------------------------------------------------------
      if 'noThirdParty' in configuration: configuration.pop('noThirdParty')
      if 'ThirdParty' in bc:
        if bc['ThirdParty'].lower()=='yes' :
          configuration['noThirdParty']=False
        else:
          configuration['noThirdParty']=True

      #--------------------------------------------------------------------
      # Set config options
      #--------------------------------------------------------------------
      configuration['configOptions']={}
      configuration['configOptions']['unique']=""
      configuration['configOptions']['invariant']=""

      if bc['OptLevel']=='Debug' :
        configuration['configOptions']['unique']+=" --enable-debug"
      if 'AdditionalConfigOptions' in bc :
        configuration['configOptions']['unique']+=" "+bc['AdditionalConfigOptions']

      configuration['configOptions']['invariant']+=" "+ CONFIGURE_FLAGS

      #--------------------------------------------------------------------
      # Deal with coin projects to be skipped by ./config
      #--------------------------------------------------------------------
      if 'SkipProjects' in configuration: configuration.pop('SkipProjects')
      if 'SkipProjects' in bc :
        configuration['SkipProjects']=bc['SkipProjects']
      
      #---------------------------------------------------------------------
      # Set up test commands
      #---------------------------------------------------------------------
      configuration['test']={}
      if NBprojectConfig.CFG_BLD_TEST.has_key(p) :
        configuration['test']=NBprojectConfig.CFG_BLD_TEST[p]
      else :
        # No test commands so remove from configuration
        configuration.pop('test')  


    if configuration['buildMethod']=='msSln' :
      #--------------------------------------------------------------------
      # Doing a microsoft solution  build.  Grap ms sln parms
      #--------------------------------------------------------------------

      #---------------------------------------------------------------------
      # Set up test executables
      #---------------------------------------------------------------------
      configuration['test']={}
      if NBprojectConfig.SLN_BLD_TEST.has_key(p) :
        configuration['test']=NBprojectConfig.SLN_BLD_TEST[p]
      else :
        # No test executables so remove from configuration
        configuration.pop('test')
        
      #---------------------------------------------------------------------
      # If solution file is not in standard place then specify it's location
      #---------------------------------------------------------------------
      configuration['slnFile']=''
      if NBprojectConfig.SLN_FILE.has_key(p) :
        configuration['slnFile']=NBprojectConfig.SLN_FILE[p]          
      else :
        configuration.pop('slnFile')

      #--------------------------------------------------------------------
      # Set msbuild configuration parm (Release or Debug)
      #--------------------------------------------------------------------
      #if bc['OptLevel']=='Debug' :
      #  configuration['msbuild']="Debug"
      #else :
      #  configuration['msbuild']="Release"
 
               
    #---------------------------------------------------------------------
    # Modify any executable commands to have location of data directories
    #---------------------------------------------------------------------
    if configuration.has_key('test') :
      for t in range( len(configuration['test']) ) :
        testCmd=configuration['test'][t]['cmd']
        testCmd=testCmd.replace('_NETLIBDIR_',netlibDir)
        testCmd=testCmd.replace('_MIPLIB3DIR_',miplib3Dir)
        testCmd=testCmd.replace('_SAMPLEDIR_',sampleDir)
        configuration['test'][t]['cmd']=testCmd

    #--------------------------------------------------
    # Build & Test the configuration, if not previously done
    #--------------------------------------------------
    if str(configuration) not in configurations :
      NBbuildConfig.run(configuration)
      configurations=configurations | set([str(configuration)])
    


NBlogMessages.writeMessage( "nightlyBuild.py Finished" )

# Email log messages to person running script
toAddrs = [NBemail.unscrambleAddress(MY_EMAIL_ADDR)]
subject = "NightlyBuild Log from "+gethostname()+" on "+sys.platform
NBemail.send(toAddrs,subject,NBlogMessages.getAllMessages())

#------------------------------------------------------------------------
#  If needed close the logfile
#------------------------------------------------------------------------

if len(LOGFILE) > 0 and not LOGFILE.isspace() :
  NBlogMessages.closeLogFile()

sys.exit(0)

