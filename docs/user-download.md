


# Downloading the Source Code

There are two ways to get source code of a COIN-OR package: Archive files or [subversion](http://subversion.apache.org). For typical users, using archive files is simplest. Archive files are available for release versions. For users interested in getting recent bug fixes without having to waiting for a new release version of the code, using subversion is required. Archive files are not available for stable or trunk versions.

The source code usually comes with the [directory structure explained here](./user-directories).

If you have problems, have a look at the [troubleshooting page.](./user-troubleshooting)

*NOTE:* If you plan to use the `configure` script and `Makefile`s, the *path to the directory into which you download or extract the source code must not contain white spaces*.


## Obtaining the Code Via Archive Files

Archive files for point releases of COIN-OR packages can be downloaded from the corresponding directories in [http://www.coin-or.org/download/source].  Their names have the form `Pgk-x.y.z.tgz` where `Pkg` is the name of the package. Selecting the largest version number (i.e. the most recent archive file) is usually the way to go.

To extract the source code from the tarball on a UNIX-like system, you go into the directory in which you want the source code directory to be created.  Then you type

```
gunzip Pkg-x.y.z.tgz
tar xvf Pkg-x.y.z.tar
``` 

If you don't like the name of the extracted base directory, you can rename it, but do not rename any directories inside the source code tree.

On Windows, you can use the standard decompression programs to extract the files.


## Obtaining the Code Using Subversion


### Getting Subversion

In order to download the code from COIN-OR via *subversion*, you need to have a subversion client installed on your computer.  On UNIX-like systems, including Linux and Cygwin, the subversion executable is usually called `svn`.  Subversion is available from [http://subversion.apache.org].  If you compile the subversion executable on your own, make sure you specify the `--with-ssl` flag when you run the `./configure` script, so that your `svn` executable is able to connect to `https://` servers.  If you already have `svn` installed on your system, you need to make sure that it is able to connect to `https://...` URLs.  You can find out if your version of `svn` supports this by typing "`svn --version`".  If it says "`handles 'https' scheme`," you are fine. 

You also have the option of using some GUI clients for subversion. We have had success with 
[eclipse](http://www.eclipse.org/) using the [subclipse plugin](http://subclipse.tigris.org/). This tool has the advantage of being cross-platform. If you prefer a tool that integrates with your operating system's file manager, you can try [ksvn](http://ksvn.sourceforge.net/) for KDE, [tortoisesvn](http://tortoisesvn.tigris.org/) for Windows, or [scplugin](http://scplugin.tigris.org/) for OS/X. Another option is [rapidSVN](http://rapidsvn.tigris.org), a cross platform stand-alone client.  


### Determining Version Number

First you need to find out which version of a COIN-OR package (say, *Pkg*) you want to obtain.  Assuming, that you want to obtain an "official" release, you can find the available three-digit version numbers by opening the URL `https://projects.coin-or.org/svn/Pkg/releases` in a browser, or by typing
```
svn list https://projects.coin-or.org/svn/Pkg/releases
```
Here and in further instructions below you need to replace the `Pkg` string in the URL above with the name of the particular COIN-OR package you want to get (such as `Cbc`, `Osi`, etc).  Also, we assume that you chose *x.y.z* as the release number you want to obtain, and you will need to replace the `x.y.z` string correspondingly (e.g., by `2.3.5`).

If you want to be nifty, you can also download the current version on a _stable branch_, or even the latest development version.  Details regarding the (recommended) release policy can be found [here](./pm-svn-releases).


### Downloading the Code

*Unix-type system (including Linux and Cygwin)*

In order to obtain the source code for a COIN-OR package (say Pkg), you go into the directory where you want to have subversion put the source code in a new subdirectory (say, Coin-Pkg).  Here, you type

```
svn checkout https://projects.coin-or.org/svn/Pkg/releases/x.y.z Coin-Pkg
```

You can choose any name for the directory where the source code should go (`Coin-Pkg` in the above example).

With this command, subversion will download all the source code and other files required to compile and run the chosen package, including code from other COIN-OR projects that are required for the compilation of the chosen package.  Note, however, that third-party source code (such as the code for the AMPL solver library) will not be downloaded and has to be obtain separately.

If you want to *update your local copy of the code at a later point* to get a later release of the package (say, `a.b.c`), you go into the downloaded base directory and use the subversion switch command:
```
cd Coin-Pkg
svn switch https://projects.coin-or.org/svn/Pkg/releases/a.b.c .
```

*Windows*

On a Windows machine, you can download the code with [TortoiseSVN](http://tortoisesvn.tigris.org/).
 * Install [TortoiseSVN](http://tortoisesvn.tigris.org/) on your system.
 * Select a directory in windows explorer where you want to place your working copy. Right click to pop up the context menu and select the command _SVN Checkout..._
```
<center>
<img src="http://www.coin-or.org/screenShotImages/tortoiseSvnCheckoutPopup.jpg" alt="TortoiseSVN Checkout Popup">
</center>
```
 which brings up the following dialog box:
```
<center>
<img src="http://www.coin-or.org/screenShotImages/tortoiseSvnCheckoutDialog.jpg" alt="TortoiseSVN Checkout Dailog Box">
</center>
```

 * In the _URL of Repository_ field enter `https://projects.coin-or.org/svn/`_Pkg_`/trunk`
 * In the _Checkout directory_ field enter the source code destination directory. The right most directory should be `Coin-`_Pkg_ where _Pkg_ is one of the COIN-OR [project names](https://www.coin-or.org/projects).

If you want to update your local copy of the code at a later point to get the latest changes then in windows explorer right click on the base directory (`Coin-`_Pkg_) to pop up the context menu and select the command _SVN Update..._
```
<center>
<img src="http://www.coin-or.org/screenShotImages/tortoiseSvnUpdatePopup.jpg" alt="TortoiseSVN Update Popup">
</center>
```


## Third Party Code

Some COIN-OR projects require (or can be enhanced by) third party code.  In that case, you will see a subdirectory `ThirdParty` in the package's base directory, with subdirectories for each third party package.  Please read the `INSTALL` or other files to learn more about this.