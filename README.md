# shite - posix shell, static site generator.
*looking for a better name*

This is a simple static-site generator made to build my persnal site:
henriquelengler.com

It is made entirely posix shell + posix tools (sed, ls, wc, echo, cat
...), *if something fail in your system, please tell me*.

The only extra tools you will need is a markdown processor, that by
default is smu (https://github.com/Gottox/smu), and a text editor.

I decided to make it because I thought it was simple to create one and even
that there is a lot "site-builders" in the internet, no one make a site
with the style I want. Which is infinite simple pages + a blog.

## How it works
Right know It is working in a very static way, you get the source, and
start to write your site on the $SRCDIR directory.
You only need to care that $SRCDIR and $DESTDIR are in the same folder of the 
build.sh script.
Edit the functions header() and footer() to change the defaults.
You write everything in markdown, infinite files in $SRCDIR and $BLOGDIR.

Each file in the main $SRCDIR will be linked in the navigation bar,
and will be rendered as a simple page.

### The blog
Each file in the $BLOGDIR will be listed in the $BLOGDIR/index.html that
will also be linked to the main page.

To create a new post just run:

    ./build.sh post

It will ask by a title, create the file, put the actual date on it and
open your editor, so you start writing.
Use this command because it will generate the correct format.

Then when you build, it will create a index in the $BLOGDIR with a list
of all your posts.

To build the whole site type:

    ./build.sh

It will delete the old content, and generate a new one.

To install the generated files type (it will copy the whole $DESTDIR to
<PATH> usualy the server folder):

    ./build && ./build install <PATH>

it will generate and copy the content of $DESTDIR to PATH.

To only clean and exit do:

    ./build.sh clean

### So, it will be something like this:

    sitebuild/
    ├── build.sh
    ├── README
    ├── site.source
    │   ├── index.md
    │   ├── contact.md
    │   ├── style.css
    │   ├── ...
    │   └ blog/
    │     ├ 1-example-post.md
    │     ├ 2-bla.md
    │     └ ...
    │
    └── site.dest
        ├ index.html
    	├ contact.html
    	├ style.css
    	└ blog/
          ├ index.html (NEW, WITH A LIST OF POSTS)
          ├ 1-example-post.md
          ├ 2-bla.md
          └ ...

### Site style:

If your generated website is ugly, don't worry, editing the CSS file can solve all 
your problems. Read the generated files, to see the tags used and edit
it. I am working to make a good default style.css.

*Also don't forget, the script is easy to understand, so just adjust
it, and send the changes back if you wanna contribute*

### TODO
[ ] Improve style.css and general style
[ ] Full navigation bar links on blog files

### Contact

Please send me patches, suggestions and any other things to:
<henriqueleng@openmailbox.org>
