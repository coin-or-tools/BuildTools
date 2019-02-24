
 This page is still a work in process...

[TortoiseSVN](http://tortoisesvn.tigris.org/) can be used to checkout and update a project.  This is described on page [Downloading the Source Code](./user-download).

Project Managers often need to add, change, delete, move, and rename files.  These operations can be performed on the local checked out copy of the repository using TortoiseSVN.  To make these changes visible in the repository the subversion _commit_ command is performed.  This page describes how to use TortoiseSVN to perform some of these operations.


## SVN Commit: Change an Existing File

After fixing a bug or adding an enhancement the source code in one or more files will have changed.  These changes need to committed to the repository. Once committed the changes are publicly available to everyone.  Windows Explorer displays a special icon to show that a file has been changed or that a directory contains a changed file.  Here Windows Explorer indicates that `CbcParam.cpp` been modified and the directories `Cbc`, `CoinUtils`, and `Coin-Cbc` contain one or more modified files.
```
<img src="http://www.coin-or.org/screenShotImages/winExplorerWithChangedFiles.jpg" alt="Windows Explorer with Changed Files">
```

To commit your changes to the Subversion repository, in Windows Explorer right click on a changed file or directory to get the context pop up menu and select _SVN Commit..._
```
<img src="http://www.coin-or.org/screenShotImages/tortoiseSvnCommitPopup.jpg" alt="TortoiseSVN Commit Popup">
```

In Log Message dialog box provide a brief message about the change you are committing.
```
<img src="http://www.coin-or.org/screenShotImages/tortoiseSvnCommit.jpg" alt="TortoiseSVN Commit Dialog">
```


## SVN Add: Add a New File

To add new files to the Subversion repository, in Windows Explorer right click on the file or the directory containing the files to get the context pop up menu and select _SVN Add..._.
```
<img src="http://www.coin-or.org/screenShotImages/tortoiseSvnAddPopup.jpg" alt="TortoiseSVN Add Popup">
```

In the Add dialog box, select the files to be added.
```
<img src="http://www.coin-or.org/screenShotImages/tortoiseSvnAdd.jpg" alt="TortoiseSVN Add Dialog">
```

Windows Explorer displays a special icon to show that the file has been added.
```
<img src="http://www.coin-or.org/screenShotImages/winExplorerAfterTortoiseSvnAdd.jpg" alt="Windows Explorer After TortoiseSVN Add">
```

*The added files are not yet available in the repository. The new files must be committed to the repository.  The commit process is described above in the* *_SVN Commit: Change an Existing File*_ *section.* 
