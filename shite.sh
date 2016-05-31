#!/bin/sh
CSSFILE='style.css'
CURRENTDIR=$(pwd)

header() { #$1 = css location, $2 favicon location, $3 index location
cat <<!__EOF__
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=0.7">
		<link rel="stylesheet" href="$1">
		<link rel="icon" href="$2" type="image/x-icon">
		<title>$TITLE - $SUBTITLE</title>
	</head>
	<body>
		<header>
			<h1 id="title"><a href=$3>$TITLE</a></h1>
			<h2 id="subtitle">&mdash; $SUBTITLE</h2>
		</header>
		<ul id="nav">
			<li><a href=$3>home</a></li>
!__EOF__
}

footer() {
cat <<!__EOF__
		<footer>
			<p> $FOOTER
		</footer>
	</body>
</html>
!__EOF__
}

barentry() { # $1 = file, $2 = name
cat <<!__EOF__
			<li><a href="$1">$2</a></li>
!__EOF__
}

die() {
	echo $@ >&2
	exit 1
}

# PARSE FLAGS AND FOLDERS
if [ "$1" == "-h" ] || [ "$1" == "" ]; then
	echo "usage: $0 [-p] SRCDIR DESTDIR"
	exit

elif [ "$1" == "-p" ]; then
	if [ "$2" == "" ]; then
		die 'you must specify the SRCDIR'
	else
		SRCDIR="$2"
	fi
		PFLAG=1
else
	if [ "$2" == "" ]; then
		die 'you must specify a DESTDIR'
	else
		SRCDIR="$1"
		DESTDIR="$2"
	fi
fi

# check shiterc
if [ -f $SRCDIR/shiterc ]; then
	echo 'found shiterc, parsing it'
	. $SRCDIR/shiterc
	echo "parsed from $SRCDIR/shiterc:"
	echo "title: $TITLE"
	echo "subtitle: $SUBTITLE"
	echo "footer: $FOOTER"'\n'
	echo "blogdir: $BLOGDIR"'\n'
else
	die "didn't found shiterc, can't proceed without it"
fi


# test dirs
# src - allways needed
if [ ! -d "$SRCDIR" ]; then
	die "$SRCDIR isn't a directory, please check it"
else
	SRCDIR=$(cd $SRCDIR && pwd && cd $CURRENTDIR)
	echo "SRCDIR path: $SRCDIR"
fi

# blog
echo blog dir: "$SRCDIR/$BLOGDIR"
if [ -d "$SRCDIR/$BLOGDIR" ]; then
	blog=1
	BLOGHEADER=$(mktemp -t shite-blogheader.XXXXXX)
	blogentries=0
else
	if [ $PFLAG ]; then
		mkdir $SRCDIR/$BLOGDIR
		echo 'there was no blog, created it'
		blog=1
	else
		echo 'no blog, not building it'
		blog=0
	fi
fi

if [ $PFLAG ]; then # continue pflag
	EDITOR=$(printenv EDITOR)

	if [ "$EDITOR" == "" ]; then
		die 'no $EDITOR, set it to use this function'
	fi

	number=$(ls -1 $SRCDIR/$BLOGDIR | wc -l )

	echo 'Name of the post:'
	read TITLE
	date=$(date "+%Y/%m/%d")

	filename="$(($number + 1))-$(echo $TITLE | sed s/' '/'-'/g)"

	cat <<!__EOF__ >> $SRCDIR/$BLOGDIR/$filename.md
# $TITLE
$date
!__EOF__
	$EDITOR $SRCDIR/$BLOGDIR/$filename.md

	echo 'post created. now, build your site'
	exit 0
fi

# check markdown
MARKDOWN=$(printenv MARKDOWN)
if [ "$MARKDOWN" == "" ]; then
	die "couldn't build site, markdown processor not found: set MARKDOWN"
else
	if $(type $MARKDOWN >/dev/null 2>&1); then
		echo "markdown processor is: $MARKDOWN"
		TITLE=$(echo $TITLE | $MARKDOWN | sed 's/<[^a>]*>//g')
		SUBTITLE=$(echo $SUBTITLE | $MARKDOWN | sed 's/<[^a>]*>//g')
		FOOTER=$(echo $FOOTER | $MARKDOWN | sed 's/<[^a>]*>//g')
	else
		die " MARKDOWN isn't a suitable binary"
	fi
fi

mkdir -p $DESTDIR
DESTDIR=$(cd $DESTDIR && pwd && cd $CURRENTDIR)
echo "destdir path is: $DESTDIR"

