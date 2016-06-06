#!/bin/bash
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
