#!/bin/bash


EXPECTED_ARGS=2
if [ $# -ne $EXPECTED_ARGS ]; then
        echo "Wrong Number of Arguments; Only $EXPECTED_ARGS accepted"
        exit 1
fi


zipFileName="$1"
fileExtension="$2"
file_ext_reg_ex="*$fileExtension"



unzip -q "$zipFileName" -d extracted_files

for file in extracted_files/*; do
	echo "$file"
	if [[ "$file" == $file_ext_reg_ex ]]; then
		name=$(grep -m1 "Name:"   "$file" | cut -d ":" -f2- | tr -d '\r' | xargs)
		phone=$(grep -m1 "Phone:" "$file" | cut -d ":" -f2- | tr -d '\r' | xargs)
		email=$(grep -m1 "Email:" "$file" | cut -d ":" -f2- | tr -d '\r' | xargs)
		street=$(grep -m1 "Street:" "$file" | cut -d ":" -f2- | tr -d '\r' | xargs)
		city=$(grep -m1 "City:"   "$file" | cut -d ":" -f2- | tr -d '\r' | xargs)
		state=$(grep -m1 "State:" "$file" | cut -d ":" -f2- | tr -d '\r' | xargs)

		string="$name,$phone,$email,$street $city $state"
		echo $string | tee -a contacts.csv
	fi
done




rm -rf extracted_files
