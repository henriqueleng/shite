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

## MANPAGE:

    SHITE(1)		    General Commands Manual		      SHITE(1)

    NAME
         shite  posix shell, static site generator
    
    SYNOPSIS
         shite [-p] SRCDIR DESTDIR
    
    DESCRIPTION
         shite is a script to generate a static web page, optionally with blog
         and/or multiple pages, by reading a bunch of markdown files and a simple
         config file.  Made to facilitate blogging, writing and publication of
         online content, since markdown format is almost pure text, it can prevent
         the author from contact with ugly html pages.  It is a very static
         program, offering little easy customization of the final product, to
         generate anything way different, one will need to edit style.css file.
    
    OPTIONS
         -p	     Create a blogpost. It will ask for a title, get the date and open
    	     your editor on the new post file.
    
    ENVIRONMENT
         MARKDOWN enviroment variable is used to generate html pages.  EDITOR will
         be used on the -p option, to write the post
    
    FILES
         SRCDIR - where the site source is, specified by command flag
    
         SRCDIR/foo.md - markdown files of the main dir. You can write "infinite"
         ones, each will be linked to the navigation bar. These files have no
         specific syntax, just pure markdown.
    
         SRCDIR/foo.link - link files. each .link file will be a simple link in
         the navigation bar, poiting to the site you write in the first line of
         it.
    
         SRCDIR/shiterc - the basic site configuration, where you set the title,
         subtitle, and footer text, write these things in markdown, as done in the
         example.
    
         SRCDIR/blog/ - the blog folder, create it if you want one. If you don't
         create it, blog will not be generated nor linked to the navbar.
    
         SRCDIR/blog/n-post-name.md - your blogposts, these files needs to follow
         a specific format, created by -p flag. n means a number, this number will
         say in each time order the posts were created. The first line of the file
         must be the name of the post in a <h1> mardown format, like '# Some
         title', followed by the date of the post in the next line. To avoid
         errors, invoke -p flag.
    
    EXAMPLES
         You can start your site on top of the example site. Copy it to anywhere
         (or keep it in place), edit shiterc, remove the blogposts or just edit
         them. After that run shite to build it, you can point directly to a
         server dir, for example:
    
         shite share/mysite /var/www/htdocs/...
         To simplify everything you can add add an alias like 'alias buildsite='shite foo bar''
         or create a script and add it to crontab to automatically build and upload to the server.
    
    SEE ALSO
         smu(1)
    
    AUTHORS
         Henrique N. Lengler <henriqueleng@openmailbox.org>
    
    SECURITY CONSIDERATIONS
         This software runs a lot of commands and can cause damage to the system,
         since it is a new piece and probably there still some bugs to be found:
         So please use with caution.
    
    OpenBSD 5.9			     2016			   OpenBSD 5.9
