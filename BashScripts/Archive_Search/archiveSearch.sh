#!/bin/bash

EXPECTED_ARGS=2
if [ $# -ne $EXPECTED_ARGS ]; then
	echo "Wrong Number of Arguments; Only $EXPECTED_ARGS accepted"
	exit 1
fi

archive_name="$1"
file_ext="$2"
file_ext_reg_ex="*$file_ext"

echo $archive_name

archive_list=$(tar -xvzf $archive_name)
phrase="SPRING26"

file_count=0
for file in $archive_list; do
	if [[ "$file" == $file_ext_reg_ex ]]; then
		((file_count++))	
		if grep -q $phrase $file; then
		line_number=$(grep -n $phrase $file | cut -d: -f1)
		correct_file=$file
		fi
	fi
done

correct_file_name=$(basename $correct_file)

echo "There were $file_count $file_ext file(s)"
echo "The file that contained the phrase \"$phrase\" was $correct_file_name"
echo "$correct_file_name contains $(wc -l <  $correct_file) lines"
echo "The file contained the phrase \"$phrase\" on line $line_number"