touch $DESTDIR/index.html
cp $SRCDIR/$CSSFILE $DESTDIR
cp $SRCDIR/favicon.ico $DESTDIR

HEADER=$(mktemp shite-header.XXXXXX)

ls -1 $SRCDIR | while read file; do
	case "$file" in
		*.md)
			filename=$(echo "$file" | sed s/.md//)
			header style.css favicon.ico index.html > "$DESTDIR/$filename.html"
			if [ "$filename" != "index" ]; then
				barentry "$filename.html" "$filename" >> "$HEADER"
				if [ $blog == 1 ]; then
					barentry "../$filename.html" "$filename" >> "$BLOGHEADER"
				fi
			fi
			;;

		*.link)
			echo "link file found: $file"
			filename=$(echo "$file" | sed s/.link//)
			url=$(sed 1q "$SRCDIR/$file")
			barentry $url "$filename" >> "$HEADER"
			if [ $blog == 1 ]; then
				barentry "$url" "$filename" >> "$BLOGHEADER"
			fi
			;;
	esac

	if [ $blog == 1 ] && [ $blogentries == 0 ]; then
		echo adding blog to headers
		mkdir "$DESTDIR/$BLOGDIR"
		header ../style.css ../favicon.ico ../index.html > "$DESTDIR/$BLOGDIR/index.html"
		barentry "$BLOGDIR/index.html" "$BLOGDIR" >> "$HEADER"
		barentry index.html "$BLOGDIR" >> "$BLOGHEADER"
		blogentries=1
	fi
done 

ls -1 "$SRCDIR" | grep md | sed s/.md// | while read file; do
	cat "$HEADER" >> "$DESTDIR/$file.html"
	echo '		</ul>' >> "$DESTDIR/$file.html"
	echo '\n\n<!--Begin markdown generated content-->\n\n' >> "$DESTDIR/$file.html"
	$MARKDOWN < $SRCDIR/$file.md >> $DESTDIR/$file.html
	echo '\n\n<!--End markdown generated content-->\n\n' >> "$DESTDIR/$file.html"
	footer >> "$DESTDIR/$file.html"
done

if [ $blog = 1 ]; then
	echo adding header to blog 
	cat $BLOGHEADER >> "$DESTDIR/$BLOGDIR/index.html"
	echo '		</ul>' >> "$DESTDIR/$BLOGDIR/index.html"

	if [ "$(ls -A $SRCDIR/$BLOGDIR)" ]; then
		echo "blog not empty, building posts"

		echo "posts detected:"
		echo '		<ul id="blogpost">' >> "$DESTDIR/$BLOGDIR/index.html"
		ls -1r "$SRCDIR/$BLOGDIR" | grep .md | sed s/.md// | while read file; do
			header ../style.css ../favicon.ico ../index.html > "$DESTDIR/$BLOGDIR/$file.html"
			cat "$BLOGHEADER" >> "$DESTDIR/$BLOGDIR/$file.html"
			posttitle=$(sed 1q "$SRCDIR/$BLOGDIR/$file.md" | sed s/#//)
			postdate=$(sed -n 2p "$SRCDIR/$BLOGDIR/$file.md")
			echo "			<li>$postdate - <a href="$file.html">$posttitle</a></li>" >> \
			"$DESTDIR/$BLOGDIR/index.html"
			echo '		</ul>' >> "$DESTDIR/$BLOGDIR/$file.html"
			echo "<h1 id="'"posttitle"'">$posttitle</h1>" >> "$DESTDIR/$BLOGDIR/$file.html"
			echo "<h2 id="'"postdate"'">Written in: $postdate</h2>" >> "$DESTDIR/$BLOGDIR/$file.html"
			echo "MARKDOWN: $file"
			echo '\n\n<!--Begin markdown generated content-->\n\n' >> "$DESTDIR/$BLOGDIR/$file.html"
			sed 1,2d $SRCDIR/$BLOGDIR/$file.md | $MARKDOWN >> "$DESTDIR/$BLOGDIR/$file.html"
			echo '\n\n<!--End markdown generated content-->\n\n' >> "$DESTDIR/$BLOGDIR/$file.html"
			footer >> "$DESTDIR/$BLOGDIR/$file.html"
		done
		echo '		</ul>' >> "$DESTDIR/$BLOGDIR/index.html"
	else
		echo '<p id="warn">No posts yet</p>' >> "$DESTDIR/$BLOGDIR/index.html"
	fi
	footer >> "$DESTDIR/$BLOGDIR/index.html"
	rm $BLOGHEADER
fi
	rm "$HEADER"
	printf '\n'
	echo "site built"
	exit 0
