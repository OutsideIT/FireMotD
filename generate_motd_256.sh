#!/bin/bash

# Script name: 			generate_motd.sh
# Version: 				v1.4.150415
# Created on: 			10/02/2014
# Author: 				Willem D'Haese
# Purpose: 				Bash script that will dynamically generate a message of they day for users logging in.
# On GitHub: 			https://github.com/willemdh/generate_motd
# On OutsideIT:			http://outsideit.net/generate-motd
# Recent History:
#       17/11/2014 => Added root information and cleanup memory
#       18/11/2014 => Edits to memory output, cleanup yum for 0 updates
#       09/01/2014 => Using printf to avoid missing leading zeroes
#       30/03/2015 => Replaced ifconfig with ip route so it works on CentOS 6 and 7
#		15/04/2015 => Prep for GitHub release and 16 color version
# Copyright:
#		This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published
#		by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed 
#		in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
#		PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public 
#		License along with this program.  If not, see <http://www.gnu.org/licenses/>.

for i in {17..21} {21..17} ; do ShortBlueScheme+="\e[38;5;${i}m#\e[0m"  ; done ;
for i in {17..21} {21..17} ; do BlueScheme+="\e[38;5;${i}m#\e[0m\e[38;5;${i}m#\e[0m"  ; done ;
for i in {17..21} {21..17} ; do LongBlueScheme+="\e[38;5;${i}m#\e[0m\e[38;5;${i}m#\e[0m\e[38;5;${i}m#"  ; done ;

# Memory usage Information
MemFreeB=`cat /proc/meminfo | grep MemFree | awk {'print $2'}`
MemTotalB=`cat /proc/meminfo | grep MemTotal | awk {'print $2'}`
MemUsedB=`expr $MemTotalB - $MemFreeB`
MemFree=`printf "%0.2f\n" $(bc -q <<< scale=2\;$MemFreeB/1024/1024)`
MemUsed=`printf "%0.2f\n" $(bc -q <<< scale=2\;$MemUsedB/1024/1024)`
MemTotal=`printf "%0.2f\n" $(bc -q <<< scale=2\;$MemTotalB/1024/1024)`

# Swap Usage Information
SwapFreeB=`cat /proc/meminfo | grep SwapFree | awk {'print $2'}`
SwapTotalB=`cat /proc/meminfo | grep SwapTotal | awk {'print $2'}`
SwapUsedB=`expr $SwapTotalB - $SwapFreeB`
SwapFree=`printf "%0.2f\n" $(bc -q <<< scale=2\;$SwapFreeB/1024/1024)`
SwapUsed=`printf "%0.2f\n" $(bc -q <<< scale=2\;$SwapUsedB/1024/1024)`
SwapTotal=`printf "%0.2f\n" $(bc -q <<< scale=2\;$SwapTotalB/1024/1024)`

# Root Usage Information
RootFreeB=`df -k / | tail -1 | awk '{print $3}'`
RootUsedB=`df -k / | tail -1 | awk '{print $2}'`
RootTotalB=`expr $RootFreeB + $RootUsedB`
RootFree=`printf "%0.2f\n" $(bc -q <<< scale=2\;$RootFreeB/1024/1024)`
RootUsed=`printf "%0.2f\n" $(bc -q <<< scale=2\;$RootUsedB/1024/1024)`
RootTotal=`printf "%0.2f\n" $(bc -q <<< scale=2\;$RootTotalB/1024/1024)`

echo -e "
$BlueScheme$LongBlueScheme$BlueScheme$ShortBlueScheme
$BlueScheme \e[38;5;93m `hostname`
$BlueScheme$LongBlueScheme$BlueScheme$ShortBlueScheme
\e[0;34m+        \e[38;5;39mIp \e[38;5;93m= \e[38;5;27m`ip route get 8.8.8.8 | head -1 | cut -d' ' -f8`
\e[0;34m+   \e[38;5;39mRelease \e[38;5;93m= \e[38;5;27m`cat /etc/*release | head -n 1`
\e[0;34m+    \e[38;5;39mKernel \e[38;5;93m= \e[38;5;27m`uname -rs`
\e[0;34m+    \e[38;5;39mUptime \e[38;5;93m= \e[38;5;27m`awk '{print int($1/3600)":"int(($1%3600)/60)":"int($1%60)}' /proc/uptime`
\e[0;34m+  \e[38;5;39mCPU Util \e[38;5;93m= \e[38;5;27m`LANG=en_GB.UTF-8 mpstat 1 1 | awk '$2 ~ /CPU/ { for(i=1;i<=NF;i++) { if ($i ~ /%idle/) field=i } } $2 ~ /all/ { print 100 - $field "%"}' | tail -1`
\e[0;34m+  \e[38;5;39mCPU Load \e[38;5;93m= \e[38;5;27m`uptime | grep -ohe '[s:][: ].*' | awk '{ print "1m: "$2 " 5m: "$3 " 15m: " $4}'`
\e[0;34m+    \e[38;5;39mMemory \e[38;5;93m= \e[38;5;27mFree: ${MemFree}GB, Used: ${MemUsed}GB, Total: ${MemTotal}GB
\e[0;34m+      \e[38;5;39mSwap \e[38;5;93m= \e[38;5;27mFree: ${SwapFree}GB, Used: ${SwapUsed}GB, Total: ${SwapTotal}GB
\e[0;34m+      \e[38;5;39mRoot \e[38;5;93m= \e[38;5;27mFree: ${RootFree}GB, Used: ${RootUsed}GB, Total: ${RootTotal}GB
\e[0;34m+   \e[38;5;39mUpdates \e[38;5;93m= \e[38;5;27m`cat /tmp/yum_updates.txt` yum updates available
\e[0;34m+  \e[38;5;39mSessions \e[38;5;93m= \e[38;5;27m`who | grep $USER | wc -l` sessions
\e[0;34m+ \e[38;5;39mProcesses \e[38;5;93m= \e[38;5;27m`ps -Afl | wc -l` running processes of `ulimit -u` maximum processes
$BlueScheme$LongBlueScheme$BlueScheme$ShortBlueScheme
\e[0;37m
"


