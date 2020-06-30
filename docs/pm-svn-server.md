
# Miscellaneous Server Configuration

----------


## Automatic tarball creation

Two kinds of tarballs can be automatically created according to the wishes of the project manager. Every night each project is scanned for two directory names: "`releases`" and "`trunk`". Note that if there are several subprojects then there might be multiple such directories. E.g., there is a "`CHiPPS/Alps/trunk`" and a "`CHiPPS/Bcps/trunk`". 


### For each "`trunk`" the following happens:
 1. The path to that "`trunk`" within the repository is extracted: "`/path/to/SUBPROJECT/trunk`".
 1. It is tested whether the file "`/path/to/SUBPROJECT/conf/nightlytrunk.txt`" exists or not, and if it does not then no tarball is created for this trunk. If it does then:
  * "`svn export`" is invoked for "`/path/to/SUBPROJECT/trunk`", and the extracted directory structure is tar'd together under the name "`SUBPROJECT-unstable-DATE.tgz`". 
  * If there is a file "`/path/to/SUBPROJECT/trunk/doxydoc/doxygen.conf`" then "`doxygen`" is invoked and the created html documentation is tar'd together under the name "`SUBPROJECT-doxydoc-unstable-DATE.tgz`". 
  * Only the last two days' trunk tarballs are kept.
Note that:
 * If the project manager does nothing then no nightly tarballs are created from trunk, which is where the new development happens.
 * If "`trunk`" is in the root of the repository (i.e., there is no subproject) then the name of the project is used instead.


### For each "`releases`" the following happens:
 1. The path to that "`releases`" within the repository is extracted: "`/path/to/SUBPROJECT/releases`".
 1. It is tested whether the file "`/path/to/SUBPROJECT/conf/nonightlyreleases.txt`" exists or not. If it does then no tarball is created from any of the releases in "`/path/to/SUBPROJECT/releases`". If it does not then:
  * For each subdirectory "`/path/to/SUBPROJECT/releases/M.m.t`" (where the last three pieces are the Major, minor and tiny version numbers) "`svn extract`" is invoked and the extracted directory structure is tar'd together under the name "`SUBPROJECT-M.m.t.tgz`", provided that
    * the tarball does not yet exists; and
    * there is no file "`/path/to/SUBPROJECT/releases/M.m.t/norelease.txt`".
  * If a tarball is created in the previous step then if there is a file "`/path/to/SUBPROJECT/releases/M.m.t/doxydoc/doxygen.conf`" then "`doxygen`" is invoked and the created html documentation is tar'd together under the name "`SUBPROJECT-doxydoc-M.m.t.tgz`". 
  * These tarballs are never deleted.
 1. It is tested whether the file "`/path/to/SUBPROJECT/conf/nolatest.txt`" exists or not. If it does then no "latest" file (see next step) is created for this subproject. If it does not then:
  * A "`SUBPROJECT-latest.png`" image file and a "`SUBPROJECT-latest.txt`" plain text file are created from the latest release number and are copied to two places. 
    * One is the static are of the Trac pages, these can be accessed as "`[htdocs:SUBPROJECT-latest.png]`" and "`[htdocs:SUBPROJECT-latest.txt]`" from the wiki pages. 
    * The other is the static area of the COIN-OR website, these can be accessed as "`/LatestRelease/SUBPROJECT-latest.png`" and "`/LatestRelease/SUBPROJECT-latest.txt`" from the static pages of any project and as "`www.coin-or.org/LatestRelease/SUBPROJECT-latest.png`" and "`www.coin-or.org/LatestRelease/SUBPROJECT-latest.txt`" from anywhere on the web.

Note that:
 * If the project manager does nothing then for each project the releases are automagically tar'd together.
 * if "`releases`" is in the root of the repository (i.e., there is no subproject) then the name of the project is used instead.

------------------


## Configuration files

There are several configuration files. Some live in the "`conf`" subdirectory of the root of the repository, some live in "`conf`" subdirectories that are siblings of "`trunk`" or "`releases`" subdirectories. These are;

=== nightlytrunk.txt === 

  Lives in a "`conf`" subdirectory that is a sibling of a "`trunk`". The existence (or non-existence) of the file controls whether a nightly tarball is created from the corresponding "`trunk`" (see above). The content of the file is irrelevant.


### nonightlyreleases.txt

  Lives in a "`conf`" subdirectory that is a sibling of a "`releases`". The existence (or non-existence) of the file controls whether tarballs are created from the subdirectories of the corresponding "`releases`" (see above). The content of the file is irrelevant.


### nolatest.txt

  Lives in a "`conf`" subdirectory that is a sibling of a "`releases`". The existence (or non-existence) of the file controls whether the "latest" file is created for the subproject the "`releases`" directory corresponds to (see above). The content of the file is irrelevant.


### norelease.txt

  Lives in a "`releases/M.m.t`" subdirectory. The existence (or non-existence) of the file controls whether a tarball should be created from the "`M.m.t`" release or not. If this file exists then  no tarball is created from this release even if the "`nonightlyreleases.txt`" file does not exist. The content of the file is irrelevant.


