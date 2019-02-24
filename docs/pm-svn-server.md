
 The COIN-OR server is set up to automatically perform several tasks at regular intervals (currently, once per day in the wee hours of the morning, Eastern time) for all subversion repositories.
This page describes the procedures that have been set up and how you can influence them.


## Automatic creation of source and documentation archives and latest-version files

Two kinds of archives can be automatically created according to the wishes of the project manager. Every night each project is scanned for two directory names: "`releases`" and "`trunk`". Note that if there are several subprojects then there might be multiple such directories. E.g., there is a "`CHiPPS/Alps/trunk`" and a "`CHiPPS/Bcps/trunk`". 


### For each trunk directory the following happens:

 1. The path to that trunk within the repository is extracted: "`path/to/SUBPROJECT/trunk`".
 1. It is tested whether the file "`path/to/SUBPROJECT/conf/nightlytrunk.txt`" exists or not. If it does not exist then no archives are created for this trunk. If it does exist, then:
  * "`svn export`" is invoked for "`path/to/SUBPROJECT/trunk`", and the extracted directory structure is tar'd together under the name "`SUBPROJECT-trunk-DATE.tgz`". 
  * If there is a file "`path/to/SUBPROJECT/trunk/doxydoc/doxygen.conf`" then "`doxygen`" is invoked and the created html documentation is tar'd together under the name "`SUBPROJECT-doxydoc-trunk-DATE.tgz`".
  * Trunk tarballs more than two days old are deleted.

Matching zip archives are also created. Note that:
 * If the project manager does nothing then no nightly archives are created from trunk, which is where the new development happens.
 * If the trunk directory being processed is the trunk of the project, at the root of the repository, then the base path is simply "`trunk`" and "`SUBPROJECT`" is replaced with "`PROJECT`" in file names.


### For each release directory the following happens:

 1. The path to that release directory within the repository is extracted: "`path/to/SUBPROJECT/releases`".
 1. It is tested whether the file "`path/to/SUBPROJECT/conf/nonightlyreleases.txt`" exists or not. If it exists then no archive is created for any of the releases in "`path/to/SUBPROJECT/releases`". If it does not exist then:
  * For each subdirectory "`path/to/SUBPROJECT/releases/M.m.t`" (where the last three pieces are the Major, minor and tiny version numbers) "`svn export`" is invoked and the extracted directory structure is tar'd together under the name "`SUBPROJECT-M.m.t.tgz`", provided that
    * an archive with this name does not yet exist; and
    * the file "`path/to/SUBPROJECT/releases/M.m.t/norelease.txt`" does not exist.
  * If an archive is created in the previous step then if there is a file "`path/to/SUBPROJECT/releases/M.m.t/doxydoc/doxygen.conf`" then "`doxygen`" is invoked and the created html documentation is tar'd together under the name "`SUBPROJECT-doxydoc-M.m.t.tgz`".
  * Release archives are never deleted.

As with trunk archives, matching zip archives are created.
Note that:
 * If the project manager does nothing then for each project the releases are automagically created.
 * If the release is for the project (and not for a subproject), the base directory is "`releases`" and "`SUBPROJECT`" is replaced with "`PROJECT`" in file names.

