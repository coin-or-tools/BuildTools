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
SLN_BLD_TEST = {}
CFG_BLD_TEST = {}
CFG_BLD_INSTALL = {}
SLN_FILE = {}
SLN_DIR = {}


#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['CoinUtils'] = 'ladanyi _AT_ us _DOT_ ibm _DOT_ com'

CFG_BLD_TEST['CoinUtils']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage ] } ]

CFG_BLD_INSTALL['CoinUtils']=[
                  {'dir':'',
                   'cmd':'make install',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage ] } ]

SLN_BLD_TEST['CoinUtils']=[
                  {'dir':r'CoinUtils\MSVisualStudio',
                   'cmd':'v8\unitTestCoinUtils\Release\unitTestCoinUtils',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage] },
                  {'dir':r'CoinUtils\MSVisualStudio',
                   'cmd':'v8\unitTestCoinUtils\Debug\unitTestCoinUtils',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage] } ]
#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['DyLP'] = 'lou _AT_ cs _DOT_ sfu _DOT_ ca'

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
                             NBcheckResult.noSolverInterfaceTestingIssueMessage] } ]

#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Clp'] = 'jjforre _AT_ us _DOT_ ibm _DOT_ com'

CFG_BLD_TEST['Clp']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage ] },
                  {'dir':'Clp/src',
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
CFG_BLD_TEST['Vol']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0 ] } ]
#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Osi'] = 'mjs _AT_ ces _DOT_ clemson _DOT_ edu'
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
CFG_BLD_TEST['Cgl']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage ] } ]
#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Cbc'] = 'jjforre _AT_ us _DOT_ ibm _DOT_ com'

CFG_BLD_TEST['Cbc']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.cbcMakeTestSuccessMessage ] },
                  {'dir':'Cbc/src',
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

CFG_BLD_TEST['Ipopt']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0 ] } ]
#third party packages are not optional here

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Bonmin'] = 'pbonami _AT_ us _DOT_ ibm _DOT_ com'

CFG_BLD_TEST['Bonmin']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0 ] } ]
#third party packages are not optional here

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['FlopC++'] = 'Tim _DOT_ Hultberg _AT_ eumetsat _DOT_ int'

CFG_BLD_TEST['FlopC++']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage ] } ]
SLN_FILE['FlopC++']=r'FlopCpp.sln'
SLN_DIR['FlopC++']=r'FlopCpp\MSVisualStudio\v8'
SLN_BLD_TEST['FlopC++']=[
                  {'dir':r'FlopCpp\MSVisualStudio\v8\Release',
                   'cmd':'unitTest',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage ] },
                  {'dir':r'FlopCpp\MSVisualStudio\v8\Debug',
                   'cmd':'unitTest',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage ] } ]

#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['OS'] = 'kipp _DOT_ martin _AT_ chicagogsb _DOT_ edu'
CFG_BLD_TEST['OS']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage ] } ]
CFG_BLD_INSTALL['OS']=[
                  {'dir':'',
                   'cmd':'make install',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage ] } ]

SLN_BLD_TEST['OS']=[
                  {'dir':r'OS\test',
                   'cmd':'unitTestDebug',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage ] },
                  {'dir':r'OS\test',
                   'cmd':'unitTestRelease',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.standardSuccessMessage ] } ]
#third party packages are not optional if Ipopt is not excluded

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['LaGO'] = 'stefan _AT_ math _DOT_ hu-berlin _DOT_ de'
CFG_BLD_TEST['LaGO']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0 ] } ]

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['CoinAll'] = 'tkr2 _AT_ lehigh _DOT_ edu'
CFG_BLD_TEST['CoinAll']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0 ] } ]

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['CppAD'] = 'bradbell _AT_ washington _DOT_ edu'

CFG_BLD_TEST['CppAD']=[
                  {'dir':'',
                   'cmd':'./example/example',
                   'check':[ NBcheckResult.rc0 ] }, 
                  {'dir':'',
                   'cmd':'./test_more/test_more',
                   'check':[ NBcheckResult.rc0 ] } ]
#does not have references to third party packages

#----------------------------------------------------------------------
PROJECT_EMAIL_ADDRS['Smi'] = 'kingaj _AT_ us _DOT_ ibm _DOT_ com'

CFG_BLD_TEST['Smi']=[
                  {'dir':'',
                   'cmd':'make test',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.endWithStarDoneStar ] } ]
SLN_BLD_TEST['Smi']=[
                  {'dir':r'Smi\test',
                   'cmd':r'..\MSVisualStudio\v8\unitTestSmi\Release\smiUnitTest',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.endWithStarDoneStar ] },
                  {'dir':r'Smi\test',
                   'cmd':r'..\MSVisualStudio\v8\unitTestSmi\Debug\smiUnitTest',
                   'check':[ NBcheckResult.rc0,
                             NBcheckResult.endWithStarDoneStar ] } ]
#does not have references to third party packages
#TODO: need some check whether make test was successful; what is the behaviour in Smi's unittest if it fails?
