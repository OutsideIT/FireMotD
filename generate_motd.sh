#!/bin/bash

# Script name: generate_motd.sh
# Version: 0.14.11.15
# Author: Willem D'Haese
# Created on: 10/02/2014
# Purpose: Bash script that will dynamically generate a message of they day for users logging in.
# History:
#       10/02/2014 => Creation date
#       15/11/2014 => Added yum update info: "00 0 * * * /usr/local/bin/count_yum_updates.sh > /tmp/yum_updates.txt"
# Copyright:
# This program is free software: you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.You should have received a copy of the GNU
# General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

for i in {17..21} {21..17} ; do SHORTBLUESCHEME+="\e[38;5;${i}m#\e[0m"  ; done ;
for i in {17..21} {21..17} ; do BLUESCHEME+="\e[38;5;${i}m#\e[0m\e[38;5;${i}m#\e[0m"  ; done ;
for i in {17..21} {21..17} ; do LONGBLUESCHEME+="\e[38;5;${i}m#\e[0m\e[38;5;${i}m#\e[0m\e[38;5;${i}m#"  ; done ;

echo -e "
$BLUESCHEME$LONGBLUESCHEME$BLUESCHEME$SHORTBLUESCHEME
$BLUESCHEME \e[38;5;93m `hostname`              
$BLUESCHEME$LONGBLUESCHEME$BLUESCHEME$SHORTBLUESCHEME
\e[0;34m+        \e[38;5;39mIp \e[38;5;93m= \e[38;5;27m`/sbin/ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'`
\e[0;34m+        \e[38;5;39mOS \e[38;5;93m= \e[38;5;27m`cat /etc/*release | head -n 1`
\e[0;34m+    \e[38;5;39mKernel \e[38;5;93m= \e[38;5;27m`uname -rs` 
\e[0;34m+    \e[38;5;39mUptime \e[38;5;93m= \e[38;5;27m`awk '{print int($1/3600)":"int(($1%3600)/60)":"int($1%60)}' /proc/uptime`
\e[0;34m+  \e[38;5;39mCPU Load \e[38;5;93m= \e[38;5;27m`uptime | grep -ohe '[s:][: ].*' | awk '{ print "1m: "$2 " 5m: "$3 " 15m: " $4}'`
\e[0;34m+    \e[38;5;39mMemory \e[38;5;93m= \e[38;5;27m`cat /proc/meminfo | grep MemFree | awk {'print $2'}` kB Free / `cat /proc/meminfo | grep MemTotal | awk {'print $2'}` kB Total 
\e[0;34m+   \e[38;5;39mUpdates \e[38;5;93m= \e[38;5;27m`cat /tmp/yum_updates.txt` yum updates available
\e[0;34m+  \e[38;5;39mSessions \e[38;5;93m= \e[38;5;27m`who | grep $USER | wc -l` sessions
\e[0;34m+ \e[38;5;39mProcesses \e[38;5;93m= \e[38;5;27m`ps -Afl | wc -l` running processes of `ulimit -u` maximum processes
$BLUESCHEME$LONGBLUESCHEME$BLUESCHEME$SHORTBLUESCHEME
\e[0;37m                                                                               
"

