shite - simple static site generator in posix shell
---------------------------------------------------

**shite** is a simple script to help generating a static webpage. Made for
personal use, it has a pretty simple usage, and no extra functionality.
It reads from a source dir and write to a destination dir. You can start
your website source from examplesite/.

shite is made in a way to don't remove any power from command line tools and
still let the user do manual job. Since shite will never delete any file or
touch files when there is no need, you still can implement things that shite
doesn't do by default. For example, if you need to have multiple versions of 
the same article but in different languages, you can just translate the html
file of the article and manually move it to destination dir (e.g. you server)
and link it to the original via markdown, so when you generate the html files, your
article will have a link to the translated versions. Just keep in mind that shite will not 
generate your entire destination folder, you should manage it (like put all your data)
and shite will never touch it, only update the html files.

And example of usage can be seen here: https://github.com/henriqueleng/henriqueleng.github.io

If you need any extra feature, you will need to touch the script and implement yourself.
Thats how shite was buil.

Please also read the manpage.
