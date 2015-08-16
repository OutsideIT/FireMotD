#!/bin/bash

# Script name:          generate_motd.sh
# Version:              v2.17.150813
# Created on:           10/02/2014
# Author:               Willem D'Haese
# Purpose:              Bash script that will dynamically generate a message of they day for users logging in.
# On GitHub:            https://github.com/willemdh/generate_motd
# On OutsideIT:         http://outsideit.net/generate-motd
# Recent History:
#	13/07/2015 => Massive cleanup, prep for custom color themes and added days to uptime and number of cores
#	21/07/2015 => Introduction of 'Red' and 'Blue' themes
#	30/07/2015 => Added exticode and cleanup
#	12/08/2015 => Added version to output
#	13/08/2015 => Finalized version insertion
# Copyright:
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any 
# later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public 
# License for more details. You should have received a copy of the GNU General Public License along with this 
# program.  If not, see <http://www.gnu.org/licenses/>.
# Examples:
#       Blanco  => ./generate_motd.sh
#       Blue    => ./generate_motd.sh Blue
#       Red     => ./generate_motd.sh Red

# Some fun from the past
# for i in {17..21} {21..17} ; do ShortBlueScheme+="\e[38;5;${i}m#\e[0m"  ; done ;
# for i in {17..21} {21..17} ; do BlueScheme+="\e[38;5;${i}m#\e[0m\e[38;5;${i}m#\e[0m"  ; done ;
# for i in {17..21} {21..17} ; do LongBlueScheme+="\e[38;5;${i}m#\e[0m\e[38;5;${i}m#\e[0m\e[38;5;${i}m#"  ; done ;

Theme=$1

ScriptName="`readlink -e $0`"
ScriptVersion=" `cat $ScriptName | grep "# Version:" | awk {'print $3'} | tr -cd '[[:digit:].-]' | sed 's/.\{2\}$//'` "

# CPU Utilisation
CpuUtil=`LANG=en_GB.UTF-8 mpstat 1 1 | awk '$2 ~ /CPU/ { for(i=1;i<=NF;i++) { if ($i ~ /%idle/) field=i } } $2 ~ /all/ { print 100 - $field}' | tail -1`
CpuProc="`cat /proc/cpuinfo | grep processor | wc -l` core(s)."

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

