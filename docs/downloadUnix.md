
 *NOTE:* Please check the [current issues page](./current-issues) before trying to configure and compile the code.


#### 1. Download

Assume that you want to get the package `Pkg` (for example, `Clp`,
or `Cbc`).

Go to the [COIN-OR source archive site](http://www.coin-or.org/download/source) and click on the directory corresponding to `Pkg`. It is likely that more than one archive file is available there. Download the one with the largest release number (i.e. most recent), such as `Pgk.x.y.z.tgz`.


#### 2. Extract

For example use:
```
gunzip Pgk-x.y.z.tgz
tar xvf Pgk-x.y.z.tar
```


#### 3. Configure and Compilation

3.1. Go into the directory created in step 2:
```
cd Pkg-x.y.z
```

3.2. Create a subdirectory `build` for building the code, go there and run the configuration script:
```
mkdir build
cd build
../configure
```

Make sure the last line of output says that the configuration was successful. Otherwise go to the [troubleshooting page](./user-troubleshooting) to try to figure out what is wrong or to the [configuration script page](./user-configure) for help. 

3.3. Compile the code:
```
make
```

3.4. Test the compiled code (optional):
```
make test
```

The last line of the output should indicate that all tests were run successfully.
If this is not the case, you might find help either on the [troubleshooting page](./user-troubleshooting), the [WikiStart more detailed instructions page], or the the project page listed on the [COIN-OR projects page](http://www.coin-or.org/projects.html).


#### 4. Installation

4.1. Install the generated libraries, executables, and header files:
```
make install
```

This will create subdirectories 
 * `build/bin` containing the executables;
 * `build/lib` containing the libraries;
 * `build/include` containing the header files.


#### 5. `Doxygen Documentation`

If you have `Doxygen` available on your machine, you can create the html documentation for the `Pkg` package as indicated [here](./user-doxygen).

-------


## Additional Help and Reporting Problems

 * [Troubleshooting page](./user-troubleshooting) 
 * [WikiStart More detailed instructions page]
 * [COIN-OR mailing list](http://list.coin-or.org/mailman/listinfo/coin-discuss) for general questions. 
 * Most projects have their own [mailing list](http://list.coin-or.org/mailman/listinfo/). If available, use the project mailing list for project specific issues.
 * [Reporting bugs and problems](http://list.coin-or.org/mailman/listinfo/BuildTools-tickets) for download and installation. 