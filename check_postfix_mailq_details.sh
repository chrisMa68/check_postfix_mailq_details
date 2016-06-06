#!/bin/sh
# 23.3.2016 chw @ wkiv050
#
#Variablen festlegen
. /usr/lib/nagios/plugins/utils.sh
Version="0.5"
dir_log=/var/log/postfix
dir_post=/var/spool/postfix
# Chose the qshape location
#SLESE 12 
programm=/usr/share/doc/packages/postfix-doc/auxiliary/qshape/qshape.pl
#debian
#programm=/usr/sbin/qshape
##Test Permissions
	if  [ ! -r $dir_post/active ]
	then
		echo "Insufficient Permissions to "$dir_post"active" /n
	        echo "Fix the Permissions or use the Script XXX every 5 Miniutes as a Cronjob" 	
		exit 1
	fi
	if [ ! -x $programm ]
	then
	        echo "qshape.pl dosen't exist. Install postfix-doc and set the x-bit to qshape.pl"
		exit 1	
       	fi

#Monitoring user has access to /var/spool/postfix/active
postfix_active=`$programm $dir_post/active | awk ' $1 ~ "TOTAL" {print $2 } '`
postfix_deferred=`$programm $dir_post/deferred | awk ' $1 ~ "TOTAL" {print $2 }'`
postfix_incoming=`$programm $dir_post/incoming | awk ' $1 ~ "TOTAL" {print $2 } '`
#Monitoring user has no access an the script XXX is usered
#postfix_active=`cat $dir_log/active`
#postfix_deferred=`cat $dir_log/deferred`
#postfix_incoming=`cat $dir_log/incoming`
#
queue_id='^[A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9]'
qsize=$(mailq | egrep -c $queue_id)



##################################
EXIT_STATUS=$STATE_OK
#########################
#define your values
##########################
warn_total=1
warn_incoming=1
warn_deferred=1
warn_active=1
crit_total=1000
crit_incoming=1000
crit_deferred=1000
crit_active=1000
##############################
###
## Print usage
usage() {
		echo " check_postfixdetailqueue $VERSION - Monitoring Postfix  mail queue check script"
		echo ""
		echo " Usage: check_postfixmailqueue "
		echo " Please set the values for Warning and Critical in the script"
		echo ""
	}

commandline() {
	if ( `test 0 -lt $#` )
	then
	  while getopts h myoption "$@"
		do
			case $myoption in
			h) 
				usage
				exit;;
			*)
				exit;;
			esac
		done
	fi
}

commandline $@
##############
queue_id='^[A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9]'
qsize=$(mailq | egrep -c $queue_id)
############# Warn
if test "$postfix_deferred" -gt "$warn_deferred"; then
	EXIT_STATUS=$STATE_WARNING
	Warn[0]="Deferred"
fi

if test "$postfix_active" -gt "$warn_active"; then
	EXIT_STATUS=$STATE_WARNING
	Warn[1]="Active"
fi

if test "$postfix_incoming" -gt "$warn_incoming"; then
	EXIT_STATUS=$STATE_WARNING
	Warn[2]="Incoming"
fi

if test "$qsize" -gt "$warn_total"; then
	EXIT_STATUS=$STATE_WARNING
	Warn[3]="Total Mailq"
fi
if test -n "$Warn"; then
	WarnMessage="WARNUNG: ${Warn[*]}"
fi

#### Crit
if test "$postfix_deferred" -gt "$crit_deferred"; then
	EXIT_STATUS=$STATE_CRITICAL
	Crit[0]="Deferred"
fi

if test "$postfix_active" -gt "$crit_active"; then
	EXIT_STATUS=$STATE_CRITICAL
	Crit[1]="Active"
fi

if test "$postfix_incoming" -gt "$crit_incoming"; then
	EXIT_STATUS=$STATE_CRITICAL
 	Crit[2]="Incoming"
fi

if test "$qsize" -gt "$crit_total"; then
	EXIT_STATUS=$STATE_CRITICAL
 	Crit[3]="Total Mailq"
fi

if test -n "$Crit"; then
	CritMessage="CRITICAL: ${Crit[*]}"
fi

progra() {
	echo "Queue $WarnMessage $CritMessage (All:$qsize) im Detail: Incoming:$postfix_incoming Deferred:$postfix_deferred Active:$postfix_active | MailQueueALL=$qsize incoming=$postfix_incoming;$warn_incoming;$crit_incoming deferred=$postfix_deferred;$warn_deferred;$crit_deferred active=$postfix_active;$warn_active;$crit_active "
	exit $EXIT_STATUS
}

progra