### release.txt

  Lives in the "`conf`" subdirectory of the root of the repository. This file *must* be committed alone. The project manager can use this file to create individual tarball releases from any part of the repository. Note that if a tarball is created then if a "`doxydoc/doxygen.conf`" file exists within the release then a tarball with the doxygen documentation will also be created. The format of this file is the following:
 * lines starting with a `#` are discarded.
 * the rest of the files must have either six (the new format) or two (the old format) fields. All other lines are discarded.
 * If a line has six fields they are interpreted as:

   `project  subproject  release  releasepath  forcetar  replacedox`

  * "`project`" specifies in which project's tarball subdirectory the created tarballs must be put.
  * "`subproject`" and "`release`" will be used to create the name of the tarball ("`subproject-release.tgz`") and of the documentation tarball ("`subproject-doxydoc-release.tgz`"). 
  * "`releasepath`" specifies the path within the repository to the relase that should be extracted via "`svn extract`" and tar'd together.
  * "`forcetar`" can be "`yes`" or "`no`". If it is "`yes`" then the tarball (and doc tarball) will be created no matter what. Otherwise the tarball will be created only if it does not already exist.
  * "`replacedox`" can be "`yes`" or "`no`". If it is "`yes`" and a doc tarball is created then the online documentation is replaced with the newly created documentation (see step 4. in the _For each "`releases`" the following happens:_ section above)
 * If a line has two fields then first all six fields of the new format are set (see below) then the same script is called to create the tarball. The two fields read from the file are
   "`releasepath`" and "`release`" (in that order), and they have the same meaning as in the other format. The other values are set as follows:
  * Since this file is committed for a project, "`project`" can easily be inferred (it could be for the other format, too, but other scripts on the server use this format, so we ask the PM to use this one, too...). 
  * "`subproject`" is set to the value of "`project`". 
  * "`forcetar`" is set to "`yes`"
  * "`replacedox`" is set to "`yes`"


### perms.txt

  Lives in the "`conf`" subdirectory of the root of the repository. The project manager can excercise access control using this file. This file *must* be committed alone. For project "`Foo`" the file must contain an arbitrary number of blocks of the following format:
```
[Foo:/some/path/in/the/repository]
userid1 = rw
userid2 = rw
```
  I.e., for a given path a number of users have read-write access (everybody has read access). Unfortunately, at this time regular expressions can't be used. The userids specfied are the ones the users created for themselves by registering in Trac on the coin-or website. Also *only those userids can be specified whose owners have already submitted a Contributor's Statement of Respect for Ownership to the COIN-OR foundation*. If another userid is included then the commit will be rejected.


### projDesc.xml

  Lives in the "`conf`" subdirectory of the root of the repository. Edit the template [here](https://projects.coin-or.org/BuildTools/raw-attachment/wiki/pm-svn-server/projDesc.xml) to contain the relevant information for your project and simply check it into the repository in the `conf/` subdirectory of your repository's root (important: do not change the filename from `projDesc.xml`). After checking in this file, the project's information page will be automatically rendered from the information in this XML file when a user types in the address http://www.coin-or.org/projects/projName.xml, where "projName" is the official acronym of your project, i.e., the one that appears after https://projects.coin-or.org/ in order to get to your projects' Trac page. For example, the XML page of SYMPHONY is [here](https://projects.coin-or.org/SYMPHONY/browser/conf/projDesc.xml), and SYMPHONY's project information page is [here](http://www.coin-or.org/projects/SYMPHONY.xml). Note: If the page fails to display after you have committed you XML file properly, the problem is most likely that your project has not been added to the project list in the XSLT file that is necessary in parsing the XML. In this case, please contact your project handler to have your project added to the list.

---------------------


## Creating and maintaining the static pages of a project

A project manager may wish to create "static" pages, i.e., pages that are not part of Trac's wiki system, not editable by anyone but themselves. To facilitate this, for every new project in the root of the svn repository of the project a directory named "`html`" is created, with one single "`index.html `" file in it. This file contains a simple redirect to the trac pages. Whenever something is committed to the html directory the content of the directory is mirrored on the web and is available at www.coin-or.org/PROJECT. So the default index.html just simply says that the home of the project lives in trac and redirects there. If the PM creates a new "`index.html`" then that will be displayed. The COIN-OR css (cascading style sheet) definitions are available to those who want to create nice pages here. For an example about how to use them look at the source of http://www.coin-or.org/CppAD.

----------


## Scripts and Logs

For the benefit of the curious, the scripts that run every night on the server can be found at http://www.coin-or.org/Update/Scripts. The update.sh script is invoked by cron, the rest is invoked by update.sh. Logs of update.sh are available for the past two weeks at http://www.coin-or.org/Update/Logs.

---

Attachments:
 * [projDesc.xml](pm-svn-server/projDesc.xml)
