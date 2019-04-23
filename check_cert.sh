#!/bin/bash

##################################################################
# Simple script using curl to check certificate expiration date. #
# This script can be used in nagios as plugin.			 #
# Author: vojda					 		 #	
##################################################################

HOST=$1
MDY=$(curl --insecure -v https://"$HOST" 2>&1 | grep "expire date" | cut -f 2- -d ":" | awk '{print $1,$2,$4}')
MDHY=$(curl --insecure -v https://"$HOST" 2>&1 | grep "expire date" | cut -f 2- -d ":")
EXPIRE_DATE=$(date -d "$MDY" +'%s')
CURRENT_DATE=$(date "+%s")
DIFF_DATE=$((($EXPIRE_DATE-$CURRENT_DATE)/(3600*24)))
WDATE=$(date -d "$MDY -$2 days" +'%s')
CDATE=$(date -d "$MDY -$3 days" +'%s')
DIFF_WARN=$((($EXPIRE_DATE-$WDATE)/(3600*24)))
DIFF_CRIT=$((($EXPIRE_DATE-$CDATE)/(3600*24)))

if [ $# -eq 0 ]
then 
	echo "How to use: ./check_cert.sh <HOST> <Warning days> <Critical days>"
	echo "Example: ./check_cert.sh google.com 20"
	echo "Check certificate only: ./check_cert.sh <HOST>"
	exit 0
elif [ $# -eq 1 ]
	then
		echo "The certificate is valid to: $MDHY"
		exit 0
fi

#For troubleshoot
#echo "$DIFF_DATE"
#echo "$DIFF_WARN"
#echo "$DIFF_CRIT"

#Compare dates

if [ "$DIFF_CRIT" -ge "$DIFF_DATE" ]
	then
		echo "CRITICAL!! The certificate will expire after $DIFF_DATE days. Valid to: $MDY"
		exit 2
	elif [ "$DIFF_WARN" -ge "$DIFF_DATE" ]
	then
		echo "WARNING!! The certificate will expire after $DIFF_DATE days. Valid to: $MDY"
		exit 1
	else
		echo "OK!! The certificate is valid to: $MDY"
		exit 0
fi

