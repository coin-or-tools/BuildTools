
 This page describes how the [policy for versioning suggested by COIN-OR](https://projects.coin-or.org/CoinTLC/wiki/VersionsAndReleases) can be implemented within the subversion repository for your project. You might want to first read the page on [understanding branches and tags](./pm-svn-branches), or other pages for [understanding subversion](./pm-svn). Below, the string _YourProject_ is to be replaced by the name of your project.


## Overview

The purpose of the COIN-OR versioning and release system is to specify standard procedures for maintaining the code base of COIN-OR projects so that users can obtain the version of the code most appropriate for them. The recommended [subversion](./pm-svn) repository layout for COIN-OR projects includes the top-level directories `trunk/`, `branches/`, `tags/`, `stable/`, and `releases/`.

At all times, the main development line is to be contained in `trunk/`. The code in `trunk/` is not expected to be completely functional and is the "bleeding edge" of the project. At appropriate points in time, specific versions can be split off from the main development line for the purpose of declaring a stable version (see below) or implementing new features.

The `branches/` and `tags/` directories may be used at the developer's convenience. Directories under `branches/` typically contain versions of the code created to implement and test new features. The `tags/` directory can be used for storing fixed and named snapshots of code for future reference. To maintain the utility of tags, subversion usage conventions recommend that no new code should ever be committed to the `tags/` directory.

The `stable/` and `releases/` directories hold the stable versions and point releases of a project that are referenced as externals by other projects and downloaded by users.
A *stable version* is created whenever the PM wishes to declare a new version of the project. Creating a stable version means roughly that the feature set and API associated with that particular version are frozen, but the code may continue to evolve through the application of patches to fix bugs, the addition of documentation, _etc._ Such a stable version is identified by a two-digit version number (_i.e._, 5.1) and is associated with a similarly-named subdirectory in `stable/` created by branching (copying) the code in `trunk/` (see below for specific commands to be used for this purpose). Stable versions are not considered frozen when copied to `stable/`. It is intended that they continue to evolve and new code can be committed to subdirectories in the `stable/` directory. However, this evolution should generally consist of bug fixes and minor tweaking only---development of new features for future versions can continue at the same time in `trunk/`. Bug fixes applied to versions in `stable/` may also need to be merged back to `trunk/`, as appropriate (see below). 

An important notion is that declaring a new stable version is not the same as creating a new *point release*. A point release is a fixed snapshot of a stable version intended for distribution in source and/or
binary form (_i.e._, a tarball). Whenever the PM deems it appropriate (usually when the current stable version, along with previously applied patches, passes some sort of litmus test established by the PM), a *point release,* identified by a three-digit release number (_i.e._, 5.1.1) can be copied from `stable/` to `releases/`. The first two digits indicate the stable version and the last number is the *patch level*.
Such point releases are frozen and are never changed. If a bug is found in a point release, it gets fixed in `stable/` and a new point release is created (_i.e._, 5.1.2) when appropriate.

To reiterate, the point releases are what we will distribute as tarballs and what we will use to create binaries because they are fixed versions that do not evolve. Therefore, if someone finds a bug in a binary or a
version created from a tarball, we will be able to recreate the exact version of the code they are using by checking out the appropriate point release from the repository. There is probably no reason why anyone other than a developer trying to fix a bug would want to check out something from `releases/`. Because the point releases never change, there is no point in using subversion because `svn update` will not retrieve the bug fixes. To update, a user would have to manually check out a new point release, but then the user might just as well download the tarball since that is easier. 


## What to Tell Users

It is up to each developer to determine exactly what they will recommend to their users as far as how to obtain the source code or binaries for their project. However, here are some suggested categories of users and the recommended way for them to get the codes in COIN-OR.

 1. Casual users and those who do not want to be bothered with frequent updates or installing subversion should download the latest tarball (point release) in either source or binary form. To report bugs, they can use the three-digit release number of the tarball they downloaded. To get a new version containing a bug fix (or an added capability they want to use), they will need to download a new tarball. Such users can expect the version they check out to be mature and mostly bug-free.
 1. Power users who want to get updates and bug fixes as soon as they are committed, but want a stable API that will not change out from under them, should use subversion to check out the latest stable release in `stable/*.*`. These users would have to report bugs based on the subversion version number they are using (a little more of a pain for the developers), but can get fixes using `svn update`. These users may experience a slightly bumpier ride, as there may occasionally be incorrect patches committed to `stable/` and other minor difficulties. Most of the time, however, this code should be mature and stable.
 1. Developers and really adventurous power users who want the bleeding edge can check out `trunk/`. This should probably not to be encouraged for users and certainly the PM won't be expected to be too responsive to bug reports from people using the code in `trunk/`, since it is not intended to be bug-free.


## Setting up your Repository

First, make sure that the directories `trunk/`, `stable/`, `releases/`, and `conf/` exist for your project. An easy way to do this is to load the webpage `https://projects.coin-or.org/svn/YourProject` (_e.g._, https://projects.coin-or.org/svn/BuildTools).  This lists the base directories in your project.

If a directory, say, `releases/`, does not yet exist, you can create it directly in the repository with the `svn mkdir` command, giving it the full URL.  For example:

```
svn mkdir https://projects.coin-or.org/svn/YourProject/releases \
           -m "creating releases directory"
```


### Moving Branches

Some of the existing COIN-OR projects had a development branch `branches/devel/`.  With the transition to the new release policy described here, this branch should now become `trunk/`.  The easiest way to do this is to first delete the old `trunk/` directory in the subversion repository (assuming that the previous "stable release" content has been copied into an appropriate place in `stable/` and/or `releases/`), and then to move `branches/devel/` to `trunk/`:

```
svn rm https://projects.coin-or.org/svn/YourProject/trunk \
           -m "deleting trunk (so that we can move branches/devel there)"
svn mv https://projects.coin-or.org/svn/YourProject/branches/devel \
           https://projects.coin-or.org/svn/YourProject/trunk \
           -m "moving branches/devel to trunk"
```


## Working with Stable Versions

The idea of a `stable/x.y/` branch is that you maintain a stable line of your code here that can be used by a user who wants to be up-to-date with your "official" version of version `x.y`.  You start with a version that you think is good enough to be made "official".  Later, you may update the code in a particular `stable/x.y/` branch to include bug fixes, or because you've made some improvements.  Typically, when you fix a bug reported by a user, you would fix it in the corresponding stable release and tell the user how to get it.  When you're confident it works, you should consider a new point release (see below).

Note: We [strongly suggest](https://projects.coin-or.org/CoinTLC/wiki/VersionsAndReleases) that you create a new stable branch when the user interface for your code changes in such a way that users of your code would have to change their code in order to use the new interface.  By creating a new stable branch, a user will not find any bad surprises when updating his/her local copy of a stable branch, and can instead switch to a new stable branch later, whenever (s)he is ready.



### Creating a New Stable Version

You usually create a new stable branch with a version number `x.y` (_e.g._, `2.3`) from some version of your code that exists in the repository.  Typically, you would have been working in `trunk/` (where the active development takes place), and want to release the current `trunk/` version in the repository as a new stable branch.

*It is strongly recommended* that you use the `prepare_new_stable` and `commit_new_stable` scripts provided in BuildTools. These scripts will automatically make the changes to configuration files and externals required to conform with COIN-OR standards for stable branches.
The first script, `prepare_new_stable`, does the following things for you:

 * automatically determines the next minor revision within the current major revision
 * checks out a clean copy of the trunk (without externals)
 * creates a `Dependencies` file from the `Externals` file, if one does not already exist
 * updates `Dependencies` to reference the most recent stable branch of each external, then sets `svn:externals` to the most recent release
 * updates version information in your `configure.ac` and `ProjConfig.h` files
 * checks out the code for the externals and checks to see if they are using the same version of BuildTools
 * uses the "get.*" scripts to download any ThirdParty code
 * executes `run_autotools` to rebuild configuration files
 * runs the configure script and compiles the code
 * runs the unit test

The result is left in a local directory. Once you're satisfied, use the `commit_new_stable` script to commit the new stable branch to the repository. It will
 * commit the stable branch candidate to trunk
 * perform a repository-side copy of the trunk into the new stable branch
 * restore the local copy to its original state by backing out all changes
 * commit the restored local copy to trunk, restoring trunk to its original state

The scripts have extensive help texts. There are options to bump the major version and to control the handling of externals and checks for BuildTools mismatches.

If, for some reason, you elect to create a new stable branch by hand, here are rough instructions. A new stable branch with the chosen version number is created in the repository using the `svn copy` command.  In order to create stable branch `2.3` from `trunk/` you could use

```
svn copy https://projects.coin-or.org/svn/YourProject/trunk \
           https://projects.coin-or.org/svn/YourProject/stable/2.3 \
           -m "Creating new stable branch 2.3 from trunk (rev 533)"
```

*NOTE: In the commit message you should always record the subversion revision number from which you created the new branch.*  This information is essential for merging and some other repository operations. To find out the revision number, you can use the `svn info` command.  For example, to determine the revision number in the above example, you could have used

```
svn info https://projects.coin-or.org/svn/YourProject/trunk
```

and looked at the line that starts with "`Revision:`".


### Maintaining a Stable Version

To change the content of a stable version, you work with it as usual: creating (checking out) a local copy of the code in that branch, making changes there (directly by editing, or [by using svn merge](./pm-svn-branches) to include changes made in a different version in the repository, such as `trunk`), and finally submitting the changes back to the repository.


## Working With Point Releases

The `releases/` directory is the place where a user can find particular, numbered releases.  The tarballs distributed on the COIN-OR website are created from these releases.  It is mandatory that checking out a release from this place in the repository always provides the identical code, so that it's possible to restore older versions (_e.g._, to reproduce a bug reported by a user).  In this context you need to be careful if you use `svn:externals`.  *Once a release has been created it must not be changed! *


### Creating a New Point Release

Typically, you would have a version of your code in a stable branch, say `stable/2.3/`, which you now want to make an official release.  *Remember, it is mandatory that one can recreate exactly the same version in the future*, _i.e._, you should not change anything in a point release after you set it up.

*It is strongly recommended* that you use the `prepare_new_release` and `commit_new_release` scripts provided in BuildTools. These scripts will automatically make the changes to configuration files and externals required to conform with COIN-OR standards for releases (including libtool library versioning).
The scripts have extensive help texts.

The first script, `prepare_new_release`, does the following things for you:

 * automatically determines the next patch level (release) within the specified minor revision (stable branch)
 * checks out a clean copy of the stable branch (without externals)
 * sets `svn:externals` to the most recent release of each external, based on the stable branch specifications in the `Dependencies` file
 * updates version information in your `configure.ac` and `ProjConfig.h` files
 * checks out the code for the externals and checks to see if they are using the same version of BuildTools
 * uses the "get.*" scripts to download any ThirdParty code
 * executes `run_autotools` to rebuild configuration files
 * runs the configure script and compiles the code
 * runs the unit test

The result is left in a local directory. Once you're satisfied, use the `commit_new_release` script to commit the new release to the repository. It will
 * commit the release candidate to the stable branch
 * perform a repository-side copy of the stable branch into the new release
 * restore the local copy to its original state by backing out all changes
 * commit the restored local copy to the stable branch, restoring the stable branch to its original state

The scripts have extensive help texts. There are options to control the handling of externals and checks for BuildTools mismatches.


If, for some reason, you elect to create a release by hand, the simplest way is to use "svn copy" similar to the example above for manual creation of a new stable branch. To create release `2.3.2` from stable branch `2.3` you could use

```
svn copy https://projects.coin-or.org/svn/YourProject/stable/2.3 \
           https://projects.coin-or.org/svn/YourProject/releases/2.3.2 \
           -m "Creating new release 2.3.2  from stable branch 2.3 (rev 533)"
```

*NOTE: In the commit message you should always record the subversion revision number from which you created the new branch.*  This information is essential for merging and some other repository operations. To find out the revision number, you can use the `svn info` command.  For example, to determine the revision number in the above example, you could have used

```
svn info https://projects.coin-or.org/svn/YourProject/stable/2.3
```

and looked at the line that starts with "`Revision:`".


### Tarball Creation

For information on the automatic tarball creation look [here](./pm-svn-server).