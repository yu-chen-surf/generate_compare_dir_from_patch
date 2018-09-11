#!/bin/bash

if [ $# != 1 ]; then
echo "USAGE: $0 patch_file"
echo " e.g.: $0 0001-x86-fix-s4.patch"
exit 1;
fi

OLD_DIR="compare_dir/old"
NEW_DIR="compare_dir/new"
patch_files=`cat "$1" | grep diff`
OLD_IFS="$IFS"
IFS=" "
array=($patch_files)
IFS="$OLD_IFS"

if [ ! -d "$OLD_DIR" ];then
	mkdir -p $OLD_DIR
fi
if [ ! -d "$NEW_DIR" ];then
	mkdir -p $NEW_DIR
fi

# copy the original files
for var in ${array[@]}
do
	if [[ "$var" =~ ^a/.* ]]; then
		file=${var:2}
		echo "Copying original "$file"..."
		dir=${file%/*}
		if [ ! -d "$OLD_DIR/$dir" ];then
			mkdir -p $OLD_DIR"/"$dir
		fi
		cp $file $OLD_DIR"/"$dir"/"
	fi
done

echo "Patch it!"
# patch it!
git apply $1

if [ $? -ne 0 ]; then
    echo "git apply fail"
	exit 1;
fi

# copy the patched files
for var in ${array[@]}
do
	if [[ "$var" =~ ^a/.* ]]; then
		file=${var:2}
		dir=${file%/*}
		echo "Copying patched "$file"..."
		if [ ! -d "$NEW_DIR/$dir" ];then
			mkdir -p $NEW_DIR"/"$dir
		fi
		cp $file $NEW_DIR"/"$dir"/"
		#rollback!
		cp $OLD_DIR"/"$file $file
	fi
done