Source and documentation archives are available from [the web site download area](http://coin-or.org/download). Source with subversion externals, and documentation, are placed in the [source](http://coin-or.org/download/source) subdirectory. Source without subversion externals is placed in the [pkgsource](http://coin-or.org/download/pkgsource) subdirectory as a convenience for individuals repackaging COIN-OR software for other distributions.



### Latest-version files

 1. It is tested whether the file "`path/to/SUBPROJECT/conf/nolatest.txt`" exists or not. If it exists then no "latest" files (see next step) are created for this subproject. If it does not exist then:
  * The most recent stable version and release version are determined by examining the subproject's "`stable`" and "`release`" directories to find the most recently created subdirectory. If a most recent stable version is identified, the search for the most recent release is initially limited to releases matching the most recent stable version. If there is no release corresponding to the most recent stable version, or if no most recent stable version can be identified, the most recent release over all releases is chosen.
  * "`SUBPROJECT-latest-stable.png`" and "`SUBPROJECT-latest-release.png`" image files and matching "`SUBPROJECT-latest-stable.txt`" and "`SUBPROJECT-latest-release.txt`" plain text files are created and copied to two places: 
    * The static area of the project's Trac pages. The files for the stable version can be accessed from Trac wiki pages as "`[htdocs:SUBPROJECT-latest-stable.png]`" and "`[htdocs:SUBPROJECT-latest-stable.txt]`". The release files are accessed in a similar manner. 
    * The project's static area on the COIN-OR website. These can be accessed as "`/LatestRelease/SUBPROJECT-latest-stable.png`" and "`/LatestRelease/SUBPROJECT-latest-stable.txt`" from the static pages of any project and as "`www.coin-or.org/LatestRelease/SUBPROJECT-latest-stable.png`" and "`www.coin-or.org/LatestRelease/SUBPROJECT-latest-stable.txt`" from anywhere on the web. The release files are accessed in a similar manner. In addition, links are created to the release files with names "`SUBPROJECT-latest.png`" and "`SUBPROJECT-latest.txt`".

As with archives, if the version files are associated with the project, "`PROJECT`" replaces "`SUBPROJECT`" in the file names.





## Configuration files

There are several configuration files. Some live in the "`conf`" directory that is a sibling of the "`trunk`" or "`releases`" directories at the root of the repository (i.e., the "`conf`" directory for the project). Some live in "`conf`" directories that are siblings of "`trunk`" or "`releases`" directories for subprojects (i.e., "`conf`" directories for subprojects). These are;

=== "`nightlytrunk.txt`" === 

Lives in a "`conf`" directory that is a sibling of a "`trunk`". The existence (or non-existence) of the file controls whether a nightly archive is created from the corresponding "`trunk`" (see above). The content of the file is irrelevant.


### "`nonightlyreleases.txt`"

Lives in a "`conf`" directory that is a sibling of a "`releases`". The existence (or non-existence) of the file controls whether archives are created from the subdirectories of the corresponding "`releases`" (see above). The content of the file is irrelevant.


### "`nolatest.txt`"

Lives in a "`conf`" directory that is a sibling of a "`releases`". The existence (or non-existence) of the file controls whether the "latest-version" files are created for the project or subproject corresponding to the "`releases`" directory (see above). The content of the file is irrelevant.


### "`norelease.txt`"

Lives in a "`releases/M.m.t`" subdirectory. The existence (or non-existence) of the file controls whether an archive should be created from the "`M.m.t`" release or not. If this file exists then no archive is created from this release even if the "`nonightlyreleases.txt`" file does not exist. The content of the file is irrelevant.


### "`release.txt`"

Lives in the "`conf`" subdirectory of the root of the repository. This file *must* be committed alone. The project manager can use this file to create an individual release archive from any part of the repository. Note that if an archive is created then if a "`doxydoc/doxygen.conf`" file exists within the release then an archive with the doxygen documentation will also be created. The format of this file is the following:
 * Lines starting with a `#` are discarded.
 * The rest of the lines must have either six (the new format) or two (the old format) fields. All other lines are discarded.
 * If a line has six fields they are interpreted as:

   `project  subproject  release  releasepath  forcetar  replacedox`

  * "`project`" specifies in which project's archive directory the created archives must be put.
  * "`subproject`" and "`release`" will be used to create the name of the source ("`subproject-release.tgz`") and documentation ("`subproject-doxydoc-release.tgz`") archives. 
  * "`releasepath`" specifies the path within the repository to the release that should be extracted via "`svn export`" and tar'd together.
  * "`forcetar`" can be "`yes`" or "`no`". If it is "`yes`" then the source and documentation archives will be created no matter what. Otherwise the archives will be created only if they do not already exist.
  * "`replacedox`" can be "`yes`" or "`no`". If it is "`yes`" and a documentation archive is created then the online documentation is replaced with the newly created documentation (see step 4. in the _For each "`releases`" the following happens:_ section above)
 * If a line has two fields then first all six fields of the new format are set (see below) then the same script is called to create the archives. The two fields read from the line are
   "`releasepath`" and "`release`" (in that order), and they have the same meaning as in the other format. The other values are set as follows:
  * Since this file is committed for a project, "`project`" can easily be inferred (it could be for the other format, too, but other scripts on the server use this format, so we ask the PM to use this one, too...). 
  * "`subproject`" is set to the value of "`project`". 
  * "`forcetar`" is set to "`yes`"
  * "`replacedox`" is set to "`yes`"

Creation of the archive(s) specified by `release.txt` is handled by the subversion post-commit hook. Creation of an archive is a non-trivial operation and no further commits can occur until the post-commit hook completes.


### perms.txt

This file lives in the "`conf`" subdirectory of the root of your project's repository. A project manager can exercise access control using this file. This file *must* be committed alone. For project "`Foo`" the file should contain an arbitrary number of blocks of the following format:
```
[Foo:/some/path/in/the/repository]
userid1 = rw
userid2 = rw
```
I.e., for a given path a number of users have read-write access (everybody has read access). Unfortunately, at this time regular expressions can't be used. The userids specified are the ones the users created for themselves by registering in Trac on the coin-or website. Also *only those userids can be specified whose owners have already submitted a Contributor's Statement of Respect for Ownership to the COIN-OR foundation*. Put another way, you can specify any userid you like but commits by that userid will be rejected unless a Contributor's Statement of Respect for Ownership is on file.

Changes to access rights are handled by the subversion post-commit hook.


### projDesc.xml

This file lives in the "`conf`" subdirectory of the root of your project's repository and is used to generate a standard information page for your project. You can acquire a copy of the [template](https://projects.coin-or.org/svn/CoinWeb/trunk/projects/projDesc.xml) from the Coin-Web repository with the command
```
svn cat https://projects.coin-or.org/svn/CoinWeb/trunk/projects/projDesc.xml
```
Edit it to contain the relevant information for your project. XML parsing is fussy! Please take note of the cautions in the comments at the head of `projDesc.xml`. When you're done, check it into your project's repository in the `conf/` subdirectory at your repository's root. *Important*: do not change the filename from `projDesc.xml`.

After checking in `projDesc.xml`, the project's standard information page will be automatically rendered from the information in the file when a user types in the address `http://www.coin-or.org/projects/Foo.xml`, where `Foo` is the repository name for your project, i.e., the one that appears in `https://projects.coin-or.org/Foo` in order to get to your project's Trac page. For example, the XML page of SYMPHONY is [here](https://projects.coin-or.org/SYMPHONY/browser/conf/projDesc.xml), and SYMPHONY's project information page is [here](http://www.coin-or.org/projects/SYMPHONY.xml).

The subversion post-commit hook handles the file copy required to make this work.


## Creating and maintaining the static webpages of a project

A project manager may wish to create "static" pages, i.e., pages that are not part of Trac's wiki system, not editable by anyone but themselves. To facilitate this, for every new project in the root of the svn repository of the project a directory named "`html`" is created, with one single "`index.html`" file in it. This file contains a simple redirect to the trac pages. *Whenever something is committed to the `html` directory the content of the directory is mirrored on the web* and is available at www.coin-or.org/PROJECT. So the default index.html just simply says that the home of the project lives in trac and redirects there. If the PM creates a new "`index.html`" then that will be displayed. The COIN-OR css (cascading style sheet) definitions are available to those who want to create nice pages here. For an example for how to use them look at the source of http://www.coin-or.org/CppAD.

The subversion post-commit hook handles the file copying required to make this work.


## Scripts and Logs

For the benefit of the curious, the scripts that run every night on the server can be found at http://www.coin-or.org/Update/Scripts. The update.sh script is invoked by cron, the rest is invoked by update.sh. Logs of update.sh are available for the past two weeks at http://www.coin-or.org/Update/Logs.
