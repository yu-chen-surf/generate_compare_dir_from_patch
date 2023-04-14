#!/bin/bash

# As a Linux Kernel newbie, it usually drives me mad when
# reviewing other's patch. Since the patches are in diff format,
# it is quite hard to get the whole picture of what and where
# this patch has changed.
#
# This script generates two directories according to the patch
# content. The first one is 'old', the other one is 'new'. The
# 'old' directory contains the files that are involved in this
# patch, but has not been modified by the patch, AKA, the original
# files. The 'new' also contains the files that are mentioned
# in the patch, but with the patch applied.
# In this way, the user can compare the full content of corresponding
# files very conveniently, by launching:
# meld compare_dir/old compare_dir/new
#
#

if [ $# != 1 ]; then
echo "USAGE: cd source_code_dir"
echo "       $0 patch_file"
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
		if [ -f "$file" ];then
			cp $file $OLD_DIR"/"$dir"/"
		fi
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
		old_file=$OLD_DIR"/"$file
		if [ -f "$old_file" ];then
			cp $old_file $file
		else
			rm $file
		fi
	fi
done


