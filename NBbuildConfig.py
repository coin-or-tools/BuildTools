#! /usr/bin/env python

import os
import sys

import NBlogMessages
import NBemail
import NBosCommand
import NBsvnCommand
import NBcheckResult

#---------------------------------------------------------------------
# Keep history so same project is not repeatedly getting code from
# subversion repository.
#---------------------------------------------------------------------
SVN_HISTORY = []
THIRD_PARTY_HISTORY = []

#------------------------------------------------------------------------
#  Given a configuration, build and test it.
#
#  configuration['project']= name of project.
#   examples: "Clp", "Ipopt"
#
#  configuration['rootDir']= root directory of nightlyBuild.
#   This is where the project will be checked out from svn, and
#   where the code will be compiled.  This directory must already
#   exist.  If the testing requires, it needs to contain Netlib & miplib3
#
#  configuration['svnVersion']= svn version to be built.
#   Examples are: "trunk", "stable/3.2", "releases/3.3.3"
#
#  configuration['noThirdParty']=True or False (optional). If False 
#   then 3rd party code will be used. If not specified then 3rd part
#   code will be skipped.
#
#  configuration['configOptions']: Parameters to be passed to configure.
#   The -C option and the options for skipping 3rd party code do not
#   need to be specified.  These will be generated by this function.
#   There are two types of configOptions to be specified. 
#  configuration['configOptions']['unique']= These are options that
#   distinguish different build configurations.  These options are used
#   to generate the vpath directory name where the code will be built.
#   Examples are: "", "--enable-debug" "--enable-parrallel"
#  configuration['configOptions']['invariant']= These are options that
#   that are the same for every build configuration so they don't need
#   to be part of the vpath directory name.
#   Example: 'CXX=g++ -m64 LDFLAGS=-lstdc++'
#
#  configuration['SkipProjects']= List of COIN projects to skip (exclude)
#    from the build.
#    examples: "Ipopt", "Ipopt DyLP"
#
#  configuration['checkMakeTest']= function to be called to determine
#    if "make test" ran correctly
#
#  configuration['unitTest']= undefined or dictionary D where
#    D['path']= relataive path were unitTest is to be run from.
#    D['command']= command to be issued to run unitTest
#    d['checkUnitTest']= function to be called to determine if unitTest
#       ran correctly.
#------------------------------------------------------------------------
def run(configuration) :
  NBlogMessages.writeMessage( configuration['project'] )

  # Create svn checkout target directory name
  svnVersionFlattened=configuration['svnVersion'].replace('/','-')

  #---------------------------------------------------------------------
  # svn checkout or update the project
  #---------------------------------------------------------------------
  projectBaseDir=os.path.join(configuration['rootDir'],configuration['project'])
  projectCheckOutDir=os.path.join(projectBaseDir,svnVersionFlattened)

  # Don't get source from subversion if previously done
  if projectCheckOutDir not in SVN_HISTORY :
    if not os.path.isdir(projectBaseDir) :
      os.makedirs(projectBaseDir)
    if not os.path.isdir(projectCheckOutDir) :
      svnCmd='svn ' +\
           'checkout ' +\
           'https://projects.coin-or.org/svn/'+configuration['project']+'/'+configuration['svnVersion']+\
           ' '+svnVersionFlattened
      if NBsvnCommand.run(svnCmd,projectBaseDir,configuration['project'])!='OK' :
        return
    else :
      svnCmd='svn update'
      if NBsvnCommand.run(svnCmd,projectCheckOutDir,configuration['project'])!='OK' :
        return
    SVN_HISTORY.append(projectCheckOutDir)
  else :
    NBlogMessages.writeMessage('  Skipping an "svn update"')

  #---------------------------------------------------------------------
  # If there are third party apps, then get these apps
  #---------------------------------------------------------------------
  if 'noThirdParty' in configuration :
    if not configuration['noThirdParty'] :
      thirdPartyBaseDir=os.path.join(projectCheckOutDir,'ThirdParty')
      if os.path.isdir(thirdPartyBaseDir) :
        if thirdPartyBaseDir not in THIRD_PARTY_HISTORY :
          THIRD_PARTY_HISTORY.append(thirdPartyBaseDir)
          thirdPartyDirs = os.listdir(thirdPartyBaseDir)
          for d in thirdPartyDirs :
            thirdPartyDir=os.path.join(thirdPartyBaseDir,d)
            install3rdPartyCmd=os.path.join(".","get."+d)
            os.chdir(thirdPartyDir)
            # If the install command has been updated since the last
            # install, then do a new install
            if os.path.isfile('NBinstalldone') :
              if NBosCommand.newer(install3rdPartyCmd,'NBinstalldone') :
                os.remove('NBinstalldone')
            if not os.path.isfile('NBinstalldone') :
              if os.path.isfile(install3rdPartyCmd) :
                NBlogMessages.writeMessage('  '+install3rdPartyCmd)
                NBosCommand.run(install3rdPartyCmd)
                f=open('NBinstalldone','w')
                f.close()
            else :
              NBlogMessages.writeMessage('  skipped a new download of '+d)
        else :
          NBlogMessages.writeMessage('  Skipped a new download into '+thirdPartyBaseDir)
    
  #---------------------------------------------------------------------
  # Source is now available, so now it is time to run config
  #---------------------------------------------------------------------
  skipOptions=''
  vpathDir=''

  if 'SkipProjects' in configuration :
    skipOptions+=configuration['SkipProjects']

  # If needed create option for skipping 3rd party code
  needSkip3PartySkipOptions=False
  if 'noThirdParty' not in configuration : 
    needSkip3PartySkipOptions=True
  elif configuration['noThirdParty'] :
    needSkip3PartySkipOptions=True
    vpathDir='-NoThirdParty'
  if needSkip3PartySkipOptions :
    thirdPartyBaseDir=os.path.join(projectCheckOutDir,'ThirdParty')
    if os.path.isdir(thirdPartyBaseDir) :
      thirdPartyDirs = os.listdir(thirdPartyBaseDir)
      for d in thirdPartyDirs :
        skipOptions+=' ThirdParty/'+d

  if skipOptions!='' :
    skipOptions=' COIN_SKIP_PROJECTS="'+skipOptions+'"'

  # Determine the build directory, and make sure it exists   
  vpathDir=svnVersionFlattened+\
          configuration['configOptions']['unique']+\
          vpathDir
  vpathDir=vpathDir.replace(' ','')
  vpathDir=vpathDir.replace('"','')
  vpathDir=vpathDir.replace("'",'')
  vpathDir=vpathDir.replace('--enable','')
  if vpathDir==svnVersionFlattened : vpathDir+='-default'
  
  fullVpathDir = os.path.join(projectBaseDir,vpathDir)
  if not os.path.isdir(fullVpathDir) : 
    os.makedirs(fullVpathDir)
  os.chdir(fullVpathDir)
  NBlogMessages.writeMessage('  Current directory: '+fullVpathDir)

  # Assemble all config options together and create config command
  configOptions ="-C "+configuration['configOptions']['unique']
  configOptions+=configuration['configOptions']['unique']
  configOptions+=configuration['configOptions']['invariant']
  configOptions+=skipOptions
  configCmd = os.path.join(projectCheckOutDir,"configure "+configOptions)



  # If config was previously run, then no need to run again.
  if NBcheckResult.didConfigRunOK() :
    NBlogMessages.writeMessage("  '"+configCmd+"' previously ran. Not rerunning")
  else :
    NBlogMessages.writeMessage("  "+configCmd)

    # Finally run config
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
        NBemail.sendCmdMsgs(configuration['project'],error_msg,configCmd)
        return

  #---------------------------------------------------------------------
  # Run make part of build
  #---------------------------------------------------------------------
  NBlogMessages.writeMessage( '  make' )
  result=NBosCommand.run('make')
      
  # Check if make worked
  if result['returnCode'] != 0 :
    NBemail.sendCmdMsgs(configuration['project'],result,'make')
    return

  #---------------------------------------------------------------------
  # Run 'make test' part of build
  #---------------------------------------------------------------------
  NBlogMessages.writeMessage( '  make test' )
  result=NBosCommand.run('make test')
      
  # Check if 'make test' worked
  didMakeTestFail=configuration['checkMakeTest'](result,configuration['project'],"make test")
  if didMakeTestFail :
    result['make test']=didMakeTestFail
    NBemail.sendCmdMsgs(configuration['project'],result,"make test")
    return

  #---------------------------------------------------------------------
  # Run unitTest if available and different from 'make test'
  #---------------------------------------------------------------------
  if "unitTest" in configuration :
    unitTestRelPath=configuration['unitTest']['path']
    unitTestPath = os.path.join(fullVpathDir,unitTestRelPath)
    os.chdir(unitTestPath)
    NBlogMessages.writeMessage('  Current directory: '+unitTestPath)

    unitTestCmdTemplate=configuration['unitTest']['command']

    dataBaseDir=os.path.join(configuration['rootDir'],'Data')
    netlibDir=os.path.join(dataBaseDir,'Netlib')
    miplib3Dir=os.path.join(dataBaseDir,'miplib3')

    unitTestCmd=unitTestCmdTemplate.replace('_NETLIBDIR_',netlibDir)
    unitTestCmd=unitTestCmd.replace('_MIPLIB3DIR_',miplib3Dir)

    NBlogMessages.writeMessage( '  '+unitTestCmd )
    result=NBosCommand.run(unitTestCmd)
      
    didUnitTestFail=configuration['unitTest']['checkUnitTest'](result,configuration['project'],unitTestCmdTemplate)
    if didUnitTestFail :
      result['unitTest']=didUnitTestFail
      NBemail.sendCmdMsgs(p,result,unitTestCmd)
      return

