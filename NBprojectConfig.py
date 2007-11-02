#! /usr/bin/env python

#------------------------------------------------------------------------
# This file is distributed under the Common Public License.
# It is part of the BuildTools project in COIN-OR (www.coin-or.org)
#------------------------------------------------------------------------

import os
import NBcheckResult

#----------------------------------------------------------------------
# This file defines variables which describe how the specific
# coin-or projects are to be tested and who are their managers.
#----------------------------------------------------------------------

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS = {}
UNITTEST_DIR = {}
UNITTEST_CMD = {}
ALL_TESTS_COMPLETED_SUCCESSFULLY_CMDS = {}
CHECK_MAKE_TEST = {}
CHECK_UNITTEST = {}



#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['CoinUtils'] = 'ladanyi _AT_ us _DOT_ ibm _DOT_ com'
CHECK_MAKE_TEST['CoinUtils']=[NBcheckResult.rc0,
                              NBcheckResult.standardSuccessMessage]
#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['DyLP'] = 'lou _AT_ cs _DOT_ sfu _DOT_ ca'
UNITTEST_DIR['DyLP'] = os.path.join('Osi','test')
UNITTEST_CMD['DyLP'] = './unitTest -testOsiSolverInterface -netlibDir=_NETLIBDIR_ -cerr2cout' 
CHECK_MAKE_TEST['DyLP']=[
                         NBcheckResult.rc0,
                         NBcheckResult.standardSuccessMessage,
                         NBcheckResult.noSolverInterfaceTestingIssueMessage]
CHECK_UNITTEST['DyLP']=[
                         NBcheckResult.rc0,
                         NBcheckResult.standardSuccessMessage,
                         NBcheckResult.noSolverInterfaceTestingIssueMessage]
#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Clp'] = 'jjforre _AT_ us _DOT_ ibm _DOT_ com'
UNITTEST_DIR['Clp'] = os.path.join('Clp','src')
UNITTEST_CMD['Clp'] = './clp -unitTest dirNetlib=_NETLIBDIR_ -netlib' 
CHECK_MAKE_TEST['Clp']=[
                         NBcheckResult.rc0,
                         NBcheckResult.standardSuccessMessage]
CHECK_UNITTEST['Clp']=[
                         NBcheckResult.rc0,
                         NBcheckResult.standardSuccessMessage,
                         NBcheckResult.endWithWoodw]

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['SYMPHONY'] = 'tkr2 _AT_ lehigh _DOT_ edu'
CHECK_MAKE_TEST['SYMPHONY']=[
                         NBcheckResult.rc0,
                         NBcheckResult.standardSuccessMessage]
UNITTEST_DIR['SYMPHONY'] = '.'
UNITTEST_CMD['SYMPHONY'] = 'make fulltest' 
CHECK_UNITTEST['SYMPHONY']=[
                         NBcheckResult.rc0,
                         NBcheckResult.standardSuccessMessage,
                         ]

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Vol'] = 'barahon _AT_ us _DOT_ ibm _DOT_ com'
CHECK_MAKE_TEST['Vol']=[
                         NBcheckResult.rc0]
#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Osi'] = 'mjs _AT_ ces _DOT_ clemson _DOT_ edu'
UNITTEST_DIR['Osi'] = os.path.join('Osi','test')
UNITTEST_CMD['Osi'] = './unitTest -testOsiSolverInterface -netlibDir=_NETLIBDIR_ -cerr2cout' 
CHECK_MAKE_TEST['Osi']=[
                         NBcheckResult.rc0,
                         NBcheckResult.standardSuccessMessage,
                         NBcheckResult.noSolverInterfaceTestingIssueMessage]
CHECK_UNITTEST['Osi']=[
                         NBcheckResult.rc0,
                         NBcheckResult.standardSuccessMessage,
                         NBcheckResult.noSolverInterfaceTestingIssueMessage]

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Cgl'] = 'robinlh _AT_ us _DOT_ ibm _DOT_ com'
CHECK_MAKE_TEST['Cgl']=[
                         NBcheckResult.rc0,
                         NBcheckResult.standardSuccessMessage]
#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Cbc'] = 'jjforre _AT_ us _DOT_ ibm _DOT_ com'
UNITTEST_DIR['Cbc'] = os.path.join('Cbc','src')
UNITTEST_CMD['Cbc'] = './cbc -unitTest -dirMiplib=_MIPLIB3DIR_ -miplib' 
CHECK_MAKE_TEST['Cbc']=[
                         NBcheckResult.rc0,
                         NBcheckResult.cbcMakeTestSuccessMessage]
CHECK_UNITTEST['Cbc']=[ NBcheckResult.rc0to2 ]

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Ipopt'] = 'andreasw _AT_ us _DOT_ ibm _DOT_ com'
CHECK_MAKE_TEST['Ipopt']=[NBcheckResult.rc0
                         # ,NBcheckResult.standardSuccessMessage
                         ]
#third party packages are not optional here

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Bonmin'] = 'pbonami _AT_ us _DOT_ ibm _DOT_ com'
CHECK_MAKE_TEST['Bonmin']=[NBcheckResult.rc0
                          ,NBcheckResult.standardSuccessMessage
                          ]
#third party packages are not optional here

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['FlopC++'] = 'Tim _DOT_ Hultberg _AT_ eumetsat _DOT_ int'
CHECK_MAKE_TEST['FlopC++']=[
                         NBcheckResult.rc0,
                         NBcheckResult.standardSuccessMessage]
#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['OS'] = 'kipp _DOT_ martin _AT_ chicagogsb _DOT_ edu'
CHECK_MAKE_TEST['OS']=[
                         NBcheckResult.rc0,
                         NBcheckResult.standardSuccessMessage]
#third party packages are not optional if Ipopt is not excluded

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['CppAD'] = 'bradbell _AT_ washington _DOT_ edu'
CHECK_MAKE_TEST['CppAD']=[NBcheckResult.anythingGoes]
UNITTEST_DIR['CppAD'] = os.path.join('.')
UNITTEST_CMD['CppAD'] = './example/example'
CHECK_UNITTEST['CppAD']=[NBcheckResult.rc0] 
#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Smi'] = 'kingaj _AT_ us _DOT_ ibm _DOT_ com'
CHECK_MAKE_TEST['Smi']=[
                         NBcheckResult.rc0,
                         NBcheckResult.standardSuccessMessage]
#does not have references to third party packages
#TODO: need some check whether make test was successful; what is the behaviour in Smi's unittest if it fails?
