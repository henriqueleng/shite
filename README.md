# shite - posix shell, static site generator.

This is a simple static-site generator made to build my personal site:
(http://www.henriquelengler.com)

It is made entirely posix shell + posix tools (sed, ls, wc, echo, cat
...), *if something fail in your system, please tell me*.

The only extra tools you will need is a markdown processor, that by
default is smu (https://github.com/Gottox/smu), and a text editor.

I decided to make it because I thought it was simple to create one and even
that there is a lot "site-builders" in the internet, no one make a site
with the style I want. Which is infinite simple pages + a blog.

## Starting
Start by just running ./build.sh, it will build an example site, so you
can see how it works. Use the example site as an skeleton fil, to start.

Edit the variables in build.sh, to match the folder of your source.
An example SRCDIR, that I use is SRCDIR=/home/henri/Source/site.source

BLOGDIR already includes SRCDIR.

## Files:

	foo.md - each .md file in the main directory will be a a page linked
into the navigation bar. Write it in markdown.

	foo.link - each .link file will end as a link in the navigation bar
to the url you put in the file. You should put thu url in the first
line. See the example.

	blog/ - this is your blog directory. it is where you write all 
your posts. This blog will be linked in the navigation bar of each page, 
and shite will generate a list in the first page iof the blog with all 
your posts and date.

To post, run the script 

    ./build.sh post

_PLEASE. You should use this command at least to create the files._

this script will create a .md file in this directory with propper header and
title.

If you don't wanna a blog don't create this folder.

## Building

To build the whole site type:

    ./build.sh

It will delete the old built content, and generate a new one.

To install the generated files type (it will copy the whole $DESTDIR to
<PATH> usualy the server folder):

    ./build && ./build install <PATH>

or simply:

	cp -R $DESTDIR/* /foo/bar/server/

You can work on github hosting by putting these files in a .foo/ dir and
add it to the gitignore, then your <PATH> will be ../
it will generate and copy the content of $DESTDIR to PATH.

To only clean and exit do:

    ./build.sh clean

### Site style:

If your generated website is ugly, don't worry, editing the CSS file can solve all 
your problems. Read the generated files, to see the tags used and edit
it. I am working to make a good default style.css.

*Also don't forget, the script is easy to understand, so just adjust
it, and send the changes back if you wanna contribute*

### TODO
- [x] Improve style.css and general style

- [x] Full navigation bar links on blog files

- [ ] Link on navigation bar

- [ ] Make it works with distant folders

### Contact
Please send me patches, suggestions and any other things to:
<henriqueleng@openmailbox.org>
