
 It is possible to download a large set of the COIN-OR Projects and build them all simultaneously using CoinAll for the package name. For those who are used to the "old" CVS directory structure, this is a way to create something that is similar.

*Warning:* CoinAll will download the latest version of all projects. They are not guaranteed to work well together! This may cause problems for compiling or running the codes. If you have never used COIN-OR packages and are just looking around, you should probably *not* download CoinAll. This is probably the most confusing of all the COIN-OR packages. You will have a better experience downloading one of the [other packages](http://www.coin-or.org/projects.html). 

To get the code for all the projects in CoinAll via subversion use the following commands 
```
svn co https://projects.coin-or.org/svn/CoinAll/trunk  COIN
cd COIN
svn co --ignore-externals https://projects.coin-or.org/svn/MSVisualStudio/trunk MSVisualStudio
```

This will download the following COIN-OR projects:
 * Alps
 * Cbc
 * Cgl
 * Clp
 * CoinUtils
 * Data
 * Dfo
 * DyLP
 * Ipopt
 * MSVisualStudio
 * multifario
 * NLPAPI
 * Osi
 * Ots
 * Smi
 * SYMPHONY
 * Vol

Using the package CoinAll is a good solution for:

 1. Project managers to check that everything in their project is compatible with the most recent revisions of other projects. 
 1. Users that wish to have a large set of COIN-OR projects and will probably not update frequently.
 1. People who want to duplicate the directory structure from the old CVS repository for linking with legacy projects.

The directory structure will be similar to what it was under CVS and user codes built with the previous versions of COIN should continue to work. If you choose to download CoinAll be aware that:

 1. There will be a long download time.
 1. There will be a long configure and compile time.
 1. Since you are downloading the most recent version of a lot of COIN-OR projects there may be inconsistencies.

Once you have downloaded the source code, it should build according to the instructions provided [here](https://projects.coin-or.org/BuildTools/wiki).


## Coin(almost)All

If you have a good understanding of COIN software, know the projects you want, and are comfortable with subversion, here's how to be a bit more selective.
Use the command
```
svn co --non-recursive https://projects.coin-or.org/svn/CoinAll/trunk  COIN
```
to check out the top level of CoinAll. Edit the
[Externals file](./pm-svn-externals) so
that it includes exactly the projects you want, then run the commands
```
svn propset svn:externals -F Externals .
svn update
```
to check out the projects you've selected. Be a bit careful. In addition to the subdirectories created for projects listed in the `Externals` file,
there may be other subdirectories you'll want (for example, the `doxydoc`
subdirectory). You will need to specifically request these; subversion remembers the initial `--non-recursive` and will not add subdirectories until you ask for them.
You can check to see what you're missing with
```
svn ls http://www.coin-or.org/svn/CoinAll/trunk
```
Note that subdirectories loaded from other repositories as externals really don't exist in CoinAll and will not be included in the `svn ls` output.


## Links to relevant pages

The main BuildTools page

https://projects.coin-or.org/BuildTools/wiki/

Other useful pages

 * [Obtaining the source code](./user-download)
 * [Understanding the directory structure](./user-directories)
 * [Preparing the compilation](./user-configure)
 * [Compiling and installing the package](./user-compile)
 * [Linking your code with COIN libraries](./user-examples)
 * [Troubleshooting](./user-troubleshooting)
 * [CoinAll -- downloading all of the Coin Projects](./user-coinall)
 * [Subversion externals](./pm-svn-externals)
