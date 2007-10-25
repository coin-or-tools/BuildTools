#! /usr/bin/env python

import sys
#sys.path.append('/Users/kmartin/Documents/files')
import userParameters

from socket import gethostname

#----------------------------------------------------------------------
# NIGHTLY_BUILD_ROOT_DIR: 
#   directory where code will be checked out and builds
#   done. If the directory does not exist, it will be created.
#----------------------------------------------------------------------
NIGHTLY_BUILD_ROOT_DIR = 'xxx'


#----------------------------------------------------------------------
# LOGPRINT:
#   switch for logoutput to stdout. If set to 1 (default) log will go to
#   stdout, if set to 0, then not.
# LOGFILE: 
#   If not empty, then log messages will go to this file.
#   If LOGPRINT is 1, then log messages will go to stdout as well.
#   The LOGFILE will be used relative to the NIGHTLY_BUILD_ROOT_DIR, i.e.,
#   log will be written into NIGHTLY_BUILD_ROOT_DIR+'/'+LOGFILE
#----------------------------------------------------------------------

LOGPRINT='1'
LOGFILE=''
	
#----------------------------------------------------------------------
# Define directory where svn is located.
# If svn is in the default path, then this can be set to an empty string
#----------------------------------------------------------------------
SVNPATH_PREFIX=''


  


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
#  STORE_EMAIL: If set, then e-mails are not send but stored in a file.
#               The filename is relative to NIGHTLY_BUILD_ROOT_DIR.
#               If set, then no values for the SMTP_ fields need to be given.
#----------------------------------------------------------------------
SMTP_SERVER_NAME = 'xxx.smtp.server.name'
SMTP_SERVER_PORT =25
SMTP_SSL_SERVER = 0
SMTP_USER_NAME = 'xxxx'
SMTP_PASSWORD_FILENAME = '/xxx/yyy/smtpPassWordFile'

SENDER_EMAIL_ADDR='xxx _AT_ yyyy _DOT_ edu'
MY_EMAIL_ADDR='xxx _AT_ yyyy _DOT_ edu'
SEND_MAIL_TO_PROJECT_MANAGER=0

STORE_EMAIL = ''

#----------------------------------------------------------------------
# DOWNLOAD_3RD_PARTY: 0 or 1.
# Several COIN-OR projects provide scripts for downloading 3rd party
# code that the project will use if it is available.  Some of
# the this 3rd party code is distributed under various different
# licenses. A 1 indicates that the script will download 3rd party
# code if the COIN-OR project provides the script
# ThirdParty/xxx/get.xxx where xxx is the name of the third party code
#----------------------------------------------------------------------
DOWNLOAD_3RD_PARTY=0



#----------------------------------------------------------------------
#On some systems the user might want to set extra options for the
#configure script like compilers...
#----------------------------------------------------------------------
CONFIGURE_FLAGS = ''

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

BUILD_TYPES = [\
              ['Default',  'NoThirdParty' ]\
              ]               


#NEW PARAMETER SETTINGS:

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
