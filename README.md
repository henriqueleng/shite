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
Edit the variables in build.sh, by default it will compile a sample site
on examples/site.source to site.dest folder.
Change the paths of DESTDIR, SRCDIR, and the mardown processor you wanna
use on MARKDOWN.
BLOGDIR already includes SRCDIR.

### The blog
Each file in the $BLOGDIR will be listed in the $BLOGDIR/index.html that
will also be linked to the main page.

To create a new post just run:

    ./build.sh post

It will ask by a title, create the file, put the actual date on it and
open your editor (set by the $EDITOR enviroment variable).

PLEASE. You should use this command at least to create the files. because 
it will generate the header that shite understand. 
After you ran it once, you can open it normally with your editor.

Then build it, it will create a index in the $BLOGDIR with a list
of all your posts.

To build the whole site type:

    ./build.sh

It will delete the old content, and generate a new one.

To install the generated files type (it will copy the whole $DESTDIR to
<PATH> usualy the server folder):

    ./build && ./build install <PATH>

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
[ ] Improve style.css and general style

[ ] Full navigation bar links on blog files

[ ] Make it works with distant folders

### Contact
Please send me patches, suggestions and any other things to:
<henriqueleng@openmailbox.org>
