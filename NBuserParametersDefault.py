#----------------------------------------------------------------------
# This file is a template for a user-given parameter file.
# It contains variables that the person running this script need to set or modify.
#----------------------------------------------------------------------

#----------------------------------------------------------------------
# NIGHTLY_BUILD_ROOT_DIR: 
#   directory where code will be checked out and builds
#   done. If the directory does not exist, it will be created.
#----------------------------------------------------------------------
NIGHTLY_BUILD_ROOT_DIR = 'xxx'

#----------------------------------------------------------------------
# List of Projects to be processed by script
#----------------------------------------------------------------------
PROJECTS = ['CoinUtils','DyLP','Clp','SYMPHONY','Vol','Osi','Cgl','Cbc','Ipopt','Bonmin','FlopC++','OS']



#---------------------------------------------------
#  Not sure what file this belongs in.
#  This data structure is intended to describe how each COIN project
#  should be built.
#---------------------------------------------------
BUILDS = {
   #'DefaultProject'   : 
   #  [ 
   #    { 'SvnVersion': 'trunk',        'OptLevel': 'Default', 'ThirdParty':'Yes' }, 
   #    { 'SvnVersion': 'latestStable', 'OptLevel': 'Debug',   'ThirdParty':'No'  } 
   #  ],
   'CoinUtils' : 
     [
       { 'SvnVersion': 'trunk',         'OptLevel': 'Default', 'ThirdParty': 'No' } 
     #,{ 'SvnVersion': 'trunk',         'OptLevel': 'Debug',   'ThirdParty': 'No' } 
     #,{ 'SvnVersion': 'latestStable',  'OptLevel': 'Default', 'ThirdParty': 'No' } 
      ,{ 'SvnVersion': 'latestStable',  'OptLevel': 'Debug',   'ThirdParty': 'No' } 
     ],
   'DyLP' : 
     [ 
       { 'Reference' : 'CoinUtils' }, 
     ],
   'Clp' : 
     [ 
       { 'Reference' : 'CoinUtils' }, 
     ],
   'SYMPHONY' : 
     [ 
       { 'Reference' : 'CoinUtils' }, 
     ],
   'Vol' : 
     [ 
       { 'Reference' : 'CoinUtils' }, 
     ],
   'Osi' : 
     [ 
       { 'Reference' : 'CoinUtils' }, 
     ],
   'Cgl' : 
     [ 
       { 'Reference' : 'CoinUtils' }, 
     ],
   'Cbc' : 
     [ 
       { 'Reference' : 'CoinUtils' }, 
           
            
       # And build a parallel version with Third Party
       { 
         'SvnVersion': 'releases/1.2.0', 
         'OptLevel': 'Default', 
         'ThirdParty': 'Yes', 
         'AdditionConfigOptions': '--enable-cbc-parallel' 
       }
     ],
   'FlopC++' : 
     [ 
       { 'Reference' : 'CoinUtils' }, 
     ],
   'Ipopt' : 
     [ 
       { 'SvnVersion': 'trunk', 'OptLevel': 'Default', 'ThirdParty':'Yes' }, 
     ],
   'Bonmin' : 
     [ 
       { 'Reference' : 'Ipopt' }, 
     ],
   'OS' :
     [ 
       { 'Reference' : 'Ipopt' }, 
       { 
         'SvnVersion': 'trunk', 
         'OptLevel': 'Default', 
         'ThirdParty': 'No', 
         'SkipProjects': ('Ipopt') } 
     ]
  }





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
LOGPRINT = 1
LOGFILE = ''

#----------------------------------------------------------------------
# Values for sending mail:
#  EMAIL_STOREFILE: If set, then e-mails are not send but stored in a file.
#                   The filename is relative to NIGHTLY_BUILD_ROOT_DIR.
#                   If set, then no values for the SMTP_ fields need to be given.
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
EMAIL_STOREFILE = ''

SMTP_SERVER_NAME = 'xxx.smtp.server.name'
SMTP_SERVER_PORT = 25
SMTP_SSL_SERVER = 0
SMTP_USER_NAME = 'xxxx'
SMTP_PASSWORD_FILENAME = '/xxx/yyy/smtpPassWordFile'
SENDER_EMAIL_ADDR='xxx _AT_ yyyy _DOT_ edu'
MY_EMAIL_ADDR = SENDER_EMAIL_ADDR

SEND_MAIL_TO_PROJECT_MANAGER = 0

#----------------------------------------------------------------------
#On some systems the user might want to set extra options for the
#configure script like compilers...
#----------------------------------------------------------------------

CONFIGURE_FLAGS = ''
