#!/bin/sh
cssfile='style.css'
currentdir="$(pwd)"
html_header() { #$1 = css location, $2 favicon location, $3 index location
cat <<!__EOF__
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=0.7">
		<link rel="stylesheet" href="$1">
		<link rel="icon" href="$2" type="image/x-icon">
		<title>$title - $subtitle</title>
	</head>
	<body>
		<header>
			<h1 id="title"><a href=$3>$title</a></h1>
			<h2 id="subtitle">&mdash; $subtitle</h2>
		</header>
		<ul id="nav">
			<li><a href=$3>home</a></li>
!__EOF__
}

html_footer() {
cat <<!__EOF__
		<footer>
			<p> $footer
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
	echo "$@" >&2
	exit 1
}

# PARSE FLAGS AND FOLDERS
if [ "$1" = "-h" ] || [ "$1" = "" ]; then
	echo usage: "$0" [-p] srcdir destdir
	exit

elif [ "$1" = "-p" ]; then
	if [ "$2" = "" ]; then
		die "you must specify the srcdir"
	else
		srcdir="$2"
	fi
		PFLAG=1
else
	if [ "$2" = "" ]; then
		die "you must specify a destdir"
	else
		srcdir="$1"
		destdir="$2"
	fi
fi

# check shiterc
if [ -f "$srcdir"/shiterc ]; then
	echo 'found shiterc, parsing it'
	. "$srcdir"/shiterc
	echo parsed from "$srcdir""shiterc":
	echo "\ttitle: $title"
	echo "\tsubtitle: $subtitle"
	echo "\tfooter: $footer"
	echo "\tblogdir: $blogdir"
else
	die "didn't found shiterc, can't proceed without it"
fi


# test dirs
# src - allways needed
if [ ! -d "$srcdir" ]; then
	die "$srcdir isn't a directory, please check it"
else
	srcdir="$(cd "$srcdir" && pwd && cd "$currentdir")"
	echo source path: "$srcdir"
fi

# blog
if [ -d "$srcdir"/"$blogdir" ]; then
	blog=1
	blogheader="$(mktemp -t shite-blogheader.XXXXXX)"
	blogentries=0
else
	if [ $PFLAG ]; then
		mkdir "$srcdir"/"$blogdir"
		echo 'there was no blog, created it'
		blog=1
	else
		echo 'no blog, not building it'
		blog=0
	fi
fi

if [ $PFLAG ]; then # continue pflag
	EDITOR="$(printenv EDITOR)"

	if [ "$EDITOR" = "" ]; then
		die "no '$EDITOR', set it to use this function"
	fi

	number="$(ls -1 "$srcdir"/"$blogdir" | wc -l )"

	echo 'Name of the post:'
	read -r title
	date="$(date "+%Y/%m/%d")"

	filename="$(("$number" + 1))-$(echo "$title" | sed s/' '/'-'/g)"

	cat <<!__EOF__ >> "$srcdir"/"$blogdir"/"$filename".md
# $title
$date
!__EOF__
	"$EDITOR" "$srcdir"/"$blogdir"/"$filename".md

	echo 'post created. now, build your site'
	exit 0
fi

# check markdown
MARKDOWN="$(printenv MARKDOWN)"
if [ "$MARKDOWN" = "" ]; then
	die "couldn't build site, markdown processor not found: set MARKDOWN"
else
	if type "$MARKDOWN" >/dev/null 2>&1; then
		echo "markdown processor: $MARKDOWN"
		title="$(echo "$title" | "$MARKDOWN" | sed 's/<[^a>]*>//g')"
		subtitle="$(echo "$subtitle" | "$MARKDOWN" | sed 's/<[^a>]*>//g')"
		footer="$(echo "$footer" | "$MARKDOWN" | sed 's/<[^a>]*>//g')"
	else
		die "MARKDOWN isn't a suitable binary"
	fi
fi

