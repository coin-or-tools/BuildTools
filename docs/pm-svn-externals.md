
 *Externals allow subversion to download additional packages from other subversion repositories.*  For example, the COIN project `Clp` requires the COIN project `CoinUtils` to be compiled.  Therefore, the `Clp` repository has externals defined so that `CoinUtils` is automatically downloaded when a user checks out `Clp`.


## Basics

Externals are defined as a [subversion property](./pm-svn-cmds#SubversionProperties) associated with a directory in a subversion repository (with the name `svn:externals`).  If someone checks out such a directory, the corresponding externals (defined using URLs) are also checked out, into subdirectories of that directory.  The names of those subdirectories, as well as the URL, are defined in the `svn:externals` property.  It is possible to specify a specific revision number for an external.  This helps us in COIN to ensure that people get a compatible version of a dependency --- the latest development version in the `trunk` of a dependency might not work with the code of the package one is trying to download and compile, if the development of the dependency has introduced incompatible changes.  Also, we can ensure in this way that point releases will always obtain the same version of their dependencies.

Externals are checked out recursively, _i.e._, if there is an `svn:externals` property defined in a directory downloaded for an external, it is also downloaded.  One can suppress the checkout (or the action of other `svn` commands) of externals by specifying the `--ignore-externals` flag.


## Externals in COIN

*In COIN, we use externals mainly to ensure that COIN packages which require other COIN packages obtain those packages automatically.*

*Our policy for managing externals in COIN is that we put a file called `Externals` into a directory. The `svn:externals` property for the directory is then set by manual execution of the `svn propset` command.*

For example, the [Externals file in the base directory for the 1.3.3 point release of the Clp package](https://projects.coin-or.org/Clp/browser/releases/1.3.3/Externals?format=raw) looks like this:

```
MSVisualStudio -r83  https://projects.coin-or.org/svn/MSVisualStudio/trunk/ExternalsDirs/Clp
BuildTools    https://projects.coin-or.org/svn/BuildTools/releases/0.5.1
Data/Netlib   https://projects.coin-or.org/svn/Data/releases/1.0.0/Netlib
Data/Sample   https://projects.coin-or.org/svn/Data/releases/1.0.0/Sample
CoinUtils     https://projects.coin-or.org/svn/CoinUtils/releases/1.0.0/CoinUtils
```

The first entry in each row specifies the directory (relative to the current directory) into which the external is to be placed (this can specify several levels of subdirectories).  After this, one can optionally specify the revision number of the dependency code that is to be obtained using the `-rN` flag, where `N` is the revision number.  The last column is the URL that specifies the location of the dependency in a repository.


## Important Considerations For Externals

*It is [mandatory](./pm-svn-releases) that the externals for a point release in a `releases/` subdirectory specify dependencies that do not change at any later point in time*, so that the original [point release](./pm-svn-releases#WorkingWithPointReleases) can always be recreated.  _We have no mechanism in place that enforces this, so we rely on the project manager's discipline to adhere to this convention._

In the above example we see that all externals have been set to things that are not going to change at some later point in time:  By [convention](./pm-svn-releases), subdirectories in the `releases/` directory for each COIN project are [tags](./pm-svn-branches), _i.e._, they should never be changed once they have been created. Pointing to specific `releases/` subdirectories is recommended.  If, for some reason, the required code is not available in a `releases/` subdirectory, the externals definition _must_ specify a particular subversion repository revision number using the `-r` flag, as shown in the `MSVisualStudio` entry above.


## Manipulating Externals

To see the value of a property (such as `svn:externals`) one uses the `svn propget` command.  For example, to see the current value set for the externals in the `Clp` base directory, move into the `Clp` base directory and issue the command

```
svn propget svn:externals .
```

If you want to change the value of a property, you use the `svn propset` command.  In COIN, we find it good practice to use an Externals file, so that users who do not have `svn` can easily see the dependencies. Changing external dependencies is a three-step process:
  1. Edit the `Externals` file to modify, add, or remove lines specifying external dependencies.
  1. Use the `Externals` file to update the `svn:externals` property with the command
  ```
svn propset svn:externals -F Externals .
```
  The `-F` flag tells `svn` to take the content of a file (in this case, `Externals`) as the value of the property to be set. That final ``.`' is important! The `svn propset` command requires that you explicitly specify the directory where the property change is to be applied. 
  1. Once the `svn:externals` property has been updated, the changes will be applied at the next `svn update` command: changed dependencies will be updated, new dependencies will be downloaded, and dependencies removed from the `svn:externals` property will be removed from subversion's records. (However, the directories must be removed by hand, after you've run `svn update`.) *Heads Up:* You must commit the whole directory to make the change in the repository. If you just commit the Externals file (like I did!), the property will not be set, because the property is associated with the directory (not just the file). 

Finally, if you decide to completely eliminate externals in a directory, you should delete the `Externals` file, and delete the `svn:externals` property with

```
svn propdel svn:externals .
```

*Note:* If you have configured your local copy with the `--enable-maintainer-mode` and have `svn` available on your system, the Makefiles will automatically do the `svn propset` command for you when you change the `Externals` file.  However, you will need to run the `svn update` command by hand.

Keep in mind that subversion knows nothing of the COIN convention for using an Externals file.
Nothing will change until you run a subversion command to change the `svn:externals` property.

More information about externals can be obtained in the [Externals Definitions](http://svnbook.red-bean.com/nightly/en/svn.advanced.externals.html) chapter of the subversion book.


## Preparing Externals For A Point Release

(_There are two scripts in BuildTools that automate this process. Read [Creating New Point Release](./pm-svn-releases#CreatingaNewPointRelease) first._)

Typically, a stable version of a COIN project that depends on other COIN projects will specify a particular version (subdirectory) in the `stable/` directory of each dependency, so that a user will always receive the latest improvements and bugfixes for each dependency.  By convention, the compilation should not break; a project manager should ensure compatibility of the project's code with the externals selected for use in a particular stable version.

If you now want to create a new point release from the latest version in your stable branch, we suggest you follow these steps:

 1. Get a local copy of your stable branch (you probably have it already).
 1. Make a backup copy of your current `Externals` file
 1. For each dependency in your Externals file find the latest point release number.  You can do this for example using
 {{{
svn list https://projects.coin-or.org/svn/DepPrcjt/releases
 }}}
 where `DepPrcjt` is the name of the dependency project. (Note: the `svn list` output is printed in an unusual numerical order; not necessarily chronological order (e.g., 0.5.1, 0.5.11, 0.5.2,...where chronological order would be 0.5.1, 0.5.2, etc.)
 1. Change the entry for each external in the Externals file to point to the latest point release for the external.
 1. Update the `svn:externals` property of the directory:
 {{{
svn propset svn:externals -F Externals .
 }}}
 1. Update the local copies in your working copy by typing `svn update`.  (Note:  If you have local changes in your checked-out externals, you should first arrange with the project manager for the dependency to have your changes committed into the dependency's repository.  It is not a good idea in any case to have local modifications in your working copy of the stable branch, since you might forget to commit them back, and then a user might download a non-working dependency.)
 1. Make sure your code now still works fine:
    i. Clean everything (`make clean`).
    i. Rebuild the autotools files (`./BuildToolds/run_autotools`).
    i. Make sure (`svn status`) that the autotools rebuild '''did not change any files in the externals subdirectories.'''  If the rebuild changed, ''e.g.'', a `configure` file, it means that the dependency does not use the same version of !BuildTools that you are using.  '''This must be reconciled first'''.
    i. Rerun `configure`.
    i. Compile and install the code (`make install`).
    i. Run your tests (`make tests`) and do whatever you do to convince yourself that your project's code works correctly.
 1. If that works fine, commit what is now in your local copy into back into the stable branch of your project (`svn commit`).
 1. To confirm portability and act as a sanity test, you might want to check that the code now in your stable branch compiles and runs fine on a different machine (`svn update` and `make tests` on the other machine).
 1. Create a copy of the current version of your stable branch as a new point release, as described [here](./pm-svn-releases#CreatingaNewPointRelease).
 1. Restore your original `Externals` file from your backup created in Step 2 above and restore the previous (non-release) externals:
 {{{
svn propset svn:externals -F Externals .
 }}}
 1. Commit the restored externals to your stable branch (`svn commit`).