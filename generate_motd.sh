#!/bin/bash

# Script name: 		generate_motd.sh
# Version: 			1.15.01.09
# Created on: 		10/02/2014
# Author: 			Willem D'Haese
# Purpose:  		Bash tool to display system information after logging into a Linux CentOS server.
# On Github:		https://github.com/willemdh/generate_motd
# On OutsideIT:		http://outsideit.net/generate-motd
# History:
#	10/02/2014 => Creation date
#	15/11/2014 => Added yum update info: "00 0 * * * /usr/local/bin/count_yum_updates.sh > /tmp/yum_updates.txt"
#	17/11/2014 => Added root information and cleanup memory
#	18/11/2014 => Edits to memory output, cleanup yum for 0 updates
#	09/01/2014 => Using printf to avoid missing leading zeroes
# Copyright:
#	This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published
#	by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed 
#	in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
#	PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public 
#	License along with this program.  If not, see <http://www.gnu.org/licenses/>.

for i in {17..21} {21..17} ; do SHORTBLUESCHEME+="\e[38;5;${i}m#\e[0m"  ; done ;
for i in {17..21} {21..17} ; do BLUESCHEME+="\e[38;5;${i}m#\e[0m\e[38;5;${i}m#\e[0m"  ; done ;
for i in {17..21} {21..17} ; do LONGBLUESCHEME+="\e[38;5;${i}m#\e[0m\e[38;5;${i}m#\e[0m\e[38;5;${i}m#"  ; done ;

# Memory usage Information
MEMFREEB=`cat /proc/meminfo | grep MemFree | awk {'print $2'}`
MEMTOTALB=`cat /proc/meminfo | grep MemTotal | awk {'print $2'}`
MEMUSEDB=`expr $MEMTOTALB - $MEMFREEB`
# The old way => Not displaying leading zero when less then 1 GB memory
# MEMFREE=$(echo "scale=2; $MEMFREEB / 1024 / 1024" | bc)
# MEMUSED=$(echo "scale=2; $MEMUSEDB / 1024 / 1024" | bc)
# MEMTOTAL=$(echo "scale=2; $MEMTOTALB / 1024 / 1024" | bc)
MEMFREE=`printf "%0.2f\n" $(bc -q <<< scale=2\;$MEMFREEB/1024/1024)`
MEMUSED=`printf "%0.2f\n" $(bc -q <<< scale=2\;$MEMUSEDB/1024/1024)`
MEMTOTAL=`printf "%0.2f\n" $(bc -q <<< scale=2\;$MEMTOTALB/1024/1024)`

# Swap Usage Information
SWAPFREEB=`cat /proc/meminfo | grep SwapFree | awk {'print $2'}`
SWAPTOTALB=`cat /proc/meminfo | grep SwapTotal | awk {'print $2'}`
SWAPUSEDB=`expr $SWAPTOTALB - $SWAPFREEB`
# The old way => Not displaying leading zero when less then 1 GB swap
# SWAPFREE=$(echo "scale=2; $SWAPFREEB / 1024 / 1024" | bc)
# SWAPUSED=$(echo "scale=2; $SWAPUSEDB / 1024 / 1024" | bc)
# SWAPTOTAL=$(echo "scale=2; $SWAPTOTALB / 1024 / 1024" | bc)
SWAPFREE=`printf "%0.2f\n" $(bc -q <<< scale=2\;$SWAPFREEB/1024/1024)`
SWAPUSED=`printf "%0.2f\n" $(bc -q <<< scale=2\;$SWAPUSEDB/1024/1024)`
SWAPTOTAL=`printf "%0.2f\n" $(bc -q <<< scale=2\;$SWAPTOTALB/1024/1024)`

