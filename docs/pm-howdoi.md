= How Do I ...? = 


## How do I (projectManagerX) give svn write access to someone (personY)?

A: Just a few easy steps...
  1. Ask for personY's uid.  If they don't have one, they need to create one by registering on Trac. There's a little red "Register" word on the upper right-hand-side of the Trac page. SVN and Trac currently use the same file for authentication.
  1. The system requires a CSRO on file for everyone with write-access. Check to see if personY has a CSRO on file by looking at the [list of people with CSROs on file](http://www.coin-or.org/management/contributors.html).  If personY is not on the list, ask personY to fill out the [CSRO form](http://www.coin-or.org/management/forms/csro.pdf) and send it to secretary`@`coin-or.org. The secretary will update the web list. 
  1. If personY just submitted an CSRO, their uid needs to be manually added to the file on the server of people with CSROs. (This file is how we automatically ensure only people with CSRO's on file are making commits to the repository). Currently, only Laci Ladanyi and Matthew Saltzman have permissions to edit this file. Send a request to Laci or Matt with the uid. 
  1. Edit the ["perms.txt" configuration file](./pm-svn-server#Configurationfiles).


## How do I update my project's .xml file (e.g., http://www.coin-or.org/projects/Cgl.xml) ?
A: You don't! It's automatic. You don't need to do anything other than commit the new stable/release version of your project. It works as follows:

  1. Your `Cgl/conf/projDesc.xml` file is the same as the source code http://www.coin-or.org/projects/Cgl.xml (Cgl.xml is not generated it is just a copy of projDesc.xml) and this xml file is what the browser downloads.
  1. The browser also simultaneously downloads http://www.coin-or.org/projects/autoGen.xsl/
  1. The `autoGen.xsl` is code I wrote in XSLT - Extensible Style Sheet Language Translation. The `autoGen.xsl` code is read by the browser. Modern browsers have XSLT engines that generates the html you actually view based on the xml file.  
  1. In the `autoGen.xsl` there is code that looks for your project name. Based on your program name it automatically downloads to the browser the png file http://www.coin-or.org/LatestRelease/Cgl-latest-stable.png . This file is updated daily on the COIN-OR server based on Laci's  scripts. Note: The project name needs to be the exact match for the project name so the png file can be found. For example, if the `CoinUtils.xml` file filled out as 
```
<projectName>COIN-OR Utilities</projectName> 
``` 
this would cause a problem, because the "official" project name is "CoinUtils" and `CoinUtils` is what needs to be in the `<projectName>` tag. 


## Does anyone have experience with building COIN-OR with Eclipse CDT on Cygwin?
A: Here is what I have done so far.  It is a long list, so I (kingaj) am writing it here.  Please feel free to edit:

  1. Download and Install
     a. Install Cygwin from http://www.cygwin.org.
        i. Obtain the fixed version of Cygwin make 3.81 to get past the "multiple targets" bug. See [wiki:current-issues the current issues page] for this.
        i. Put the directory `<cygwin_root>/bin` into your Windows PATH environment variable.
     a. Install Eclipse IDE for C/C++ Developers from http://www.eclipse.org.
  1. Set up Eclipse 
     a. Start Eclipse and choose a workspace location.  It is a good idea not to have spaces in directory names.
     a. Open up the Help documentation and get familiarized.
     a. Use the Eclipse Software Update tool to install Subclipse. 
     a. Go through the "C/C++ Getting started" exercises, all the way through to "debugging".
        i.  If you find that some Cygwin libraries or exe's are missing you may have to copy them to a location in your Windows PATH.
  1. Set up COIN-OR
     a. Create the subversion repository (''e.g.'', https://projects.coin-or.org/svn/Smi) in the Subclipse view.
     a. Check out your project (''e.g.'', trunk) as a "normal project" into a directory in your Eclipse workspace.
     a. Open a Cygwin window, `cd` to the checkout directory, and run `configure/make/make test/make install` as usual.
  1. Create a C++ Project for your library.
     a. Choose "Makefile Project".
     a. Uncheck "default location" and browse to the location of the project root (''e.g.'', `trunk/Smi`).
     a. Right click the project and create Make targets ("all" and "test" are good choices) and try to build.  This worked the first time for me (surprise!).
  1. Create a C++ Project for an example.
     a. Choose "Executable".  This will be a CDT "Managed Makefile" project.  
     a. Uncheck "default location" and browse to the location of the project root (''e.g.'', `trunk/Smi/examples`).
     a. Right click the project and select "Properties->C/C++ Build->Settings". In here you can add includes for the C++ Compiler and libraries for the Linker. 
       i. If there are multiple main programs in this directory it will complain.  Just delete the ones you don't need for now.  In your next release you can reorganize your examples into subdirectories.

A final note.  The CDT project perspective looks very good.  CDT has matured greatly since I last looked a few years ago, and it looks like it could be a fine replacement for MSVC++ for COIN-OR development -- especially since now the CDT picks up all project information directly from Makefiles, so there is no need to maintain separate project files.  


## How do I build CoinAll without rpaths?

 1. get rid of all `-rpath` occurrences in Makefile.am by running [this script](https://projects.coin-or.org/svn/CoinBinary/rpm/trunk/noRpathsPatch.sh).
 1. re-run autotools [with the right versions of automake, autoconf, and libtool.](./pm-get-autotools)
 1. configure with `--prefix` pointing to a standard place
 1. make
 1. add all .libs with libraries in them to `LD_LIBRARY_PATH` so that tests have a chance. For example, from the CoinAll base directory do:
 {{{
#!sh
for f in `find . -iname "*.so"`; do
        LD_LIBRARY_PATH=$LD_LIBRARY_PATH:`pwd`/`dirname $f`
done
export LD_LIBRARY_PATH
 }}}
 1. make test
 1. make install
