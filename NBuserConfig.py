#! /usr/bin/env python

import sys

#from socket import gethostname

execfile('NBuserParametersDefault.py')

#the following two should go away when newNightlyBuild.py becomes the default

#----------------------------------------------------------------------
# For every project, indicate which svn versions are to be used.
# Supported versions are: trunk & latestStable
#----------------------------------------------------------------------
#PROJECT_VERSIONS = ['trunk','latestStable']

#----------------------------------------------------------------------
# For every project version, indicate all the ways the code is to 
# be built.
# Presently, NoThirdParty is not yet working
#----------------------------------------------------------------------
##BUILD_TYPES = [\
##              ['Default','ThirdParty'   ]\
##              ,['Debug',  'ThirdParty'   ]\
##              ,['Debug',  'NoThirdParty' ]\
##              ]

# NEW WAY to read user parameters:
execfile('NBuserParameters.py')

