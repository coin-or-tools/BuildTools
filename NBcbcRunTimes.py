import re
import os
import sys
import platform
import MySQLdb

import NBsvnCommand
import NBlogMessages

def getTestCaseRunTimes(cbcStdout):
  retVal = {}
  # Look for pattern
  #   processing mps file: p0201 (31 out of 44)
  # cbc_clp 13.75 = 13.75 ; okay - took 17.83 seconds.
  r1=r'(cbc_clp (.+) = (.+) ; okay - took (\d*\.\d*) seconds.)'
  
  r2=r'(.+ processing mps file: (.+) \((\d*) out of (\d*)\))'
  r='('+r1+'|'+r2+')'
  reResult=re.findall(r,cbcStdout)

  for i in range(len(reResult)):
    if reResult[i][0].find("  processing mps file:") : continue
    # reResult[i] contains "  processing mps file:"
    if reResult[i][8] != '44' : continue
    tcName=reResult[i][6]
    tcRuntime=reResult[i+1][4]
    retVal[tcName]=tcRuntime
    
  return retVal

def getCbcStdout(cbcStdoutFileName):
  retVal='file not read'
  if os.path.isfile(cbcStdoutFileName) :
    cbcStdoutFilePtr = open(cbcStdoutFileName,'r')
    retVal = cbcStdoutFilePtr.read()
    cbcStdoutFilePtr.close()
  return retVal
#===========================================================================
def updateMachineTables(db) : 
  cursor = db.cursor()
  
  # Get Info about machine and put into database
  machineHw=platform.machine()
  machineOS=platform.system()
  machineName=platform.node()
  svnRevNum = NBsvnCommand.svnRevision('.')

  # Does this machine already exist in database?
  x=cursor.execute("""SELECT machineId from machine WHERE hostName='%s' and machineOS='%s' and machineHardware='%s'"""%
                 (machineName,machineOS,machineHw) )
  row = cursor.fetchone()
  if row!=None :
    retVal=row[0]
    cursor.close()
    return retVal
  
  x=cursor.execute("Insert INTO machine (hostName,machineOS,machineHardware) VALUES (%s,%s,%s)",
                 (machineName,machineOS,machineHw) )  
  retVal = db.insert_id()
  cursor.close()

  return retVal
#==================================================================================

def updateBuildTables(db,svnSrcDir,buildDir) : 
  cursor = db.cursor()
  
  # Get Info about build and put into database
  os.chdir(svnSrcDir)  
  svnRevNum = NBsvnCommand.svnRevision('.')
  svnUrl = NBsvnCommand.svnUrl('.')
  execFilename=os.path.join(buildDir,"Cbc","src","cbc")
  execModTimeEpoch=os.path.getmtime(execFilename)
  execModTime=str(datetime.datetime.fromtimestamp(execModTimeEpoch))

  # Does this build already exist in database?
  x=cursor.execute("""SELECT buildId from build WHERE svnRevision='%s' and svnUrl='%s' and executableTimeStamp='%s'"""%
                 (str(svnRevNum),svnUrl,execModTime) )
  row = cursor.fetchone()
  if row!=None :
    retVal=row[0]
    cursor.close()
    return retVal
  
  x=cursor.execute("Insert INTO build (svnRevision,svnUrl,executableTimeStamp) VALUES (%s,%s,%s)",
                 (str(svnRevNum),svnUrl,execModTime) )  
  retVal = db.insert_id()

  # Insert build attributes in database
  externalsRevisionNum = {}
  NBsvnCommand.svnRevisions('.',externalsRevisionNum)
  x=cursor.execute("Insert INTO buildAttr"+
                   "(buildId,buildAttrName,buildAttrValue) VALUES (%s,'svnExternals',%s)",
                 (str(retVal),str(externalsRevisionNum)) )

  #TODO: add configuration parms and gcc version (perhaps compiler name too)
  cursor.close()
  return retVal



  

def updateDb(dbPwDir,svnSrcDir,buildDir,cbcStdout) :

  # Get access info: host, userid, pw
  dbAccessInfoFile = os.path.join(dbPwDir,'dbAccessInfo.txt')
  if os.path.isfile(dbAccessInfoFile) :
    dbAccessInfoFilePtr = open(dbAccessInfoFile,'r')
    for dbAccessInfoRecord in dbAccessInfoFilePtr.readlines():
      dbAccessInfo=dbAccessInfoRecord.split(":")
      if len(dbAccessInfo)!=4 : continue
      if dbAccessInfo[0].strip()=="DbAccessInfo" : break
    if dbAccessInfo[0].strip()!="DbAccessInfo" :
      NBlogMessages.writeMessage("Expected record not found in "+dbAccessInfoFile )
      sys.exit(1)
    dbAccessInfoFilePtr.close()  
    dbServer=dbAccessInfo[1].strip()
    dbUserid=dbAccessInfo[2].strip()
    dbPw=dbAccessInfo[3].strip()
  else :
    NBlogMessages.writeMessage( "Failure reading " + dbAccessInfoFile )
    sys.exit(1)

  # Open date base connection
  db = MySQLdb.connect(host=dbServer,user=dbUserid,passwd=dbPw,db='coin')

  
  # Get Info about machine and put into database
  machineId=updateMachineTables(db)

  # Get Info about build and put into database
  buildId=updateBuildTables(db,svnSrcDir,buildDir)

  x=getTestCaseRunTimes(cbcStdout)
  cursor = db.cursor() 
  for t in x:
    # execute SQL statement
    cursor.execute("INSERT INTO cbcUnitTest (mpsName,time,buildId,machineId) VALUES (%s,%s,%s,%s)",
                  (t, x[t],str(buildId),str(machineId)))

##  cursor.execute("SELECT mpsName, time from cbcUnitTest")
##  while (1):
##    row=cursor.fetchone()
##    if row==None: break
##    print "%s %s" % (row[0],row[1])
##  print "Number of rows returned: %d" % cursor.rowcount

  cursor.close()
  db.commit()
  db.close()


x=getCbcStdout('/home/jp/COIN/Cbc/trunkNoThirdParty/Cbc/src/NBstdout-.-cbcunitTestdirMiplib--home-jp-COIN-Data-miplib3miplib')
updateDb("/home/jp/testScripts","/home/jp/COIN/Cbc/trunk","/home/jp/COIN/Cbc/trunkNoThirdParty",x)

# http://pleac.sourceforge.net/pleac_python/datesandtimes.html

