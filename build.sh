#!/bin/sh
DESTDIR='site.dest'
SRCDIR='examples/site.source'
CSSFILE='style.css'
BLOGDIR='blog'

MARKDOWN=smu

#### SITE INFO ####
TITLE='Sample Title'
SUBTITLE='Personal page'
###################

header() { #$1 = css location, $2 favicon location, $3 index location
cat <<!__EOF__
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <link rel="stylesheet" href="$1">
	<link rel="icon" href="$2" type="image/x-icon">
  </head>
  <body>
  <div id="wrapper">
  <header>
    <h1><a href=$3>$TITLE</a></h1>
	<h2>&mdash; $SUBTITLE</h2>
  </header>
<li id="navbar"><a href=$3>home</a></li>
!__EOF__
}

footer() {
cat <<!__EOF__
    <footer>
      <p>Hosted in <a href="http://www.github.com">Github</a>
    </footer>
	</div>
  </body>
</html>
!__EOF__
}

barentry() { # $1 = file, $2 = name
cat <<!__EOF__
<li id="navbar"><a href="$1">$2</a></li>
!__EOF__
}

clean() {
	rm -rf $DESTDIR
}

# START #
if [ "$1" == "clean" ]
then
	clean
	exit
elif [ "$1" == "install" ]
then
	cp -R $DESTDIR/* $2
	exit
elif [ "$1" == "-h" ]
then
	echo "usage: $0 [clean/post] [install <PATH>]"
	exit

elif [ "$1" == "post" ]
then
EDITOR=$(printenv EDITOR)

if [ "$EDITOR" == "" ]
then
echo 'No $EDITOR, set it to use this function'
exit
fi

number=$(ls -1 $SRCDIR/$BLOGDIR | wc -l )

echo 'Name of the post:'
read TITLE
date=$(date "+%Y/%m/%d")

filename="$(($number + 1))-$(echo $TITLE | sed s/' '/'-'/g)"

cat <<!__EOF__ >> $SRCDIR/$BLOGDIR/$filename.md
# $TITLE
## &mdash; $date
!__EOF__
$EDITOR $SRCDIR/$BLOGDIR/$filename.md
fi

## BEGIN ##
clean
mkdir $DESTDIR
touch $DESTDIR/index.html
cp $SRCDIR/$CSSFILE $DESTDIR
cp $SRCDIR/favicon.ico $DESTDIR

# check for blog
if [ -d "$SRCDIR/$BLOGDIR" ]; then
	blog=1
	blogentries=0
else
	echo "there is no blog, not building it"
fi

ls -1 $SRCDIR | while read file; do
	if [ $blog == 1 ]; then
		if [ "$file" == "$BLOGDIR" ]; then
			echo blog detected, building it!
		fi
	fi

	case $file in *.md)
		filename=$(echo $file | sed s/.md//)
		header style.css favicon.ico index.html >> $DESTDIR/$filename.html
		if [ $filename != "index" ]; then
			barentry $filename.html $filename >> $DESTDIR/header.html
			if [ $blog == 1 ]; then
				barentry ../$filename.html $filename >> $DESTDIR/$BLOGDIR/header.html
			fi
		fi
	esac

	if [ $blogentries == 0 ]; then
		echo addind blog to headers
		mkdir $DESTDIR/$BLOGDIR
		header ../style.css ../favicon.ico ../index.html >> $DESTDIR/$BLOGDIR/index.html
		barentry $BLOGDIR/index.html $BLOGDIR >> $DESTDIR/header.html #blog entry on pages
		barentry index.html $BLOGDIR >> $DESTDIR/$BLOGDIR/header.html #blog entry on blog pages
		blogentries=1
	fi
done 

ls -1 $SRCDIR | grep md | sed s/.md// | while read file; do
	cat $DESTDIR/header.html >> $DESTDIR/$file.html
	$MARKDOWN < $SRCDIR/$file.md >> $DESTDIR/$file.html
	footer >> $DESTDIR/$file.html
done

if [ $blog = 1 ]; then
	echo adding header to blog 
	cat $DESTDIR/$BLOGDIR/header.html >> $DESTDIR/$BLOGDIR/index.html

	if [ "$(ls -A $SRCDIR/$BLOGDIR)" ]; then
		echo "blog not empty, building posts"

		echo "posts detected:"
		ls -1 $SRCDIR/$BLOGDIR | grep .md | sed s/.md// | while read file; do
			echo $file
			header ../style.css ../favicon.ico ../index.html >> $DESTDIR/$BLOGDIR/$file.html
			cat $DESTDIR/$BLOGDIR/header.html >> $DESTDIR/$BLOGDIR/$file.html
			title=$(head -n1 $SRCDIR/$BLOGDIR/$file.md | sed s/#//)
			date=$(sed -n '2p' $SRCDIR/$BLOGDIR/$file.md | sed "s/..*; //")
			echo "<li>$date - <a href="$file.html">$title</a></li>" >> $DESTDIR/$BLOGDIR/index.html
			$MARKDOWN < $SRCDIR/$BLOGDIR/$file.md >> $DESTDIR/$BLOGDIR/$file.html
			footer >> $DESTDIR/$BLOGDIR/$file.html
		done
	else
	   echo "<p id="'"warn"'">No posts yet</p>" >> $DESTDIR/$BLOGDIR/index.html
	fi
	footer >> $DESTDIR/$BLOGDIR/index.html

	echo cleaning tmp files
	rm $DESTDIR/$BLOGDIR/header.html
	rm $DESTDIR/header.html

	echo "site builded, copy it to the server"
fi
