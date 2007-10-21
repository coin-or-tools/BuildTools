#! /usr/bin/env python

from socket import gethostname

#----------------------------------------------------------------------
# This file contains variables that person running this scirpt
# might need to change. 
#----------------------------------------------------------------------



#----------------------------------------------------------------------
# NIGHTLY_BUILD_ROOT_DIR: 
#   directory where code will be checked out and builds
#   done. If the directory does not exist, it will be created.
#----------------------------------------------------------------------
NIGHTLY_BUILD_ROOT_DIR = 'xxx'
if gethostname()=='ubuntu' :
  NIGHTLY_BUILD_ROOT_DIR = '/home/jp/COIN'
elif gethostname()=='math01.watson.ibm.com' :
  NIGHTLY_BUILD_ROOT_DIR = '/u/jpfasano/COIN/nbTest'
elif gethostname()=='JPF4' :
  NIGHTLY_BUILD_ROOT_DIR = 'd:/nbTest'
elif gethostname()=='kmartin-maclt.local' :
  NIGHTLY_BUILD_ROOT_DIR = '/Users/kmartin/COIN'
  

#----------------------------------------------------------------------
# Define directory where svn is located.
# If svn is in the default path, then this can be set to an empty string
#----------------------------------------------------------------------
SVNPATH_PREFIX=''
if gethostname()=='math01.watson.ibm.com' :
  SVNPATH_PREFIX='/gsa/yktgsa/projects/o/oslos/local/bin'
elif gethostname()=='JPF4' :
  SVNPATH_PREFIX = ''
elif gethostname()=='kmartin-maclt.local' :
  SVNPATH_PREFIX='/usr/local/bin'
  


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
SMTP_SERVER_NAME = 'xxx.smtp.server.name'
SMTP_SERVER_PORT =25
SMTP_SSL_SERVER = 0
SMTP_USER_NAME = 'xxxx'
SMTP_PASSWORD_FILENAME = '/xxx/yyy/smtpPassWordFile'

SENDER_EMAIL_ADDR='xxx _AT_ yyyy _DOT_ edu'
MY_EMAIL_ADDR='xxx _AT_ yyyy _DOT_ edu'
SEND_MAIL_TO_PROJECT_MANAGER=0
if gethostname()=='ubuntu' or \
   gethostname()=='math01.watson.ibm.com' or\
   gethostname()=='JPF4' :
  #SMTP_SERVER_NAME = 'outgoing.verizon.net'
  #SMTP_SERVER_PORT = 25
  #SMTP_SSL_SERVER = 0
  #SMTP_USER_NAME = 'jpfasano'

  SMTP_SERVER_NAME = 'smtp.gmail.com'
  SMTP_SERVER_PORT = 587
  SMTP_SSL_SERVER = 1
  SMTP_USER_NAME = 'jpfasano _AT_ gmail _DOT_ com'
  if gethostname()=='ubuntu' :
    SMTP_PASSWORD_FILENAME = '/home/jp/bin/smtpPwFile'
  elif gethostname()=='math01.watson.ibm.com' :
    SMTP_PASSWORD_FILENAME = '/u/jpfasano/COIN/bin/smtpPwFile'
  else :
    SMTP_PASSWORD_FILENAME = 'c:\smtpPwFile.txt'

  SENDER_EMAIL_ADDR='jpfasano _AT_ verizon _DOT_ net'
  MY_EMAIL_ADDR='jpfasano _AT_ us _DOT_ ibm _DOT_ com'
  SEND_MAIL_TO_PROJECT_MANAGER=0
elif gethostname()=='kmartin-maclt.local' :
  SMTP_SERVER_NAME = 'gsbims.uchicago.edu'
  SMTP_SERVER_PORT =587
  SMTP_SSL_SERVER = 0
  SMTP_USER_NAME = 'kmartin'
  SMTP_PASSWORD_FILENAME = '/Users/kmartin/passwd'

  SENDER_EMAIL_ADDR='kipp _DOT_ martin _AT_ chicagogsb _DOT_ edu'
  MY_EMAIL_ADDR='kipp _DOT_ martin _AT_ chicagogsb _DOT_ edu'
  SEND_MAIL_TO_PROJECT_MANAGER=0


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
if gethostname()=='ubuntu' :
  DOWNLOAD_3RD_PARTY=1
elif gethostname()=='math01.watson.ibm.com' :
  DOWNLOAD_3RD_PARTY=1
elif gethostname()=='JPF4' :
  DOWNLOAD_3RD_PARTY=1


#----------------------------------------------------------------------
# List of Projects to be processed by script
#----------------------------------------------------------------------
PROJECTS = ['CoinUtils','DyLP','Clp','SYMPHONY','Vol','Osi','Cgl','Cbc',\
            'FlopC++','Ipopt','OS','CppAD']
PROJECTS =['CoinUtils']

#----------------------------------------------------------------------
# List of vpath directories and corresponding configure options
# Setup as a dictionary
#----------------------------------------------------------------------

VPATH_DIRS = ['vpath', 'vpath-no_third_party']
VPATH_CONFIG_ARGS = ['configure -C' ,\
                     'configure COIN_SKIP_PROJECTS="Ipopt ThirdParty/ASL ThirdParty/Blas ThirdParty/Glpk ThirdParty/HSL ThirdParty/Lapack ThirdParty/Mumps"']

# Perhaps use dictionaries
VPATH_BUILD = {'vpath': 'configure -C' ,\
               'vpath-no_third_party': 'configure COIN_SKIP_PROJECTS="Ipopt ThirdParty/ASL ThirdParty/Blas ThirdParty/Glpk ThirdParty/HSL ThirdParty/Lapack ThirdParty/Mumps"'}
