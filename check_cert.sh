#!/bin/bash

##################################################################
# Simple script using curl to check certificate expiration date. #
# This script can be used in nagios as plugin.                   #
# Created by: vojda 						 #
##################################################################

HOST=$1
MDY=$(curl --insecure -v https://"$HOST" 2>&1 | grep "expire date" | cut -f 2- -d ":" | awk '{print $1,$2,$4}')
MDHY=$(curl --insecure -v https://"$HOST" 2>&1 | grep "expire date" | cut -f 2- -d ":")
EXPIRE_DATE=$(date -d "$MDY" +'%s')
CURRENT_DATE=$(date "+%s")
DIFF_DATE=$(($EXPIRE_DATE-$CURRENT_DATE))


if [ $# -eq 0 ]
then 
	echo "How to use: ./check_cert.sh <HOST> <Warning days> <Critical days>"
	echo "Example: ./check_cert.sh google.com 20 10"
	echo "Check certificate only: ./check_cert.sh <HOST>"
	exit 0
elif [ $# -eq 1 ]
	then
		echo "The certificate is valid to: $MDHY"
		exit 0
fi

WARNING_DATE=$(($2 * 86000))
CRITICAL_DATE=$(($3 * 86000))

#echo "$CURRENT_DATE"
#echo "$WARNING_DATE"
#echo "$CRITICAL_DATE"
#echo "$EXPIRE_DATE"
#echo "$DIFF_DATE"

#Compare dates

if [ "$WARNING_DATE" -ge "$DIFF_DATE" ]
	then
		echo "Warning!! The certificate is going to expire. Expiration date: $MDY"
		exit 1
	elif [ "$CRITICAL_DATE" -ge "$DIFF_DATE" ]
			then
				echo "Critical!! The certificate is going to expire. Expiration date: $MDY"
				exit 2
	else
		echo "OK!! The certificate is valid to: $MDY"
		exit 0
fi


