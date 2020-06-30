
# Understanding Subversion



Subversion (SVN) is a *version control system*.  It is the successor of CVS.  It shares many of the features and commands of CVS, but is more powerful, and some details are different.  The COIN repository is now organized by subversion.  Since the swtich-over to subversion, the code on CVS has been frozen, i.e., changes can only be made to the SVN repository.

The home page of the subversion project is [http://subversion.tigris.org/](http://subversion.tigris.org/).  A detailed manual for subversion is the Subversion Book, which can be found at [http://svnbook.red-bean.com/](http://svnbook.red-bean.com/).

If you have used CVS before and want to know how subversion related to CVS, you should look at the "Subversion for CVS Users" appendix of the subversion book at [http://svnbook.red-bean.com/nightly/en/svn.forcvs.html](http://svnbook.red-bean.com/nightly/en/svn.forcvs.html).  A major difference to CVS is that you can do most operations off-line, such as `diff`, without having to be connected to the internet.  Also, in contrast to CVS, subversion is able to properly handle revisions of directories.

On the pages behind the following links, we intend to give all the information necessary for a project manager that is necessary to maintain a COIN project.

[Basic commands](./pm-svn-cmds)

[Dealing with branches and tags](./pm-svn-branches)

[Handling svn externals](./pm-svn-externals)

