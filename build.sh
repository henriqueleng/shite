#!/bin/sh
DESTDIR='site.dest'
SRCDIR='site.source'
CSSFILE='style.css'
BLOGDIR='blog'

MARKDOWN=smu
EDITOR=vim

#### SITE INFO ####
TITLE='Henrique Lengler'
SUBTITLE='Personal page'
###################

header() { #$1 = css location, $2 index location
cat <<!__EOF__
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <link rel="stylesheet" href="$1">
  </head>
  <body>
  <div id="wrapper">
  <header>
    <h1><a href=$3>$TITLE</a></h1>
	<h2>&mdash; $SUBTITLE</h2>
  </header>
<li id="navbar"><a href=$2>home</a></li>
!__EOF__
}

footer() {
cat <<!__EOF__
    <footer>
      <p>Hosted in <a href="https://github.com/henriqueleng/henriqueleng.github.io">Github</a>
    </footer>
	</div>
  </body>
</html>
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
	cp -R $DESTDIR $2
	exit
elif [ "$1" == "-h" ]
then
	echo "usage: $0 [clean/post] [install <PATH>]"
	exit

elif [ "$1" == "post" ]
then
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

ls -1 $SRCDIR | while read file; do
	if [ "$file" == "$BLOGDIR" ]; then
		blog=1
		level=2
		mkdir $DESTDIR/$BLOGDIR
		header ../style.css ../index.html >> $DESTDIR/$BLOGDIR/index.html
		echo "<li id="'"navbar"'"><a href="index.html">$BLOGDIR</a></li>" >> $DESTDIR/$BLOGDIR/index.html
	fi

	case $file in *.md)
		level=1
		filename=$(echo $file | sed s/.md//)
		header style.css index.html >> $DESTDIR/$filename.html
		ls -1 $SRCDIR | grep md | sed s/.md// | while read file2; do
		if [ $file2 != "index" ]; then
			echo "<li id="'"navbar"'"><a href="$file2.html">$file2</a></li>" >> $DESTDIR/$filename.html
		fi
		done
		if [ $blog == 1 ]; then
			echo "<li id="'"navbar"'"><a href="$BLOGDIR/index.html">$BLOGDIR</a></li>" >> $DESTDIR/$filename.html
			if [ $filename != "index" ]; then
				if [ $blog == 1 ]; then
					echo "<li id="'"navbar"'"><a href="../$filename.html">$filename</a></li>" >> $DESTDIR/$BLOGDIR/index.html
				fi
			fi
		fi
		$MARKDOWN < $SRCDIR/$file >> $DESTDIR/$filename.html
		footer >> $DESTDIR/$filename.html
	esac
done

# populate blog, XXX - find a workaround to use the $blog variable with
# no need to check again
if [ -d $SRCDIR/$BLOGDIR ]; then

if [ -z "$(ls -1 $DIRECTORY)" ]; then
	:
else
   echo "<p id="'"warn"'">No posts yet</p>" >> $DESTDIR/$BLOGDIR/index.html 
fi

ls -1 $SRCDIR/$BLOGDIR | while read file; do
	case $file in *.md)
		file=$(echo $file | sed s/.md//)
		header ../style.css ../index.html >> $DESTDIR/$BLOGDIR/$file.html
		echo "<li id="'"navbar"'"><a href="index.html">$BLOGDIR</a></li>" >> $DESTDIR/$BLOGDIR/$file.html
		title=$(head -n1 $SRCDIR/$BLOGDIR/$file.md | sed s/#//)
		date=$(sed -n '2p' $SRCDIR/$BLOGDIR/$file.md | sed "s/..*; //")
		echo "<p id="'"postdate"'">$date -</p>" >> $DESTDIR/$BLOGDIR/index.html
		echo "<li><a href="$file.html">$title</a></li>" >> $DESTDIR/$BLOGDIR/index.html
		$MARKDOWN < $SRCDIR/$BLOGDIR/$file.md >> $DESTDIR/$BLOGDIR/$file.html
		footer >> $DESTDIR/$BLOGDIR/$file.html
	esac	
	done
	footer >> $DESTDIR/$BLOGDIR/index.html
fi
