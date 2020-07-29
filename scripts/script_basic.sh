#! /bin/bash

for OUT in /usr/bin/*;
do
	echo "$OUT"
	./woody_woodpacker $OUT > /dev/null 2>&1
	if [ $? -gt 2 ]
	then
		valgrind ./woody_woodpacker $OUT
		exit 1
	fi
done
for OUT in /bin/*;
do
	echo "$OUT"
	./woody_woodpacker $OUT > /dev/null 2>&1
	if [ $? -gt 2 ]
	then
		valgrind ./woody_woodpacker $OUT
		exit 1
	fi
done
for OUT in /sbin/*;
do
	echo "$OUT"
	./woody_woodpacker $OUT > /dev/null 2>&1
	if [ $? -gt 2 ]
	then
		valgrind ./woody_woodpacker $OUT
		exit 1
	fi
done
for OUT in /usr/lib/*;
do
	echo "$OUT"
	./woody_woodpacker $OUT > /dev/null 2>&1
	if [ $? -gt 2 ]
	then
		valgrind ./woody_woodpacker $OUT
		exit 1
	fi
done
for OUT in /usr/sbin/*;
do
	echo "$OUT"
	./woody_woodpacker $OUT > /dev/null 2>&1
	if [ $? -gt 2 ]
	then
		valgrind ./woody_woodpacker $OUT
		exit 1
	fi
done
for OUT in obj/*;
do
	echo "$OUT"
	./woody_woodpacker $OUT > /dev/null 2>&1
	if [ $? -gt 2 ]
	then
		valgrind ./woody_woodpacker $OUT
		exit 1
	fi
done

