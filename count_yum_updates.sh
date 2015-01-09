#!/bin/sh

# Script name: count_yum_updates.sh
# Version: 0.14.11.18
# Author: Willem D'Haese
# Created on: 15/11/2014
# Purpose: Bash script that will output total number of yum updates
# History:
#       15/11/2014 => Script creation
#       18/11/2014 => if statement in case 0 updates available (else -1)
# Copyright:
# This program is free software: you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.You should have received a copy of the GNU
# General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

IFACE=eth0

if [ -n "$(/sbin/ifconfig $IFACE | /bin/grep RUNNING)" ]; then
        YUMCOUNT=`/usr/bin/yum -d 0 check-update 2>/dev/null | echo $(($(wc -l)-1))`
        if [ $YUMCOUNT == -1 ]; then
                YUMCOUNT=0
        fi
        echo "$YUMCOUNT"
fi

exit 0

