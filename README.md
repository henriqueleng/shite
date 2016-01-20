# shite - posix shell, static site generator.

This is a simple static-site generator made to build my personal site:
(http://www.henriquelengler.com)

It is made entirely posix shell + posix tools (sed, ls, wc, echo, cat
...), *if something fail in your system, please tell me*.

The only extra tools you will need is a markdown processor, that by
default is smu (https://github.com/Gottox/smu), and a text editor.

I decided to make it because I thought it was simple to create one and even
that there is a lot "site-builders" in the internet, no one make a site the way
I want. Which is infinite simple pages + a blog.

## Installing
Just edit the variables on the Makefile and run 

    # make install

## Usage

Information about usage, files and other things on the manpage, please read
it after using shite

### Site style:

If your generated website is ugly, don't worry, editing the CSS file can solve all 
your problems. Read the generated files, to see the tags used and edit
it. I am working to make a good default style.css.

### TODO

- [x] Improve style.css and general style

- [x] Full navigation bar links on blog files

- [x] Remove some variables from the script, making it universal and
  installable (almost done, there still DESTDIR, MARKDOWN, SRCDIR ...)

- [x] Link on navigation bar

- [x] Make it works with distant folders

- [x] Manpage

- [ ] Indent code

- [ ] break long lines?

### Contact
Please send patches, suggestions and any other things to:
<henriqueleng@openmailbox.org>
