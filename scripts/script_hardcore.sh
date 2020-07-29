#! /bin/bash

for ((i=1; i<=10000; i++)); do

	random_cpy=$RANDOM
	let "random_cpy %= $2"
	begin=$2
	let "begin -= $random_cpy"
	dd if=$1 of=hard_woody1 bs=1 count=$begin > /dev/null 2>&1
	dd if=/dev/urandom of=hard_woody2 bs=1 count=$random_cpy > /dev/null 2>&1
	cat hard_woody2 >> hard_woody1
	echo "hardcore : $i"
	./woody_woodpacker hard_woody1 > /dev/null 2>&1
	if [ $? -gt 2 ]
	then
		valgrind ./woody_woodpacker hard_woody1
		exit 1
	fi
done
