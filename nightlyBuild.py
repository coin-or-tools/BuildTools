#!/usr/bin/env python

#------------------------------------------------------------------------
# This file is distributed under the Common Public License.
# It is part of the BuildTools project in COIN-OR (www.coin-or.org)
#------------------------------------------------------------------------

import os
import sys
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
#   -Clean up the kludge that tests if "make test" and 'unitTest' were
#    successfull
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
#  Get the data directories if they don't already exist
#------------------------------------------------------------------------
dataBaseDir=os.path.join(NIGHTLY_BUILD_ROOT_DIR,'Data')
if not os.path.isdir(dataBaseDir) :
  os.makedirs(dataBaseDir)
dataDirs=['Netlib','miplib3']
for d in dataDirs :
  dataDir=os.path.join(dataBaseDir,d)
  if not os.path.isdir(dataDir) :
    svnCmd=os.path.join( SVNPATH_PREFIX,'svn') + ' checkout https://projects.coin-or.org/svn/Data/releases/1.0.0/'+d+' '+d
    if NBsvnCommand.run(svnCmd,dataBaseDir,'Data')!='OK' :
      sys.exit(1)
    result=NBosCommand.run('find '+d+' -name \*.gz -print | xargs gzip -d')
netlibDir=os.path.join(dataBaseDir,'Netlib')
miplib3Dir=os.path.join(dataBaseDir,'miplib3')

#------------------------------------------------------------------------
# Loop once for each project (get code, compile & link, and test).
#------------------------------------------------------------------------
configuration={}
configuration['rootDir']=NIGHTLY_BUILD_ROOT_DIR
#for p,buildConfigs in NBprojectConfig.BUILDS.iteritems():
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
    if 'OptLevel' not in bc :
      print 'Error. BUILDS does not contain OptLevel'
      print '       Project is '+p
      print '       BuildConfig is '+str(bc)
      sys.exit(1)
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

