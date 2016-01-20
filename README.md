# shite - posix shell, static site generator.

This is a simple static-site generator made to build my personal site:
(http://www.henriquelengler.com)

It is made entirely posix shell + posix tools (sed, ls, wc, echo, cat
...), *if something fail in your system, please tell me*.

The only extra tools you will need is a markdown processor, and a text editor.

## Installing
Just edit the variables on the Makefile and run 

    # make install

## Usage

On the manpage, please read it.

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