# Root Usage Information
ROOTFREEB=`df -k / | tail -1 | awk '{print $3}'`
ROOTUSEDB=`df -k / | tail -1 | awk '{print $2}'`
ROOTTOTALB=`expr $ROOTFREEB + $ROOTUSEDB`
# The old way => Not displaying leading zero when less then 1 GB free space
# ROOTFREE=$(echo "scale=2; $ROOTFREEB / 1024 / 1024" | bc)
# ROOTUSED=$(echo "scale=2; $ROOTUSEDB / 1024 / 1024" | bc)
# ROOTTOTAL=$(echo "scale=2; $ROOTTOTALB / 1024 / 1024" | bc)
ROOTFREE=`printf "%0.2f\n" $(bc -q <<< scale=2\;$ROOTFREEB/1024/1024)`
ROOTUSED=`printf "%0.2f\n" $(bc -q <<< scale=2\;$ROOTUSEDB/1024/1024)`
ROOTTOTAL=`printf "%0.2f\n" $(bc -q <<< scale=2\;$ROOTTOTALB/1024/1024)`

# Old way for getting CPU utilization information
# CPUUTIL=`mpstat 1 1 | awk '$2 ~ /CPU/ { for(i=1;i<=NF;i++) { if ($i ~ /%idle/) field=i } } $2 ~ /all/ { print 100 - $field "%"}'`

echo -e "
$BLUESCHEME$LONGBLUESCHEME$BLUESCHEME$SHORTBLUESCHEME
$BLUESCHEME \e[38;5;93m `hostname`
$BLUESCHEME$LONGBLUESCHEME$BLUESCHEME$SHORTBLUESCHEME
\e[0;34m+        \e[38;5;39mIp \e[38;5;93m= \e[38;5;27m`/sbin/ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'`
\e[0;34m+   \e[38;5;39mRelease \e[38;5;93m= \e[38;5;27m`cat /etc/*release | head -n 1`
\e[0;34m+    \e[38;5;39mKernel \e[38;5;93m= \e[38;5;27m`uname -rs`
\e[0;34m+    \e[38;5;39mUptime \e[38;5;93m= \e[38;5;27m`awk '{print int($1/3600)":"int(($1%3600)/60)":"int($1%60)}' /proc/uptime`
\e[0;34m+  \e[38;5;39mCPU Util \e[38;5;93m= \e[38;5;27m`LANG=en_GB.UTF-8 mpstat 1 1 | awk '$2 ~ /CPU/ { for(i=1;i<=NF;i++) { if ($i ~ /%idle/) field=i } } $2 ~ /all/ { print 100 - $field "%"}' | tail -1`
\e[0;34m+  \e[38;5;39mCPU Load \e[38;5;93m= \e[38;5;27m`uptime | grep -ohe '[s:][: ].*' | awk '{ print "1m: "$2 " 5m: "$3 " 15m: " $4}'`
\e[0;34m+    \e[38;5;39mMemory \e[38;5;93m= \e[38;5;27mFree: ${MEMFREE}GB, Used: ${MEMUSED}GB, Total: ${MEMTOTAL}GB
\e[0;34m+      \e[38;5;39mSwap \e[38;5;93m= \e[38;5;27mFree: ${SWAPFREE}GB, Used: ${SWAPUSED}GB, Total: ${SWAPTOTAL}GB
\e[0;34m+      \e[38;5;39mRoot \e[38;5;93m= \e[38;5;27mFree: ${ROOTFREE}GB, Used: ${ROOTUSED}GB, Total: ${ROOTTOTAL}GB
\e[0;34m+   \e[38;5;39mUpdates \e[38;5;93m= \e[38;5;27m`cat /tmp/yum_updates.txt` yum updates available
\e[0;34m+  \e[38;5;39mSessions \e[38;5;93m= \e[38;5;27m`who | grep $USER | wc -l` sessions
\e[0;34m+ \e[38;5;39mProcesses \e[38;5;93m= \e[38;5;27m`ps -Afl | wc -l` running processes of `ulimit -u` maximum processes
$BLUESCHEME$LONGBLUESCHEME$BLUESCHEME$SHORTBLUESCHEME
\e[0;37m
"


