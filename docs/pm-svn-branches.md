
 The detailed description of this topic in the subversion book can be found [here](http://svnbook.red-bean.com/nightly/en/svn.branchmerge.html).

A *_tag*_ is a name that is given by the project maintainer to a particular revision of the code in a repository, so that one can easily retrieve it without having to specify a revision number.  Typically, one might want to give tags to stable versions of the code.

A *_branch*_ is a specific "line" of code development.  One always has a main branch, which contains the main development branch.  In subversion, this main development branch is by convention called *_trunk*_.  But it is a very good idea, and we highly recommend this, to maintain stable branches, which allow the common user to work with a recent version of the code, without being disturbed by every single change and intermediate unstable version.  The recommended way to handle a project's repository in terms of stable branches and official point releases is discussed [here](./pm-svn-releases.md).

In the trunk development branch one can safely continue to work, possibly sharing the changes with other developers, and if a new stable version has been obtained, the changes can be *_merged*_ to a stable branch.

If you have used CVS before, you know the notion of "branches" and "tags".  In CVS, there are specific commands to organize tags and branches, which can sometimes be confusing.  It is important to understand that subversion works in a different, much easier way.

Subversion itself does not know about tags and branches.  Instead, one can use the fact that subversion (in contrast to CVS) also keeps revisions of directories, just as for files, and that an `svn copy` retains the change history for copied files and directories.

*Project managers are encouraged to follow the [COIN-OR release management policy](./pm-svn-releases.md).*  In this case, the directory structure in the svn repository at the very base of a project (say, `Prjct`), is
```
Prjct ---- trunk
  |
  |------- stable
  |
  |------- releases
  |
  |------- branches
  |
  |------- tags
  |
  -------- conf
```
Here, `stable` contains subdirectories `x.y` with 2-digit release numbers, indicating a *stable branch*, and `releases` contains subdirectories `x.y.z` with 3-digit release numbers, indicating *tags for stable point releases*.  The latest development is meant to take place in `trunk`.  The directories `branches` and `tags` are meant for further branches and tags, respectively, and `conf` contains some configuration files.

You can find out more about the subversion commands used here by typing `svn help command`, or look at our short documentation [here](./pm-svn-cmds.md).


## Creating New Branches and Tags

In the `trunk` directory should be the current main development version of the project, i.e., the stuff that the project manager and other developers work on.  If you want to create a new branch, say a new stable branch called `stable/2.5` from the current `trunk` version, you use `svn copy` to create a copy of `trunk` in a new subdirectory (in the svn repository) under `stable`.

You can do this without having to use a local copy of the entire repository by specifying URLs for both the source and the destination of the copy.  For the `Prjct` example project, you would do this with

```
svn copy https://projects.coin-or.org/svn/Prjct/trunk \
         https://projects.coin-or.org/svn/Prjct/stable/2.5 \
         -m "Creating branch stable/2.5 from revision 450"
```

Since this is a write action to the repository, you will need to provide a message that logs the change you are doing (this is what the "`-m`" flag is for).  If you omit this flag, your default editor will open and ask you to provide the log message.  *Here it is highly recommended to include the current repository revision number of the repository in the commit message.*  You can use the `svn info` command to determine this number; in case of the above example you can do:
```
>$ svn info https://projects.coin-or.org/svn/Prjct/trunk
Path: trunk
URL: https://projects.coin-or.org/svn/Prjct/trunk
Repository Root: https://projects.coin-or.org/svn/Prjct
Repository UUID: ef2a96d0-92f8-0310-a3c1-cdaa70078a94
Revision: 450
Node Kind: directory
Last Changed Author: johndoe
Last Changed Rev: 443
Last Changed Date: 2006-07-20 10:49:03 -0400 (Thu, 20 Jul 2006)
```
Look for the line starting with "`Revision:`" in the output.

If you now want to check out the stable branch `stable/2.5` to be able to make changes and submit them back to the branch, you specify the corresponding directory in the repository in your `svn checkout` command, such as

```
svn co https://projects.coin-or.org/svn/Prjct/stable/2.5 Coin-Prjct-stable-2.5
```

This will create a subdirectory `Coin-Prjct-stable-2.5` (or however you name it) in which you can work.

At a later point you probably want to transfer changes between branches, for example, from the development branch `trunk` to a stable branch.  For this you use `svn merge` as described further below.

Just as you create new branches with `svn copy`, you can create a tag by copying the version you want to tag into a subdirectory in the `tags` subversion repository directory.  For example, say, you decided that what you want to make a new point release (number 2.5.6) from what you have currently in your stable branch `stable/2.5`.  Then you could issue the command
```
svn copy https://projects.coin-or.org/svn/Prjct/stable/2.5 \
         https://projects.coin-or.org/svn/Prjct/releases/2.5.6 \
         -m "Creating releases/2.5.6 from stable/2.5 (from rev 457)"
```

In contrast to CVS, you could now make modifications to the tagged version of your code (since subversion handles tags by convention simply as internal directories), but since tags are supposed to be a snapshot of the code at a particular time, that would be very bad practice.


### Summary

The subversion repository is essentially a large file system with revision control.  One can check out directories (including subdirectories) at any level of that file system.  By convention, the root of the file system has the structure as in the above diagram.  The *trunk* is the main development branch of the project, subdirectories in the *stable* and *branches* directories correspond to branches, and subdirectories in the *releases* and *tags* directories correspond to tags.


## Merging Branches

*Please make sure you read the [page about the COIN-OR policy of handling releases and stable branches](./pm-svn-releases.md).*


### Synchronizing two branches

After you worked on your development branch (`trunk`) for a while, you might want to merge the changes you made into a stable branch, say `stable/2.5`.  For this, you use the `svn merge` command.

An `svn merge` conceptually does an `svn diff` to get the difference between two copies of the code, and applies the difference as patch to the work copy, in which `svn merge` is performed, but it is more powerful than just obtaining the `diff` output and applying the patches yourself, since it will also rename and create files and directories, when this was within the changes that were done between the two copies.

As an example, assume that the current content in `stable/2.5` was the content of the development `trunk` corresponding to the repository revision 450 (e.g., you copied the `trunk` to `stable/2.5` at that revision, or you synchronized the two with a previous merge operation).  Now you want to update `stable/2.5` to the current state of `trunk`.  First, you need to have a local working copy of `stable/2.5`.  In the base directory of this working copy, you would then type
```
svn merge -r 450 https://projects.coin-or.org/svn/Prjct/trunk
```
This will merge then changes that occurred in `trunk` since revision 450 into your local copy (of `stable/2.5`).  If you have made no local modifications in `stable/2.5` (and it is a good idea do keep it that way), everything should just work fine.  If you have local modification in your `trunk` copy, you might encounter conflicts that you have to resolve, just as if you have done an `svn commit` and encountered conflicts (see the description of `svn commit` [here](./pm-svn-cmds.md)).

Note: Once you have successfully synchronized `stable/2.5` with `trunk`, you should commit the changes in `stable/2.5` and *include the current repository number in your commit message, so that you know the beginning point for your next merge operation.*


### Applying a changeset to a different branch

Another typical example is that you are working on some branch (say, `trunk`), and you are committing a change to this branch (such as a bugfix), which you also want to apply to another branch (say, you stable branch `stable/2.5`).  If the committed change for `trunk` brought your subversion repository revision number from N to N+1 (say, from 465 to 466), you can then type
```
svn merge -r 465:466 https://projects.coin-or.org/svn/Prjct/trunk
```
in your local working copy of `stable/2.5`.  This will try to merge the changeset 466 into your local copy.  If the files to which changes are applied have not diverged too much, this should work without problems, but you should check in any case if the patch is applied correctly.