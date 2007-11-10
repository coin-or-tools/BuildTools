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
SLN_BLD_TEST = {}
CFG_BLD_TEST = {}
SLN_FILE = {}



#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['CoinUtils'] = 'ladanyi _AT_ us _DOT_ ibm _DOT_ com'
CHECK_MAKE_TEST['CoinUtils']=[NBcheckResult.rc0,
                              NBcheckResult.standardSuccessMessage]
CFG_BLD_TEST['CoinUtils']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage ] } ]
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

CFG_BLD_TEST['DyLP']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage,
                             NBcheckResult.noSolverInterfaceTestingIssueMessage ] },
                  {'dir':'Osi/test',
                   'cmd':'./unitTest -testOsiSolverInterface -netlibDir=_NETLIBDIR_ -cerr2cout',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage,
                             NBcheckResult.endWithWoodw,
                             NBcheckResult.noSolverInterfaceTestingIssueMessage] } ]

#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Clp'] = 'jjforre _AT_ us _DOT_ ibm _DOT_ com'
UNITTEST_DIR['Clp'] = os.path.join('Clp','src')
UNITTEST_CMD['Clp'] = './clp -unitTest -dirNetlib=_NETLIBDIR_ -netlib' 
CHECK_MAKE_TEST['Clp']=[
                         NBcheckResult.rc0,
                         NBcheckResult.standardSuccessMessage]
CHECK_UNITTEST['Clp']=[
                         NBcheckResult.rc0,
                         NBcheckResult.standardSuccessMessage,
                         NBcheckResult.endWithWoodw]

CFG_BLD_TEST['Clp']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage ] },
                  {'dir':'Clp/Src',
                   'cmd':'./clp -unitTest -dirNetlib=_NETLIBDIR_ -netlib',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage,
                             NBcheckResult.endWithWoodw] } ]
SLN_BLD_TEST['Clp']=[
                  {'dir':r'Clp\MSVisualStudio\v8\clp\Release',
                   'cmd':'clp -dirSample=_SAMPLEDIR_ -unitTest -dirNetlib=_NETLIBDIR_ -netlib',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage,
                             NBcheckResult.endWithWoodw] },
                  {'dir':r'Clp\MSVisualStudio\v8\clp\Debug',
                   'cmd':'clp -dirSample=_SAMPLEDIR_ -unitTest -dirNetlib=_NETLIBDIR_ -netlib',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage,
                             NBcheckResult.endWithWoodw] } ]

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
CFG_BLD_TEST['SYMPHONY']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage ] },
                  {'dir':'',
                   'cmd':'make fulltest',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage ] } ]
SLN_BLD_TEST['SYMPHONY']=[ {
                   'dir':r'SYMPHONY\MSVisualStudio\v8\Release',
                   'cmd':r'symphony -F _NETLIBDIR_\25fv47.mps',
                   'check':[ NBcheckResult.rc0 ] },
                  {'dir':r'SYMPHONY\MSVisualStudio\v8\Debug',
                   'cmd':r'symphony -F _NETLIBDIR_\25fv47.mps',
                   'check':[ NBcheckResult.rc0 ] } ]

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Vol'] = 'barahon _AT_ us _DOT_ ibm _DOT_ com'
CHECK_MAKE_TEST['Vol']=[
                         NBcheckResult.rc0]
CFG_BLD_TEST['Vol']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0 ] } ]
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
CFG_BLD_TEST['Osi']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage,
                             NBcheckResult.noSolverInterfaceTestingIssueMessage ] },
                  {'dir':'Osi/test',
                   'cmd':'./unitTest -testOsiSolverInterface -netlibDir=_NETLIBDIR_ -cerr2cout',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage,
                             NBcheckResult.noSolverInterfaceTestingIssueMessage] } ]

SLN_BLD_TEST['Osi']=[
                  {'dir':r'Osi\MSVisualStudio\v8\OsiExamplesBuild\Release',
                   'cmd':'OsiExamplesBuild',
                   'check':[ NBcheckResult.rc0 ] },
                  {'dir':r'Osi\MSVisualStudio\v8\OsiExamplesBuild\Debug',
                   'cmd':'OsiExamplesBuild',
                   'check':[ NBcheckResult.rc0 ] } ]

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Cgl'] = 'robinlh _AT_ us _DOT_ ibm _DOT_ com'
CHECK_MAKE_TEST['Cgl']=[
                         NBcheckResult.rc0,
                         NBcheckResult.standardSuccessMessage]
CFG_BLD_TEST['Cgl']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage ] } ]
#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Cbc'] = 'jjforre _AT_ us _DOT_ ibm _DOT_ com'
UNITTEST_DIR['Cbc'] = os.path.join('Cbc','src')
UNITTEST_CMD['Cbc'] = './cbc -unitTest -dirMiplib=_MIPLIB3DIR_ -miplib' 
CHECK_MAKE_TEST['Cbc']=[
                         NBcheckResult.rc0,
                         NBcheckResult.cbcMakeTestSuccessMessage]
