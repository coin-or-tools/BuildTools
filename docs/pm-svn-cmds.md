
 Below we list the subversion command line commands that a typical developer has to know about.  Online help is available using `svn help`.  A detailed description of each command can be found in the "Subversion Complete Reference" chapter of the subversion book, at [http://svnbook.red-bean.com/nightly/en/svn.ref.html](http://svnbook.red-bean.com/nightly/en/svn.ref.html) 


*Terminology*: [COIN Package vs COIN Project](./user-directories#Nomenclature)


## Subversion Configuration File

It is a good idea to change your local subversion configuration to set svn properties (see below) automatically for certain files, so that the properties are correctly set when you add a file.  For this purpose, *you should copy the following lines to the end of your `$HOME/.subversion/config` file* (with the Windows [TortoiseSVN](http://tortoisesvn.tigris.org) client this file is located at `%APPDATA%/Subversion`).

```
[miscellany]
enable-auto-props = yes
[auto-props]
*.c        = svn:eol-style=native;svn:keywords="Author Date Id Revision"
*.cpp      = svn:eol-style=native;svn:keywords="Author Date Id Revision"
*.h        = svn:eol-style=native;svn:keywords="Author Date Id Revision"
*.hpp      = svn:eol-style=native;svn:keywords="Author Date Id Revision"
*.f        = svn:eol-style=native;svn:keywords="Author Date Id Revision"
*.F        = svn:eol-style=native;svn:keywords="Author Date Id Revision"
*.sh       = svn:eol-style=native;svn:executable
*.txt      = svn:eol-style=native
*.zip      = svn:mime-type=application/zip
*.tgz      = svn:mime-type=application/x-gzip
*.gz       = svn:mime-type=application/x-gzip
Makefile   = svn:eol-style=native;svn:keywords="Author Date Id Revision"
Makefile.in = svn:eol-style=native
Makefile.am = svn:eol-style=native;svn:keywords="Author Date Id Revision"
configure.ac = svn:keywords="Author Date Id Revision"
Externals  = svn:eol-style=native
```



## SVN Commands


### svn help

Lists all available `svn` commands.  *Help for a specific command* `cmd` can be obtained with `svn help cmd`.


### svn checkout (short form: svn co)

*Checks out a directory plus all subdirectories* from a subversion repository.  The COIN repositories are available from the URL `https://projects.coin-or.org/svn`.  For each COIN package, say `Pkg`, you obtain everything in the package (including all branches and tags) by specifying "`svn co https://projects.coin-or.org/svn/Pkg/`"; if you only want a part of the code, such as the current official release (by convention in the subdirecory `trunk`, you type `svn co https://projects.coin-or.org/svn/Pkg/trunk`.  Usually, you should specify the target directory where you want your local copy of the code to be stored (such as `Coin-Pkg`).  If the target directory is omitted, the source code will be installed in a subdirectory with the name of the last directory in the URL, i.e., `trunk` in the example above.

If you want to specify a specific revision that you want to check out, you can do this using the `-r N` flag, where `N` is the revision number.

By default, `svn checkout` will download files from other subversion repositories, if [svn externals](./pm-svn-externals) are defined for directories in the specified URL, and will recurse to further locations if externals are defined there.  If you don't want to download any externals, specify the `--ignore-externals` flag.

The COIN svn repository is set up in a way, so that everybody can download files, without having to provide a password.  You will have to provide your id and password once, if you want to do a write action, such as `svn submit`.


### svn update (short form: svn up)

*Updates the local copy* to the current version of the current directory and subdirectories, or of a specific directory, if this directory is given as argument (e.g., `svn up subdir`).  If you have made changes in your local copy, subversion will try to merge the difference between the previously checked-out version and the new one.  If it has trouble doing that, it will notify you of a _conflict_.  You should then have a look at the files for which a conflict occured and fix it; the location of a conflict is marked by `<<<` and `>>>` strings.
It is important that you _resolve_ the conflict, either by using `svn resolved` or `svn revert`, because you will otherwise not be able to commit your changes.

The `-r N` flag allows you to update your local copy to a specific revision number (`N`).  To avoid recursion into subdirectories during the update, use the `-N` flag.  The `--ignore-externals` flags tells subversion to ignore the externals.


### svn switch (short form: svn sw)

This command is similar to `svn update`, but you use it to *switch the local copy to a different path in the subversion repository*.  For example, if you checked out a particular point release into a certain directory earlier, you can use this command to change your local copy to a newer point release.  It is the way to move a working copy to a branch or tag within the same repository.


### svn status (short form: svn st)

If you want to find out the *status of the files in your local copy*, you use this command.  This will tell you, which files and directories in your local copy have local modifications, which files are marked for addition or deletion, etc.  To see a list of the symbol that show up for the files, type "`svn help status`", or look read about it in the [subversion book](http://svnbook.red-bean.com/nightly/en/svn.ref.html).


### svn info

This command is used to *obtain information about a file and directory in the local copy*.  For example, "`svn info filename`" shows you the URL to the corresponding file in the subversion repository, what the current subversion revision number is, and at which subversion revision number this file has last been changed.


### svn commit (short form: svn ci)

This command it used to *commit your local modifications to the subversion repository*. If you enter a file or directory name as argument, only the file or the directory (and everything below it) will be committed.  If you omit this argument, the current directory and everything below it will be submitted.  To suppress the recursion into subdirectories, you can specify the `-N` flag.

You should enter a message that describe the changes that you made, so that later on you can see in the subversion history what has been going on.  You can enter the message on the command line, using the "`-m`" flag, followed by the message (in quotes).  If you omit the `-m` flag, you default editor will open for you to enter the message.

*Note*:  For most COIN packages, we use [subversion externals](./pm-svn-externals) to obtain dependencies.  The `commit` command does not automatically recurse into externals; therefore, you have to do a `commit` by hand.  *Make sure you are not committing code to an external with a specified version number in the externals definition!*


### svn diff (short form: svn di)

To *see the details of local modifications in your working copy*, you use this command.  You can specify a file or directory name as argument, to narrow down, which modifications you want to have shown.  Again, the `-N` flag can be used to suppress recursion into subdirectories.  You can also see the differences of your local copy with respect to a particular revision in the repositry, by using the "`-r N`" flag, where `N` is the specific revision number.


### svn revert

If you want to *restore the current version in the repository* and undo your local modifications, you use this command.  By default, it reverts the modifications only made to a file or directory given to the command as argument; if the argument is omitted, only the current directory is reverted.  If you want to revert more than just one file or directory, you can use the "`-R`" to enable the recursive action of the command.


### svn resolved

This command is necessary to tell subversion that you *resolved a conflict that occured earlier during an update or a merge*.  Unless you _resolve_ those conflicts, you will not be able to commit local changes of the files and directories, for which the conflict occurred.  A conflict is also resolve automatically, if you use the `revert` command.


### svn add

You use this command to *add new files and directories* to the repository.  You need to give subversion the name(s) of the file(s) or directory(ies) as argument.  *Note that the command acts recursively on directories*, unless you use the "`-N`" flag.  The file or directory must exist when you use this command.  The file or directory will only be added to the repository when you do a `svn commit`.


### svn remove (short form: svn rm)

This command *deteles a file or directory (including content) in your local copy and marks those files for deletion*.  The files will be deleted in the repository when you type "`svn commit`" the next time.  In your local copy, directories will actually remain there, until you commit, but they will be empty.  _Do not delete them by hand!_.  *You should always use this command, and never the shell `rm` command directory on version controlled files and directories.*   Note that you can can give only one argument at a time to this command, i.e., in order to delete several files, you will have to use this command for each one, e.g., using the `xargs` UNIX command.


### svn copy (short form: svn cp)

To *copy a version controlled file in your local copy including its repository history*, you use this command. 


### svn mkdir

This command *creates a new version controlled subdirectory* in your local copy.  You can later add files in this new directory with *svn add*.


### svn merge

This command is used to *merge changes in a different part of the repository (like a branch) into the local copy*.  Please see the [wiki page on branches](./pm-svn-branches) to see how you can use it properly.


### svn export

This command is essentially the same as `svn checkout`, except that it skips all subversion-internal stuff, and you won't be able to do any further revision management commands in the obtained directories.  This command is used to *extract files from the repository with the purpose of given the obtained files to someone else* (e.g., in the form of a tarball).


## Subversion Properties

To understand the next set of commands you need to know what [Subversion Properties](http://svnbook.red-bean.com/nightly/en/svn.advanced.props.html) are.  A subversion property is something associated with a file or a directory.  In principle, you can pick any property name and any content.  However, there are special subversion properties, that tell subversion some details about the file or directory.

 * *svn:executable*: If this property is set (with or without a value), subversion knows that this is an executable file, and will make it executable when you check it out.  Note, when you want to mark a file as an executable file, you simply need to set this property for this file, and subversion will automatically make it executable in your local copy.
 * *svn:eol-style*:  This property should be set to the value *native* for any text file.  This way, it will be adapted correctly at a checkout to have the correct line-end bytes (which differ for example between UNIX and Windows systems).
 * *svn:externals*: This is a property that can be set for directories, and it defines [subversion externals](./pm-svn-externals).
 * *svn:mime-type*: This property, set for a file, tells subversion the MIME type of the file.


### svn proplist (short form: svn plist)

This command takes as argument the name of a file or directory, and *lists all properties* given to this file or directory.  By default, you only see the names of the properties, without their values.  If you want to see also their values, use the "`-v`" flag.


### svn propget (short form: svn pget)

This command *tells you the value for a specific property for a file or directory*.  As first argument, you need to specify the name of the property (e.g., `svn:externals`), and as second argument the name of the file or directory.


### svn propset (short form: svn pset)

With this command you can *set the value of a specify property for a file or directory*.  As the first argument, you need to specify the name of the property, then the value of the property (use quotation if this has more than one word), and finally you need to specify the name of the file or directory.  You can also provide the value as the content of a file, say `FileName`, in which case you omit the value argument, and use the "`-F FileName`" flag instead.  In COIN, we use this to assign [subversion externals](./pm-svn-externals).


### svn propdel (short form: svn pdel)

Finally, you can *delete a specific property of a file or directory*.  As first argument, you specify the name of the property, and then the name of the file or directory.