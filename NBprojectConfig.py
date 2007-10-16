#! /usr/bin/env python

import os

#----------------------------------------------------------------------
# This file defines variables which describe how the specific
# coin-or projects are to be built and tested. 
#----------------------------------------------------------------------

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS = {}
UNITTEST_DIR = {}
UNITTEST_CMD = {}
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS = {} 

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['CoinUtils'] = 'ladanyi _AT_ us _DOT_ ibm _DOT_ com'
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS['CoinUtils'] = ['make test']

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['DyLP'] = 'lou _AT_ cs _DOT_ sfu _DOT_ ca'
UNITTEST_DIR['DyLP'] = os.path.join('Osi','test')
UNITTEST_CMD['DyLP'] = './unitTest -testOsiSolverInterface -netlibDir=_NETLIBDIR_ -cerr2cout' 
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS['DyLP'] = ['make test']

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Clp'] = 'jjforre _AT_ us _DOT_ ibm _DOT_ com'
UNITTEST_DIR['Clp'] = os.path.join('Clp','src')
UNITTEST_CMD['Clp'] = './clp -unitTest -netlib dirNetlib=_NETLIBDIR_' 
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS['Clp'] = ['make test',UNITTEST_CMD['Clp']]

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['SYMPHONY'] = 'tkr2 _AT_ lehigh _DOT_ edu'
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS['SYMPHONY'] = ['make test']

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Vol'] = 'barahon _AT_ us _DOT_ ibm _DOT_ com'

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Osi'] = 'mjs _AT_ ces _DOT_ clemson _DOT_ edu'
UNITTEST_DIR['Osi'] = os.path.join('Osi','test')
UNITTEST_CMD['Osi'] = './unitTest -testOsiSolverInterface -netlibDir=_NETLIBDIR_ -cerr2cout' 
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS['Osi'] = ['make test',UNITTEST_CMD['Osi']]

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Cgl'] = 'robinlh _AT_ us _DOT_ ibm _DOT_ com'
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS['Cgl'] = ['make test']

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Cbc'] = 'jjforre _AT_ us _DOT_ ibm _DOT_ com'
UNITTEST_DIR['Cbc'] = os.path.join('Cbc','src')
UNITTEST_CMD['Cbc'] = './cbc -unitTest -miplib -dirMiplib=_MIPLIB3DIR_' 


#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Ipopt'] = 'andreasw _AT_ us _DOT_ ibm _DOT_ com'

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['OS'] = 'kipp _DOT_ martin _AT_ chicagogsb _DOT_ edu'

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['CppAD'] = 'bradbell _AT_ washington _DOT_ edu'
