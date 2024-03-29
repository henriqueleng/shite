#!/bin/sh
currentdir="$(pwd)"

# -- BEGIN FUNCTIONS

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

# $1, print script, yes = 1, no = 0
html_footer() {
echo '		<footer>'
if [ "$1" ]; then
	cat "$srcdir"/"$comment_script"
fi
printf '\n'
cat <<!__EOF__
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
if [ "$1" = "-h" -o "$1" = "" ]; then
	echo usage: "$0" srcdir destdir
	exit
fi

if [ "$2" = "" ]; then
	die "you must specify a destdir"
else
	srcdir="$1"
	destdir="$2"
fi

# test directories
# src - allways needed
if [ ! -d "$srcdir" ]; then
	die "$srcdir isn't a directory, please check it"
else
	srcdir="$(cd "$srcdir" && pwd && cd "$currentdir")"
	echo source path: "$srcdir"
fi

# check shiterc
if [ -f "$srcdir"/shiterc ]; then
	. "$srcdir"/shiterc

	cat << EOF
parsed from $srcdir/shiterc:
	title: $title
	subtitle: $subtitle
	footer: $footer
	blogdir: $blogdir
	comment script: $comment_script
EOF
else
	die "shiterc not found, can't proceed without it"
fi

# check if blog
if [ -d "$srcdir"/"$blogdir" ]; then
	blog=1
else
	echo 'no blog, not building it'
	blog=0
fi

# check markdown
MARKDOWN="$(printenv MARKDOWN)"
if [ "$MARKDOWN" = "" ]; then
	die "can't build site, markdown processor not found: set MARKDOWN"
else
	if type "$MARKDOWN" >/dev/null 2>&1; then
		echo "markdown: $MARKDOWN"
		title="$(echo "$title" | "$MARKDOWN" | sed 's/<[^a>]*>//g')"
		subtitle="$(echo "$subtitle" | "$MARKDOWN" | sed 's/<[^a>]*>//g')"
		footer="$(echo "$footer" | "$MARKDOWN" | sed 's/<[^a>]*>//g')"
	else
		die "MARKDOWN isn't a suitable binary"
	fi
fi

# main
mkdir -p "$destdir"
destdir="$(cd "$destdir" && pwd && cd "$currentdir")"
echo "destination path: $destdir"

touch "$destdir"/index.html

header="$(mktemp -t shite-header.XXXXXX)"

# generate indexes and navigation bar for blog and blogposts
if [ "$blog" = 1 ]; then
	# this is the header of the blog index
	blogheader="$(mktemp -t shite-blogheader.XXXXXX)"
	if [ "$(ls -A "$srcdir"/"$blogdir")" ]; then
		blogfiles=1
		# create header for files on level deeper (blogposts)
		blogheader2="$(mktemp -t shite-blogheader2.XXXXXX)"
	else
		blogfiles=0
	fi

	mkdir -p "$destdir"/"$blogdir"
	# create header of blog index
	html_header ../style.css ../favicon.ico ../index.html > "$blogheader"
	barentry index.html "$blogdir" >> "$blogheader"
	# add blog link to site index
	barentry "$blogdir"/index.html "$blogdir" >> "$header"
	if [ "$blogfiles" = 1 ]; then
		html_header ../../style.css ../../favicon.ico \
			../../index.html > "$blogheader2"
		barentry ../index.html "$blogdir" >> "$blogheader2"
	fi
fi

# create the navigation bar entries, for all the pages that may come
cd "$srcdir"
for file in *; do
	case "$file" in
		*.md)
			filename="$(echo "$file" | sed 's/\.md//')"
			html_header style.css favicon.ico index.html > "$destdir"/"$filename".html
			if [ "$filename" != "index" ]; then
				barentry "$filename".html "$filename" >> "$header"
				if [ "$blog" = 1 ]; then
					barentry ../"$filename".html "$filename" >> "$blogheader"
				fi
				if [ "$blogfiles" = 1 ]; then
					barentry ../../"$filename".html "$filename" >> "$blogheader2"
				fi
			fi
			;;

		*.link)
			echo "link file found: $file"
			filename="$(echo "$file" | sed 's/\.link//')"
			url="$(sed 1q "$srcdir"/"$file")"
			barentry "$url" "$filename" >> "$header"
			if [ "$blog" = 1 ]; then
				barentry "$url" "$filename" >> "$blogheader"
			fi
			if [ "$blogfiles" = 1 ]; then
				barentry "$url" "$filename" >> "$blogheader2"
			fi
			;;
	esac
