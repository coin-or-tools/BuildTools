#------------------------------------------------------------------------
# This file is distributed under the Common Public License.
# It is part of the BuildTools project in COIN-OR (www.coin-or.org)
#------------------------------------------------------------------------

#----------------------------------------------------------------------
# This file is a template for a user-given parameter file.
# It contains variables that the person running this script need to set or modify.
#----------------------------------------------------------------------

#----------------------------------------------------------------------
# NIGHTLY_BUILD_ROOT_DIR: 
#   directory where code will be checked out and builds
#   done. If the directory does not exist, it will be created.
#
#   This should be the full path, not a path relative to the
#   nightlyBuild script.
#
#   examples for both unix and windows:
#      NIGHTLY_BUILD_ROOT_DIR = '/home/userid/nbBuildDir'
#      NIGHTLY_BUILD_ROOT_DIR = r'c:\nbBuildDir'
#----------------------------------------------------------------------
NIGHTLY_BUILD_ROOT_DIR = '/xxx'

#----------------------------------------------------------------------
# List of Projects to be processed by script
#----------------------------------------------------------------------
PROJECTS = ['CoinUtils','Clp','Osi','DyLP','SYMPHONY','Vol','Cgl','Cbc','Smi','FlopC++','Ipopt','Bonmin','OS','CppAD']

#----------------------------------------------------------------------
#  Define how a COIN-OR project is to be built and tested.
#  A project can be built multiple times in different ways.
#
#  SvnVersion: Specifies where in subversion the source should be obtained.
#   Examples: 'trunk', 'latestStable', 'releases/1.2.0'
#
#  OptLevel: 'Default' or 'Debug'. Specifies if "./configure" needs
#   additional parameters to build with debug.  The default is supposed
#   to be an optimized build.
#
#  ThirdParty: 'Yes' or 'No'.  Some projects provide scripts for downloading
#   third party code. If 'Yes' then these scripts will be run. If 'No'
#   then the options for skipping the use of third party codes are
#   used when running "./configure".
#
#  'AdditionConfigOptions': This provides the ability to specify an
#    additional './configure' option to be applied to this specific build.
#    CONFIGURE_FLAGS can be set if one wants to specify addtional configure
#    options to all builds.
#    Example: '--enable-cbc-parallel'
#
#  'Reference': This specifies that the build is to be done in the way
#    of the referenced name.
#    Example: 'CoinUtils'
#    The example indicates that the build configurations specified
#    for CoinUtils are to be used for building.
#
#----------------------------------------------------------------------
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
     #,{ 'SvnVersion': 'latestStable',  'OptLevel': 'Debug',   'ThirdParty': 'No' } 
     #,{ 'SvnVersion': 'latestRelease', 'OptLevel': 'Default', 'ThirdParty': 'No' }  
     #,{ 'SvnVersion': 'latestRelease', 'OptLevel': 'Debug', 'ThirdParty': 'No' } 
     ],
   'Osi' : 
     [ 
       { 'Reference' : 'CoinUtils' }
     ],
   'Clp' : 
     [ 
       { 'Reference' : 'CoinUtils' }
     ],
   'DyLP' : 
     [ 
       { 'Reference' : 'CoinUtils' }
     ],
   'SYMPHONY' : 
     [ 
       { 'Reference' : 'CoinUtils' }
     ],
   'Vol' : 
     [ 
       { 'Reference' : 'CoinUtils' }
     ],
   'Cgl' : 
     [ 
       { 'Reference' : 'CoinUtils' }
     ],
   'Cbc' : 
     [ 
       { 'Reference' : 'CoinUtils' } 

       # And build a parallel version with Third Party
     #,{ 
     #   'SvnVersion': 'latestStable', 
     #   'OptLevel': 'Default', 
     #   'ThirdParty': 'Yes', 
     #   'AdditionalConfigOptions': '--enable-cbc-parallel' 
     # }
     ],
   'Smi' : 
     [ 
       { 'Reference' : 'CoinUtils' } 
     ],
   'FlopC++' : 
     [ 
       { 'Reference' : 'CoinUtils' }
     ],
   'Ipopt' : 
     [ 
       { 'SvnVersion': 'trunk',        'OptLevel': 'Default', 'ThirdParty':'Yes' }
     #,{ 'SvnVersion': 'trunk',        'OptLevel': 'Debug',   'ThirdParty':'Yes' }
     #,{ 'SvnVersion': 'latestStable', 'OptLevel': 'Default', 'ThirdParty':'Yes' }
     #,{ 'SvnVersion': 'latestRelease','OptLevel': 'Default', 'ThirdParty':'Yes' }
     ],
   'Bonmin' : 
     [ 
       { 'Reference' : 'Ipopt' }
     ],
   'OS' :
     [ 
       { 'Reference' : 'Ipopt' } 
     #,{ 'SvnVersion': 'trunk',        'OptLevel': 'Default', 'ThirdParty': 'No', 'SkipProjects': ('Ipopt') } 
     #,{ 'SvnVersion': 'trunk',        'OptLevel': 'Debug',   'ThirdParty': 'No', 'SkipProjects': ('Ipopt') } 
     #,{ 'SvnVersion': 'latestStable', 'OptLevel': 'Default', 'ThirdParty': 'No', 'SkipProjects': ('Ipopt') } 
     #,{ 'SvnVersion': 'latestRelease','OptLevel': 'Default', 'ThirdParty': 'No', 'SkipProjects': ('Ipopt') } 
     ],
   'CppAD' : 
     [ 
       { 'SvnVersion': 'trunk',        'OptLevel': 'Default', 'ThirdParty': 'No', 'AdditionalConfigOptions':'--with-Example --with-TestMore' } 
     #,{ 'SvnVersion': 'trunk',        'OptLevel': 'Debug',   'ThirdParty': 'No', 'AdditionalConfigOptions':'--with-Example --with-TestMore' } 
     #,{ 'SvnVersion': 'latestStable', 'OptLevel': 'Default', 'ThirdParty': 'No', 'AdditionalConfigOptions':'--with-Example --with-TestMore' } 
     #,{ 'SvnVersion': 'latestRelease','OptLevel': 'Default', 'ThirdParty': 'No', 'AdditionalConfigOptions':'--with-Example --with-TestMore' } 
     ],
   'Smi' : 
     [ 
       { 'Reference' : 'CoinUtils' }
     ]
  }

#----------------------------------------------------------------------
#On some systems the user might want to set extra options for the
#configure script like compilers...
#example: CONFIGURE_FLAGS = 'CC="gcc -m32" CXX="g++ -m32" F77="gfortran -m32"'
#----------------------------------------------------------------------

CONFIGURE_FLAGS = ''


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
