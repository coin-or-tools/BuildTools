#! /usr/bin/env python

import os
import NBuserConfig

#----------------------------------------------------------------------
# This file defines variables which describe how the specific
# coin-or projects are to be build and tested. 
#----------------------------------------------------------------------

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS = {}
PROJECT_CONFIG_LINES = {}
UNITTEST_DIR = {}
UNITTEST_CMD = {}
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS = {} 
SKIP3RDPARTY_CONFIG_LINE = 'COIN_SKIP_PROJECTS="ThirdParty/ASL ThirdParty/Blas ThirdParty/Glpk ThirdParty/HSL ThirdParty/Lapack ThirdParty/Mumps"'
STANDARD_CONFIG_LINES = {}
SKIP3RDPARTY_CONFIG_LINES = {}

for buildType in NBuserConfig.BUILD_TYPES :
	if "Debug" in buildType :
		key = 'Debug'
		val = '--enable-debug'
	else :
		key = 'Default'
		val = ''

	if "ThirdParty" in buildType :
		STANDARD_CONFIG_LINES[key] = val
	else :
		key += "-no3rdParty"
		val += ' '+SKIP3RDPARTY_CONFIG_LINE
		SKIP3RDPARTY_CONFIG_LINES[key] = val

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['CoinUtils'] = 'ladanyi _AT_ us _DOT_ ibm _DOT_ com'
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS['CoinUtils'] = ['make test']
PROJECT_CONFIG_LINES['CoinUtils'] = STANDARD_CONFIG_LINES.copy()
#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['DyLP'] = 'lou _AT_ cs _DOT_ sfu _DOT_ ca'
UNITTEST_DIR['DyLP'] = os.path.join('Osi','test')
UNITTEST_CMD['DyLP'] = './unitTest -testOsiSolverInterface -netlibDir=_NETLIBDIR_ -cerr2cout' 
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS['DyLP'] = ['make test']
PROJECT_CONFIG_LINES['DyLP'] = STANDARD_CONFIG_LINES.copy()
#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Clp'] = 'jjforre _AT_ us _DOT_ ibm _DOT_ com'
UNITTEST_DIR['Clp'] = os.path.join('Clp','src')
UNITTEST_CMD['Clp'] = './clp -unitTest dirNetlib=_NETLIBDIR_ -netlib' 
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS['Clp'] = ['make test',UNITTEST_CMD['Clp']]
PROJECT_CONFIG_LINES['Clp'] = STANDARD_CONFIG_LINES.copy()
PROJECT_CONFIG_LINES['Clp'].update(SKIP3RDPARTY_CONFIG_LINES)

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['SYMPHONY'] = 'tkr2 _AT_ lehigh _DOT_ edu'
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS['SYMPHONY'] = ['make test']
PROJECT_CONFIG_LINES['SYMPHONY'] = STANDARD_CONFIG_LINES.copy()
#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Vol'] = 'barahon _AT_ us _DOT_ ibm _DOT_ com'
PROJECT_CONFIG_LINES['Vol'] = STANDARD_CONFIG_LINES.copy()
#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Osi'] = 'mjs _AT_ ces _DOT_ clemson _DOT_ edu'
UNITTEST_DIR['Osi'] = os.path.join('Osi','test')
UNITTEST_CMD['Osi'] = './unitTest -testOsiSolverInterface -netlibDir=_NETLIBDIR_ -cerr2cout' 
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS['Osi'] = ['make test',UNITTEST_CMD['Osi']]
PROJECT_CONFIG_LINES['Osi'] = STANDARD_CONFIG_LINES.copy()
PROJECT_CONFIG_LINES['Osi'].update(SKIP3RDPARTY_CONFIG_LINES)

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Cgl'] = 'robinlh _AT_ us _DOT_ ibm _DOT_ com'
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS['Cgl'] = ['make test']
PROJECT_CONFIG_LINES['Cgl'] = STANDARD_CONFIG_LINES.copy()
#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Cbc'] = 'jjforre _AT_ us _DOT_ ibm _DOT_ com'
UNITTEST_DIR['Cbc'] = os.path.join('Cbc','src')
UNITTEST_CMD['Cbc'] = './cbc -unitTest -dirMiplib=_MIPLIB3DIR_ -miplib' 
PROJECT_CONFIG_LINES['Cbc'] = STANDARD_CONFIG_LINES.copy()
PROJECT_CONFIG_LINES['Cbc'].update(SKIP3RDPARTY_CONFIG_LINES)
PROJECT_CONFIG_LINES['Cbc']['Parallel']='--enable-cbc-parallel'

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['FlopC++'] = 'Tim _DOT_ Hultberg _AT_ eumetsat _DOT_ int'
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS['FlopC++'] = ['make test']
PROJECT_CONFIG_LINES['FlopC++'] = STANDARD_CONFIG_LINES
#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Ipopt'] = 'andreasw _AT_ us _DOT_ ibm _DOT_ com'
PROJECT_CONFIG_LINES['Ipopt'] = STANDARD_CONFIG_LINES
#third party packages are not optional here

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['OS'] = 'kipp _DOT_ martin _AT_ chicagogsb _DOT_ edu'
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS['OS'] = ['make test']
PROJECT_CONFIG_LINES['OS'] = STANDARD_CONFIG_LINES
#third party packages are not optional here (because it uses Ipopt)

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['CppAD'] = 'bradbell _AT_ washington _DOT_ edu'
PROJECT_CONFIG_LINES['CppAD'] = STANDARD_CONFIG_LINES
#does not have references to third party packages
