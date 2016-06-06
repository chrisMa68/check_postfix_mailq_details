#!/bin/sh
# Plugin: check_postfix_mailq_detail
# Copyright 2016, Christopher Wieser
# 
# Created: 2016-06  (mail@opso-it.de)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#Define Variables
Version="0.5"
. /usr/lib/nagios/plugins/utils.sh
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
		echo "Insufficient Permissions to "$dir_post"active" 
	        echo "Fix the Permissions or use the Script mailq_details.sh as a Cronjob"
	        echo "Do you use the Script mailq_details.sh, then disable this test and the 
	        Lines 46,47 and 48 and activate the lines 50,51,52"
		exit 2
	fi
	if [ ! -x $programm ]
	then
	        echo "qshape dosen't exist. Install postfix-doc and set the x-bit to qshape"
		exit 2	
       	fi

#Monitoring user has access to /var/spool/postfix/active
postfix_active=`$programm $dir_post/active | awk ' $1 ~ "TOTAL" {print $2 } '`
postfix_deferred=`$programm $dir_post/deferred | awk ' $1 ~ "TOTAL" {print $2 }'`
postfix_incoming=`$programm $dir_post/incoming | awk ' $1 ~ "TOTAL" {print $2 } '`
#Monitoring user has no access an the script XXX is usered
#postfix_active=`cat $dir_log/active`
#postfix_deferred=`cat $dir_log/deferred`
#postfix_incoming=`cat $dir_log/incoming`
##################################
EXIT_STATUS=$STATE_OK
#########################
#Define your Warn & Critical values
##########################
warn_total=1500
warn_incoming=500
warn_deferred=500
warn_active=500
crit_total=3000
crit_incoming=1000
crit_deferred=1000
crit_active=1000
## Print usage
usage() {
		echo " check_postfix_detail_details $VERSION - Monitoring Postfix  mail queue check script"
		echo ""
		echo " Usage: check_postfix_mailq_details "
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

