## Build Functions ##

# problem with this if it more files added
# but existing don't change sum will be ok
function createChecksumFile {
	top_dir=$1
	out_file=$2
	# empty out_file, if exists
	cat /dev/null > $out_file
	files=$(find $top_dir -type f)
	# $(find public_html -type f -name *.php)
	for f in $files
	do
		MD5SUM=$(md5sum -b $f)
		echo $MD5SUM >> $out_file
	done
	# return somethign
}

# quickest way to checksum checksums! and compare
# in case of any new files in one package, could be missed
# could be issue with binary'*' and text' '
function compareChecksumFiles {
	SUM1=$(md5sum $1 | cut -f 1 -d' ')
	SUM2=$(md5sum $2 | cut -f 1 -d' ')
	if [ "$SUM1" = "$SUM2" ] ; then
		return 0
	else
		return 1
	fi
}

function buildApp {
	top_dir=$1
	files=$(find $top_dir -type f)
}