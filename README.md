shite - simple static site generator in posix shell
---------------------------------------------------

Installation
------------

Edit Makefile and run
    # make install

Quick Start
-----------

Create an empty folder, where your website files will be placed:

``` $ mkdir destdir ```

Run shite to build the pages:  

``` $ shite examplesite/ destdir/ ```

And you are ready to go! This will build your site into "destdir/".





Now you just need to copy the files "favicon.ico",
"disquss.html" and "style.css" to destdir/. You only need to do this once. 

Everytime you update the source files you just run shite again to update 
the webpage. If you delete any file in the source, you'll have to mannually 
delete them from destdir.


Usage
-----

And example of usage can be seen here: https://github.com/henriqueleng/henriqueleng.github.io

More detailed information on the manpage.
