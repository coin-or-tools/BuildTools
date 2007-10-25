#! /usr/bin/env python

import sys

from socket import gethostname

execfile('NBuserParametersDefault.py')

#----------------------------------------------------------------------
# List of Projects to be processed by script
#----------------------------------------------------------------------
PROJECTS = ['CoinUtils','DyLP','Clp','SYMPHONY','Vol','Osi','Cgl','Cbc',\
            'Ipopt','Bonmin','FlopC++','OS']


#----------------------------------------------------------------------
# For every project, indicate which svn versions are to be used.
# Supported versions are: trunk & latestStable
#----------------------------------------------------------------------
PROJECT_VERSIONS = ['trunk','latestStable']

#----------------------------------------------------------------------
# For every project version, indicate all the ways the code is to 
# be built.
# Presently, NoThirdParty is not yet working
#----------------------------------------------------------------------
BUILD_TYPES = [\
              ['Default','ThirdParty'   ]\
              ,['Debug',  'ThirdParty'   ]\
              ,['Debug',  'NoThirdParty' ]\
              ]

# OLD WAY to read user parameters: 

#sys.path.append('/Users/kmartin/Documents/files')
import userParameters

NIGHTLY_BUILD_ROOT_DIR = userParameters.data['NIGHTLY_BUILD_ROOT_DIR']
SMTP_SERVER_NAME = userParameters.data['SMTP_SERVER_NAME']
SMTP_SERVER_PORT = userParameters.data['SMTP_SERVER_PORT']
SMTP_SSL_SERVER = userParameters.data['SMTP_SSL_SERVER']
SMTP_USER_NAME = userParameters.data['SMTP_USER_NAME']
SMTP_PASSWORD_FILENAME = userParameters.data['SMTP_PASSWORD_FILENAME']
SENDER_EMAIL_ADDR = userParameters.data['SENDER_EMAIL_ADDR']
MY_EMAIL_ADDR =  userParameters.data['MY_EMAIL_ADDR']
SEND_MAIL_TO_PROJECT_MANAGER = userParameters.data['SEND_MAIL_TO_PROJECT_MANAGER']
STORE_EMAIL = userParameters.data['STORE_EMAIL']
SVNPATH_PREFIX = userParameters.data['SVNPATH_PREFIX']
DOWNLOAD_3RD_PARTY = userParameters.data['DOWNLOAD_3RD_PARTY'] 
CONFIGURE_FLAGS = userParameters.data['CONFIGURE_FLAGS'] 
LOGFILE = userParameters.data['LOGFILE'] 
LOGPRINT = userParameters.data['LOGPRINT'] 

# NEW WAY to read user parameters:
#execfile('NBuserParameters.py')
