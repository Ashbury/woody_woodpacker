#! /bin/bash

for (( i=1; i<=$2; i++))
	do
	newfsize=$2
	((newfsize-=$i))
	echo "degr : $newfsize"
	dd if=$1 of=degr_woody bs=1 count=$newfsize > /dev/null 2>&1
	./woody_woodpacker degr_woody > /dev/null 2>&1
	if [ $? -gt 2 ]
	then
		valgrind ./woody_woodpacker degr_woody
		exit 1
	fi
done
