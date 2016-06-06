#!/bin/bash
dir_post=/var/spool/postfix
dir_log=/var/log/postfix

# Chose the qshape location
#SLESE 12 
programm=/usr/share/doc/packages/postfix-doc/auxiliary/qshape/qshape.pl
#debian
#programm=/usr/sbin/qshape

##### Test for Folder and Programms
depends () {
	if [ ! -d $dir_log ]
		then 
		echo "The Logfile Folder $dir_log dosen't exist. Create it !"
	fi
	if  [ ! -x $programm ]
		then
		echo "qshape.pl dosen't exist. Install postfix-doc and set the x-bit to qshape.pl"
	fi
	if [[ $EUID -ne 0 ]] 
		then
		echo "This script must be run as root, while the folder $dir_post only for root is readable"
	fi
}
############ Mailq write values
mailq_detail () {
	$programm $dir_post/deferred | awk ' $1 ~ "TOTAL" {print $2 > "'${dir_log}'/deferred" } ' 
	$programm $dir_post/incoming | awk ' $1 ~ "TOTAL" {print $2 > "'${dir_log}'/incoming" } ' 
	$programm $dir_post/active | awk ' $1 ~ "TOTAL" {print $2 > "'${dir_log}'/active" } '
}

depends
