#!/usr/bin/env python

import os
import sys

import NBuserConfig
import NBprojectConfig
import NBlogMessages
import NBemail
import NBosCommand
import NBsvnCommand
import NBcheckResult
import NBbuildConfig

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
# Loop once for each project (get code, compile & link, and test).
#------------------------------------------------------------------------
configuration={}
configuration['rootDir']=NBuserConfig.NIGHTLY_BUILD_ROOT_DIR
#for p,buildConfigs in NBprojectConfig.BUILDS.iteritems():
for p in NBuserConfig.PROJECTS :

  configuration['project']=p

  #------------------------------------------------------------------------
  # Loop once for each build configuration of p
  #------------------------------------------------------------------------
  buildConfigs = NBprojectConfig.BUILDS[p]
  for bc in buildConfigs:

    #--------------------------------------------------------------------
    # Does build reference another project's build configuration.
    # If yes, then build p as specified by the reference project.
    #--------------------------------------------------------------------
    if 'Reference' in bc :
      referencedConfigs = NBprojectConfig.BUILDS[ bc['Reference'] ]
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
      configuration['svnVersion']='stable/'+NBsvnCommand.latestStableVersion(p)
    else:
      configuration['svnVersion']=bc['SvnVersion']

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
    configuration['configOptions']=""
    if 'OptLevel' not in bc :
      print 'Error. BUILDS does not contain OptLevel'
      print '       Project is '+p
      print '       BuildConfig is '+str(bc)
      sys.exit(1)
    if bc['OptLevel']=='Debug' :
      configuration['configOptions']+=" --enable-debug"
    if 'AdditionalConfigOptions' in bc :
      configuration['configOptions']+=" "+bc['AdditionalConfigOptios']

    configuration['configOptions']+=" "+NBuserConfig.CONFIGURE_FLAGS

    #--------------------------------------------------------------------
    # Deal with coin projects to be skipped by ./config
    #--------------------------------------------------------------------
    if 'SkipProjects' in configuration: configuration.pop('SkipProjects')
    if 'SkipProjects' in bc :
      configuration['SkipProjects']=bc['SkipProjects']

    #---------------------------------------------------------------------
    # Setup checkMakeTest
    #---------------------------------------------------------------------
    configuration['checkMakeTest']=NBcheckResult.didTestFail


    #---------------------------------------------------------------------
    # Set up unitTest
    #---------------------------------------------------------------------
    configuration['unitTest']={}
    if NBprojectConfig.UNITTEST_CMD.has_key(p) :

      unitTestCmdTemplate=NBprojectConfig.UNITTEST_CMD[p]
      unitTestCmd=unitTestCmdTemplate.replace('_NETLIBDIR_',netlibDir)
      unitTestCmd=unitTestCmd.replace('_MIPLIB3DIR_',miplib3Dir)

      configuration['unitTest']['command']=unitTestCmd
      configuration['unitTest']['checkUnitTest']=NBcheckResult.didTestFail
      configuration['unitTest']['path']=NBprojectConfig.UNITTEST_DIR[p]

    else :
      # No unitTest so remove from configuration
      configuration.pop('unitTest')

    #--------------------------------------------------
    # Build & Test the configuration
    #--------------------------------------------------
    NBbuildConfig.run(configuration)


NBlogMessages.writeMessage( "nightlyBuild.py Finished" )

sys.exit(0)