mkdir -p "$destdir"
destdir="$(cd "$destdir" && pwd && cd "$currentdir")"
echo "destination path: $destdir"

touch "$destdir"/index.html
cp "$srcdir"/"$cssfile" "$destdir"
cp "$srcdir"/favicon.ico "$destdir"

header="$(mktemp shite-header.XXXXXX)"

ls -1 "$srcdir" | while read -r file; do
	case "$file" in
		*.md)
			filename="$(echo "$file" | sed s/.md//)"
			html_header style.css favicon.ico index.html > "$destdir"/"$filename".html
			if [ "$filename" != "index" ]; then
				barentry "$filename".html "$filename" >> "$header"
				if [ "$blog" = 1 ]; then
					barentry ../"$filename".html "$filename" >> "$blogheader"
				fi
			fi
			;;

		*.link)
			echo "link file found: $file"
			filename="$(echo "$file" | sed s/.link//)"
			url="$(sed 1q "$srcdir"/"$file")"
			barentry "$url" "$filename" >> "$header"
			if [ "$blog" = 1 ]; then
				barentry "$url" "$filename" >> "$blogheader"
			fi
			;;
	esac

	if [ "$blog" = 1 ] && [ "$blogentries" = 0 ]; then
		echo adding blog to headers
		mkdir "$destdir"/"$blogdir"
		html_header ../style.css ../favicon.ico ../index.html > \
			"$destdir"/"$blogdir"/index.html
		barentry "$blogdir"/index.html "$blogdir" >> "$header"
		barentry index.html "$blogdir" >> "$blogheader"
		blogentries=1
	fi
done 

ls -1 "$srcdir" | grep md | sed s/.md// | while read -r file; do
	{
		cat "$header"
		echo '		</ul>'
		printf '\n\n<!--Begin markdown generated content-->\n\n'
		"$MARKDOWN" < "$srcdir"/"$file".md
		printf '\n\n<!--End markdown generated content-->\n\n'
		html_footer
	} >> "$destdir"/"$file".html
done

if [ "$blog" = 1 ]; then
	echo adding header to blog
	cat "$blogheader" >> "$destdir"/"$blogdir"/index.html
	echo '		</ul>' >> "$destdir"/"$blogdir"/index.html

	if [ "$(ls -A "$srcdir"/"$blogdir")" ]; then
		echo "blog not empty, building posts"

		echo "posts detected:"
		echo '		<ul id="blogpost">' >> "$destdir"/"$blogdir"/index.html
		ls -1r "$srcdir"/"$blogdir" | grep .md | sed s/.md// | while read -r file; do
			posttitle="$(sed 1q "$srcdir"/"$blogdir"/"$file".md | sed s/#//)"
			postdate="$(sed -n 2p "$srcdir"/"$blogdir"/"$file".md)"
			echo "			<li>$postdate - <a href=$file.html>$posttitle</a></li>" >> \
				"$destdir"/"$blogdir"/index.html
			html_header ../style.css ../favicon.ico ../index.html > \
				"$destdir"/"$blogdir"/"$file".html
			{
				cat "$blogheader"
				echo '		</ul>'
				echo "<h1 id=\"posttitle\">$posttitle</h1>"
				echo "<h2 id=\"postdate\">Written in: $postdate</h2>"
				printf '\n\n<!--Begin markdown generated content-->\n\n'
				sed 1,2d "$srcdir"/"$blogdir"/"$file".md | "$MARKDOWN"
				printf '\n\n<!--End markdown generated content-->\n\n'
				html_footer
			} >> "$destdir"/"$blogdir"/"$file".html
			echo "MARKDOWN: $file"
		done
		echo '		</ul>' >> "$destdir"/"$blogdir"/index.html
	else
		echo '<p id="warn">No posts yet</p>' >> "$destdir"/"$blogdir"/index.html
	fi
	html_footer >> "$destdir"/"$blogdir"/index.html
	rm "$blogheader"
fi
	rm "$header"
	printf '\n'
	echo "site built"
	exit 0