# Markup
MaxLeftOverChars=35
Hostname=`hostname`
HostChars=$((${#Hostname} + 8))
LeftoverChars=$((MaxLeftOverChars - HostCHars -10))

if [[ $Theme = "Blue" ]] ; then
        # 16 Color Blue Frame Scheme
        # Blue
        Sch1="\e[0;34m#####"
        # Light Blue
        Sch2="\e[1;34m#####"
        # Light Cyan
        Sch3="\e[1;36m#####"
        # Cyan
        Sch4="\e[0;36m#####"
        # Pre-Host Scheme
        PrHS=$Sch1$Sch1$Sch2$Sch2
        # Host Scheme Top
        HST="\e[1;36m`head -c $HostChars /dev/zero|tr '\0' '#'`"
        # Host Scheme Top Filler
        HSF="\e[1;36m###"
        # Host Scheme Bot
        HSB="\e[1;34m`head -c $HostChars /dev/zero|tr '\0' '#'`"
        # Post Host Scheme
        PHS="\e[1;34m`head -c $LeftoverChars /dev/zero|tr '\0' '#'`"
        # Host Version Filler
        HVF="\e[1;34m`head -c 9 /dev/zero|tr '\0' '#'`"
        # Front Scheme
        FrS="\e[0;34m##"
        # Equal Scheme
        ES="\e[1;34m="
        # 16 Color Green Value Scheme
        # Host Color
        HC="\e[1;32m"
        # Green Value Color
        VC="\e[0;32m"
        # Light Green Value Color
        VCL="\e[1;32m"
        # Light Yellow Key Color
        KS="\e[1;33m"
        # Version Color
        SVC="\e[1;36m"
elif [[ $Theme = "Red" ]] ; then
        # 16 Color Red Frame Scheme
        # Red
        Sch1="\e[0;31m#####"
        # Light Red
        Sch2="\e[1;31m#####"
        # Light Yellow
        Sch3="\e[1;33m#####"
        # Yellow
        Sch4="\e[0;33m#####"
        # Pre-Host Scheme
        PrHS=$Sch1$Sch1$Sch2$Sch2
        # Host Scheme Top
        HST="\e[1;33m`head -c $HostChars /dev/zero|tr '\0' '#'`"
        # Host Scheme Top Filler
        HSF="\e[1;33m###"
        # Host Scheme Bot
        HSB="\e[0;31m`head -c $HostChars /dev/zero|tr '\0' '#'`"
        # Post Host Scheme
        PHS="\e[2;31m`head -c $LeftoverChars /dev/zero|tr '\0' '#'`"
	# Host Version Filler
	HVF="\e[2;31m`head -c 9 /dev/zero|tr '\0' '#'`"
        # Front Scheme
        FrS="\e[0;31m##"
        # Equal Scheme
        ES="\e[1;31m="
        # 16 Color Yellow Value Scheme
        # Host Color
        HC="\e[1;37m"
        # Yellow Value Color
        VC="\e[0;33m"
        # Light Yellow Value Color
        VCL="\e[1;33m"
        # Light Yellow Key Color
        KS="\e[0;37m"
	# Version Color
	SVC="\e[1;33m"
fi

echo -e "
$PrHS$Sch2$HST$Sch2$PHS$Sch1
$PrHS$Sch3$HSF $HC$Hostname $HSF$Sch3$HSF$HVF$SVC$ScriptVersion$Sch1
$PrHS$Sch2$HST$Sch2$PHS$Sch1
$FrS          ${KS}Ip $ES ${VCL}`ip route get 8.8.8.8 | head -1 | cut -d' ' -f8`
$FrS     ${KS}Release $ES ${VC}`cat /etc/*release | head -n 1`
$FrS      ${KS}Kernel $ES ${VC}`uname -rs`
$FrS      ${KS}Uptime $ES ${VC}`awk '{print int($1/86400)" day(s) "int($1%86400/3600)":"int(($1%3600)/60)":"int($1%60)}' /proc/uptime`
$FrS    ${KS}CPU Util $ES ${VCL}$CpuUtil ${VC}% average CPU usage over $CpuProc
$FrS    ${KS}CPU Load $ES ${VC}`uptime | grep -ohe '[s:][: ].*' | awk '{ print "1m: "$2 " 5m: "$3 " 15m: " $4}'`
$FrS      ${KS}Memory $ES ${VC}Free: ${VCL}${MemFree}${VC} GB, Used: ${VCL}${MemUsed}${VC} GB, Total: ${VCL}${MemTotal}${VC} GB
$FrS        ${KS}Swap $ES ${VC}Free: ${VCL}${SwapFree}${VC} GB, Used: ${VCL}${SwapUsed}${VC} GB, Total: ${VCL}${SwapTotal}${VC} GB
$FrS        ${KS}Root $ES ${VC}Free: ${VCL}${RootFree}${VC} GB, Used: ${VCL}${RootUsed}${VC} GB, Total: ${VCL}${RootTotal}${VC} GB
$FrS     ${KS}Updates $ES ${VCL}`cat /tmp/yum_updates.txt` ${VC}yum updates available.
$FrS    ${KS}Sessions $ES ${VCL}`who | grep $USER | wc -l` ${VC}sessions
$FrS   ${KS}Processes $ES ${VCL}`ps -Afl | wc -l` ${VC}running processes of ${VCL}`ulimit -u` ${VC}maximum processes
$PrHS$Sch2$HSB$Sch2$PHS$Sch1
\e[0;37m"
exit 0
