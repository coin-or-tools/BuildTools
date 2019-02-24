
 Assume that you have downloaded the source code of a COIN-OR package `Pkg` in
a local directory `Pkg-x.y.z` and used `Pkg-x.y.z/build` as build directory, following the [quick download and installation guide](./downloadMain).

If you have `Doxygen` available, you can build the html documentation by typing

```
make doxydoc
``` 

in the directory `Pkg-x.y.z/build`. Then open the file `Pkg-x.y.z/doxydoc/html/index.html` with a browser.
Note that this creates the documentation for all the projects included in the `Pkg` package. If you
prefer to generate the documentation only for a subset 
of these projects, you can edit the file `Pkg-x.y.z/doxydoc/doxygen.conf` to exclude directories 
(using the `EXCLUDE` variable, for example).

If `Doxygen` is not available, a link to an on-line version of the html documentation might be available from the respective project pages available from the [COIN-OR projects page](https://projects.coin-or.org).

------------------


## Additional Help

 * [CoinHelp page](https://projects.coin-or.org/BuildTools/wiki).
 * Frequently Asked Questions: [FAQ page](http://www.coin-or.org/faqs.html).

