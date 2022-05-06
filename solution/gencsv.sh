#!/bin/bash

if test -z "${1}"
then
	NUM=10
else
	NUM=${1}
fi

FILENAME='inputFile'

>${FILENAME}	## truncate file if script is run fresh


## Value of N for sequence
N=`expr ${NUM} - 1`

for i in `seq 0 ${N}`
do
	echo "${i}, ${RANDOM}" >> ${FILENAME}
done	
