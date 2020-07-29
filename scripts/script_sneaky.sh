#! /bin/bash

for ((i=1; i<=10000; i++)); do

	random_idx=$RANDOM
	begin=$2
	let "begin -= 4"
	let "random_idx %= $begin"
	let "begin -= $random_idx"
	dd if=$1 of=hard_woody1 bs=1 count=$begin > /dev/null 2>&1
	dd if=/dev/urandom of=hard_woody2 bs=1 count=$4 > /dev/null 2>&1
	dd if=$1 of=hard_woody1 bs=1 count=$begin seek=$random_idx > /dev/null 2>&1
	cat hard_woody2 >> hard_woody1
	echo "sneaky : $i"
	./woody_woodpacker hard_woody1 > /dev/null 2>&1
	if [ $? -gt 2 ]
	then
		valgrind ./woody_woodpacker hard_woody1
		exit 1
	fi
done