CHECK_UNITTEST['Cbc']=[ NBcheckResult.rc0to2 ]

CFG_BLD_TEST['Cbc']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.cbcMakeTestSuccessMessage ] },
                  {'dir':'Cbc/Src',
                   'cmd':'./cbc -unitTest -dirMiplib=_MIPLIB3DIR_ -miplib',
                   'check':[ NBcheckResult.rc0to2 ] } ]

SLN_BLD_TEST['Cbc']=[
                  {'dir':r'Cbc\MSVisualStudio\v8\cbcSolve\Release',
                   'cmd':'cbcSolve -dirSample=_SAMPLEDIR_ -unitTest -dirMiplib=_MIPLIB3DIR_ -miplib',
                   'check':[ NBcheckResult.rc0to2 ] },
                  {'dir':r'Cbc\MSVisualStudio\v8\cbcSolve\Debug',
                   'cmd':'cbcSolve -dirSample=_SAMPLEDIR_ -unitTest -dirMiplib=_MIPLIB3DIR_ -miplib',
                   'check':[ NBcheckResult.rc0to2 ] } ]

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Ipopt'] = 'andreasw _AT_ us _DOT_ ibm _DOT_ com'
CHECK_MAKE_TEST['Ipopt']=[NBcheckResult.rc0
                         # ,NBcheckResult.standardSuccessMessage
                         ]
CFG_BLD_TEST['Ipopt']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0
                             #,NBcheckResult.standardSuccessMessage
                  ] } ]
#third party packages are not optional here

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Bonmin'] = 'pbonami _AT_ us _DOT_ ibm _DOT_ com'
CHECK_MAKE_TEST['Bonmin']=[NBcheckResult.rc0
                          ,NBcheckResult.standardSuccessMessage
                          ]
CFG_BLD_TEST['Bonmin']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage ] } ]
#third party packages are not optional here

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['FlopC++'] = 'Tim _DOT_ Hultberg _AT_ eumetsat _DOT_ int'
CHECK_MAKE_TEST['FlopC++']=[
                         NBcheckResult.rc0,
                         NBcheckResult.standardSuccessMessage]
CFG_BLD_TEST['FlopC++']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.cbcMakeTestSuccessMessage ] } ]
SLN_FILE['FlopC++']=r'FlopCpp\MSVisualStudio\v8\FlopCpp.sln'
SLN_BLD_TEST['FlopC++']=[
                  {'dir':r'FlopCpp\MSVisualStudio\v8\Release',
                   'cmd':'unitTest -dirSample=_SAMPLEDIR_ -unitTest -dirNetlib=_NETLIBDIR_ -netlib',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage ] },
                  {'dir':r'FlopCpp\MSVisualStudio\v8\Debug',
                   'cmd':'unitTest -dirSample=_SAMPLEDIR_ -unitTest -dirNetlib=_NETLIBDIR_ -netlib',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage ] } ]

#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['OS'] = 'kipp _DOT_ martin _AT_ chicagogsb _DOT_ edu'
CHECK_MAKE_TEST['OS']=[
                         NBcheckResult.rc0,
                         NBcheckResult.standardSuccessMessage]
CFG_BLD_TEST['OS']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.cbcMakeTestSuccessMessage ] } ]
#third party packages are not optional if Ipopt is not excluded

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['CppAD'] = 'bradbell _AT_ washington _DOT_ edu'
CHECK_MAKE_TEST['CppAD']=[NBcheckResult.anythingGoes]
UNITTEST_DIR['CppAD'] = os.path.join('.')
UNITTEST_CMD['CppAD'] = './example/example'
CHECK_UNITTEST['CppAD']=[NBcheckResult.rc0]

CFG_BLD_TEST['CppAD']=[
                  {'dir':'',
                   'cmd':'./example/example',
                   'check':[ NBcheckResult.rc0 ] } ]
#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Smi'] = 'kingaj _AT_ us _DOT_ ibm _DOT_ com'
CHECK_MAKE_TEST['Smi']=[
                         NBcheckResult.rc0,
                         NBcheckResult.standardSuccessMessage]
CFG_BLD_TEST['Smi']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0 ] } ]
SLN_BLD_TEST['Smi']=[
                  {'dir':r'Smi\MSVisualStudio\v8\unitTest\Release',
                   'cmd':'unitTest -dirSample=_SAMPLEDIR_ -unitTest -dirNetlib=_NETLIBDIR_ -netlib',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage ] },
                  {'dir':r'Smi\MSVisualStudio\v8\unitTest\Debug',
                   'cmd':'unitTest -dirSample=_SAMPLEDIR_ -unitTest -dirNetlib=_NETLIBDIR_ -netlib',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage ] } ]
#does not have references to third party packages
#TODO: need some check whether make test was successful; what is the behaviour in Smi's unittest if it fails?