done 

# still in srcdir
cd "$srcdir"

# process markdown
for file in *.md; do
	file="$(echo "$file" | sed 's/\.md$//')"
	{
		cat "$header"
		echo '		</ul>'
		printf '\n\n<!--Begin markdown generated content-->\n\n'
		"$MARKDOWN" < "$srcdir"/"$file".md
		printf '\n\n<!--End markdown generated content-->\n\n'
		html_footer
	} >> "$destdir"/"$file".html
done

cd "$currentdir"

if [ "$blog" = 1 ]; then
	cat "$blogheader" > "$destdir"/"$blogdir"/index.html
	echo '		</ul>' >> "$destdir"/"$blogdir"/index.html

	if [ "$blogfiles" = 1 ]; then
		echo '		<ul id="blogpost">' >> "$destdir"/"$blogdir"/index.html

		# read and link section by section
		find "$srcdir"/"$blogdir" -type d ! -name "$blogdir" | sed 's#.*/##' | \
		while read section; do
			echo "<h2 id=\"section\">$section</h2>" >> "$destdir"/"$blogdir"/index.html
			# if section have files
			if [ "$(ls -A "$srcdir"/"$blogdir"/"$section")" ]; then
				section_dest="$(echo "$section" | sed s/\ /_/g)"
				mkdir -p "$destdir"/"$blogdir"/"$section_dest"

				# change dir to list
				cd "$srcdir"/"$blogdir"/"$section"

				# list files in reverse order, so newer posts stay on top
				for f in *; do echo "$f"; done | sort -r | while read -r file; do
					case "$file" in
						*.md)
							file="$(echo "$file" | sed 's/\.md//')"
							posttitle="$(sed 1q "$srcdir"/"$blogdir"/"$section"/"$file".md | sed s/#//)"
							postdate="$(sed -n 2p "$srcdir"/"$blogdir"/"$section"/"$file".md)"
							echo "          <li>$postdate - <a href=\""$section_dest"/"$file".html\">$posttitle</a></li>" >> \
								"$destdir"/"$blogdir"/index.html
							touch "$destdir"/"$blogdir"/"$section_dest"/"$file".html
						{
							cat "$blogheader2"
							echo '		</ul>'
							echo "<h1 id=\"posttitle\">$posttitle</h1>"
							echo "<h2 id=\"postdate\">Written in: $postdate</h2>"
							printf '\n\n<!--Begin markdown generated content-->\n\n'
							sed 1,2d "$srcdir"/"$blogdir"/"$section"/"$file".md | "$MARKDOWN"
							printf '\n\n<!--End markdown generated content-->\n\n'
							if [ "$comment_script" ]; then
								html_footer yes
							fi
						} > "$destdir"/"$blogdir"/"$section_dest"/"$file".html
						printf "\tMARKDOWN: $section/$file"'\n'
						;;

						*.link)
							file="$(echo "$file" | sed 's/\.link//')"
							echo link file found: "$file"
							posttitle="$(sed 1q "$srcdir"/"$blogdir"/"$section"/"$file".link | sed s/#//)"
							postdate="$(sed -n 2p "$srcdir"/"$blogdir"/"$section"/"$file".link)"
							postlink="$(sed -n 3p "$srcdir"/"$blogdir"/"$section"/"$file".link)"
							echo LINK POST  $postlink
							echo "          <li>$postdate - <a href=\""$postlink"\">$posttitle</a></li>" >> \
								"$destdir"/"$blogdir"/index.html
						;;
					esac
				done
				cd "$currentdir"
			else
				echo '<p>Nothing on this category</p>' >> "$destdir"/"$blogdir"/index.html
			fi
	done
		echo '		</ul>' >> "$destdir"/"$blogdir"/index.html
	else
		echo "<p id=\"warn\">There's nothing here, yet</p>" >> "$destdir"/"$blogdir"/index.html
	fi
	html_footer >> "$destdir"/"$blogdir"/index.html
	rm "$blogheader"
fi
	rm "$header"
	if [ "$blogfiles" = 1 ]; then
		rm "$blogheader2"
	fi

	printf '\n'
	echo "site built"
	exit 0
