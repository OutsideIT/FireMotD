#!/bin/bash
# Script name:          generate_motd.sh
# Version:              v3.15.160111
# Created on:           10/02/2014
# Author:               Willem D'Haese
# Purpose:              Bash script that will dynamically generate a message
#                       of they day for users logging in.
# On GitHub:            https://github.com/willemdh/generate_motd
# On OutsideIT:         https://outsideit.net/generate-motd
# Recent History:
#   28/12/15 => Better integration and parameter options
#   06/01/16 => Correct SUSE OS version and full separation of variables
#   09/01/16 => Splitup into function, introduction modern theme
#   10/01/16 => Implemented zypper update count
#   11/09/16 => Removed emtpy line from MotD
# Copyright:
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version. This program is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
# Public License for more details. You should have received a copy of the
# GNU General Public License along with this program.  If not, see
# <http://www.gnu.org/licenses/>.

Verbose=0

CountUpdates () {
    if [[ -x "/usr/bin/yum" ]] ; then
        UpdateCount=$(/usr/bin/yum -d 0 check-update 2>/dev/null | echo $(($(wc -l)-1)))
        if [ $UpdateCount == -1 ]; then
            UpdateCount=0
        fi
    elif [[ -x "/usr/bin/zypper" ]] ; then
        UpdateCount=$(zypper list-updates | wc -l) 
        UpdateCount=$(expr $UpdateCount - 4)
	if (( $UpdateCount <= 0 )) ; then
	    UpdateCount=0
	fi
    elif [[ -x "/usr/bin/apt-get" ]] ; then
        WriteLog Verbose Info "Apt-get detected (TODO)"
    fi
    echo "$UpdateCount"
    exit 0
}

GatherInfo () {
    ScriptName="$(readlink -e $0)"
    ScriptVersion=" $(cat $ScriptName | grep "# Version:" | awk {'print $3'} | tr -cd '[[:digit:].-]' | sed 's/.\{2\}$//') "
    OsVersion="$(cat /etc/*release | head -n 1)"
    if [[ "$OsVersion" == "SUSE"* ]] ; then
        OsVersion="$(echo $OsVersion | sed 's/ (.*//')"
        PatchLevel="$(cat /etc/*release | sed -n 3p | sed 's/.*= //')"
        OsVersion="${OsVersion}.$PatchLevel"
    elif [[ "$OsVersion" == "openSUSE"* ]] ; then
	OsVersion="$(cat /etc/os-release | sed -n 4p | sed 's/PRETTY_NAME="//' | sed 's/ (.*//')"
    fi
    IpAddress="$(ip route get 8.8.8.8 | head -1 | cut -d' ' -f8)"
    Kernel="$(uname -rs)"
    Uptime="$(awk '{print int($1/86400)" day(s) "int($1%86400/3600)":"int(($1%3600)/60)":"int($1%60)}' /proc/uptime)"
    Dmi="$(dmesg | grep "DMI:")"
    if [[ "$Dmi" = *"QEMU"* ]] ; then
        Platform="$(dmesg | grep "DMI:" | sed 's/^.*QEMU/QEMU/' | sed 's/, B.*//')"
    elif [[ "$Dmi" = *"VMware"* ]] ; then
        Platform="$(dmesg | grep "DMI:" | sed 's/^.*VMware/VMware/' | sed 's/, B.*//')"
    elif [[ "$Dmi" = *"FUJITSU PRIMERGY"* ]] ; then
        Platform="$(dmesg | grep "DMI:" | sed 's/^.*FUJITSU PRIMERGY/Fujitsu Primergy/' | sed 's/, B.*//')"
    elif [[ "$Dmi" = *"VirtualBox"* ]] ; then
        Platform="$(dmesg | grep "DMI:" | sed 's/^.*VirtualBox/VirtualBox/' | sed 's/ .*//')"
    else
        Platform="Unknown"
    fi
    CpuUtil="$(LANG=en_GB.UTF-8 mpstat 1 1 | awk '$2 ~ /CPU/ { for(i=1;i<=NF;i++) { if ($i ~ /%idle/) field=i } } $2 ~ /all/ { print 100 - $field}' | tail -1)"
    CpuProc="$(cat /proc/cpuinfo | grep processor | wc -l) core(s)."
    CpuLoad="$(uptime | grep -ohe '[s:][: ].*' | awk '{ print "1m: "$2 " 5m: "$3 " 15m: " $4}')"
    MemFreeB="$(cat /proc/meminfo | grep MemFree | awk {'print $2'})"
    MemTotalB="$(cat /proc/meminfo | grep MemTotal | awk {'print $2'})"
    MemUsedB="$(expr $MemTotalB - $MemFreeB)"
    MemFree="$(printf "%0.2f\n" $(bc -q <<< scale=2\;$MemFreeB/1024/1024))"
    MemUsed="$(printf "%0.2f\n" $(bc -q <<< scale=2\;$MemUsedB/1024/1024))"
    MemTotal="$(printf "%0.2f\n" $(bc -q <<< scale=2\;$MemTotalB/1024/1024))"
    SwapFreeB="$(cat /proc/meminfo | grep SwapFree | awk {'print $2'})"
    SwapTotalB="$(cat /proc/meminfo | grep SwapTotal | awk {'print $2'})"
    SwapUsedB="$(expr $SwapTotalB - $SwapFreeB)"
    SwapFree="$(printf "%0.2f\n" $(bc -q <<< scale=2\;$SwapFreeB/1024/1024))"
    SwapUsed="$(printf "%0.2f\n" $(bc -q <<< scale=2\;$SwapUsedB/1024/1024))"
    SwapTotal="$(printf "%0.2f\n" $(bc -q <<< scale=2\;$SwapTotalB/1024/1024))"
    RootFreeB="$(df -k / | tail -1 | awk '{print $3}')"
    RootUsedB="$(df -k / | tail -1 | awk '{print $2}')"
    RootTotalB="$(expr $RootFreeB + $RootUsedB)"
    RootFree="$(printf "%0.2f\n" $(bc -q <<< scale=2\;$RootFreeB/1024/1024))"
    RootUsed="$(printf "%0.2f\n" $(bc -q <<< scale=2\;$RootUsedB/1024/1024))"
    RootTotal="$(printf "%0.2f\n" $(bc -q <<< scale=2\;$RootTotalB/1024/1024))"
    UpdateCount="$(cat /tmp/updatecount.txt)"
    SessionCount="$(who | grep $USER | wc -l)"
    ProcessCount="$(ps -Afl | wc -l)"
    ProcessMax="$(ulimit -u)"
    PhpVersion="$(/usr/bin/php -v 2>/dev/null | grep -oE '^PHP\s[0-9]+\.[0-9]+\.[0-9]+' | awk '{ print $2}')"
    MaxLeftOverChars=35
    Hostname="$(hostname)"
    HostChars=$((${#Hostname} + 8))
    LeftoverChars=$((MaxLeftOverChars - HostCHars -10))
    if [[ -x "/usr/bin/yum" ]] ; then
        UpdateType="yum "
    elif [[ -x "/usr/bin/zypper" ]] ; then
        UpdateType="zypper "
    elif [[ -x "/usr/bin/apt-get" ]] ; then
        UpdateType="apt-get "
    fi    
}

WriteLog () {
  if [ -z "$1" ] ; then echo "WriteLog: Log parameter #1 is zero length. Please debug..." ; exit 1
  else
    if [ -z "$2" ] ; then echo "WriteLog: Severity parameter #2 is zero length. Please debug..." ; exit 1
    else
      if [ -z "$3" ] ; then echo "WriteLog: Message parameter #3 is zero length. Please debug..." ; exit 1 ; fi
    fi
  fi
  Now=$(date '+%Y-%m-%d %H:%M:%S,%3N')
  if [ $1 = "Verbose" -a $Verbose = 1 ] ; then echo "$Now: $2: $3"
  elif [ $1 = "Verbose" -a $Verbose = 0 ] ; then :
  elif [ $1 = "Output" ] ; then echo "${Now}: $2: $3"
  elif [ -f $1 ] ; then echo "${Now}: $2: $3" >> $1
  fi
}

StartBlueTheme () {
    # Blue
    Sch1="\e[0;34m####"
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
}

StartRedTheme () {
    # Red
    Sch1="\e[0;31m####"
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
}

StartOriginalBlue () {
    WriteLog Verbose Info "StartOriginalBlue function started."
    for i in {18..21} {21..18} ; do ShortBlueScheme+="\e[38;5;${i}m#\e[0m"  ; done ;
    for i in {17..21} {21..17} ; do BlueScheme+="\e[38;5;${i}m#\e[0m\e[38;5;${i}m#\e[0m"  ; done ;
    for i in {17..21} {21..17} ; do LongBlueScheme+="\e[38;5;${i}m#\e[0m\e[38;5;${i}m#\e[0m\e[38;5;${i}m#"  ; done ;
}

GenerateOriginal256Color () {
        echo -e "$BlueScheme$LongBlueScheme$BlueScheme$ShortBlueScheme
$BlueScheme \e[38;5;93m $Hostname $BlueScheme \e[38;5;98m$ScriptVersion
$BlueScheme$LongBlueScheme$BlueScheme$ShortBlueScheme
\e[0;38;5;17m##          \e[38;5;39mIp \e[38;5;93m= \e[38;5;33m$IpAddress
\e[0;38;5;17m##     \e[38;5;39mRelease \e[38;5;93m= \e[38;5;27m$OsVersion
\e[0;38;5;17m##      \e[38;5;39mKernel \e[38;5;93m= \e[38;5;27m$Kernel
\e[0;38;5;17m##    \e[38;5;39mPlatform \e[38;5;93m= \e[38;5;27m$Platform
\e[0;38;5;17m##      \e[38;5;39mUptime \e[38;5;93m= \e[38;5;27m$Uptime
\e[0;38;5;17m##    \e[38;5;39mCPU Util \e[38;5;93m= \e[38;5;33m${CpuUtil}\e[38;5;27m% average CPU usage over $CpuProc
\e[0;38;5;17m##    \e[38;5;39mCPU Load \e[38;5;93m= \e[38;5;27m$CpuLoad
\e[0;38;5;17m##      \e[38;5;39mMemory \e[38;5;93m= \e[38;5;27mFree: \e[38;5;33m${MemFree}\e[38;5;27mGB, Used: \e[38;5;33m${MemUsed}\e[38;5;27mGB, Total: \e[38;5;33m${MemTotal}\e[38;5;27mGB
\e[0;38;5;17m##        \e[38;5;39mSwap \e[38;5;93m= \e[38;5;27mFree: \e[38;5;33m${SwapFree}\e[38;5;27mGB, Used: \e[38;5;33m${SwapUsed}\e[38;5;27mGB, Total: \e[38;5;33m${SwapTotal}\e[38;5;27mGB
\e[0;38;5;17m##        \e[38;5;39mRoot \e[38;5;93m= \e[38;5;27mFree: \e[38;5;33m${RootFree}\e[38;5;27mGB, Used: \e[38;5;33m${RootUsed}\e[38;5;27mGB, Total: \e[38;5;33m${RootTotal}\e[38;5;27mGB
\e[0;38;5;17m##     \e[38;5;39mUpdates \e[38;5;93m= \e[38;5;33m$UpdateCount\e[38;5;27m ${UpdateType}updates available
\e[0;38;5;17m##    \e[38;5;39mSessions \e[38;5;93m= \e[38;5;33m$SessionCount\e[38;5;27m sessions
\e[0;38;5;17m##   \e[38;5;39mProcesses \e[38;5;93m= \e[38;5;33m$ProcessCount\e[38;5;27m running processes of \e[38;5;33m$ProcessMax\e[38;5;27m maximum processes"
    if [[ $PhpVersion =~ ^[0-9.]+$ ]] ; then
        echo -e "\e[0;38;5;17m##    \e[38;5;39mPHP Info \e[38;5;93m= \e[38;5;27mVersion: \e[38;5;33m$PhpVersion"
    fi
    echo -e "$BlueScheme$LongBlueScheme$BlueScheme$ShortBlueScheme\e[0;37m"
}

GenerateBasic16Color () {
    echo -e "$PrHS$Sch2$HST$Sch2$PHS$Sch1
$PrHS$Sch3$HSF $HC$Hostname $HSF$Sch3$HSF$HVF$SVC$ScriptVersion$Sch1
$PrHS$Sch2$HST$Sch2$PHS$Sch1
$FrS          ${KS}Ip $ES ${VCL}$IpAddress
$FrS     ${KS}Release $ES ${VC}$OsVersion
$FrS      ${KS}Kernel $ES ${VC}$Kernel
$FrS    ${KS}Platform $ES ${VC}$Platform
$FrS      ${KS}Uptime $ES ${VC}$Uptime
$FrS    ${KS}CPU Util $ES ${VCL}$CpuUtil ${VC}% average CPU usage over $CpuProc
$FrS    ${KS}CPU Load $ES ${VC}$CpuLoad
$FrS      ${KS}Memory $ES ${VC}Free: ${VCL}${MemFree}${VC} GB, Used: ${VCL}${MemUsed}${VC} GB, Total: ${VCL}${MemTotal}${VC} GB
$FrS        ${KS}Swap $ES ${VC}Free: ${VCL}${SwapFree}${VC} GB, Used: ${VCL}${SwapUsed}${VC} GB, Total: ${VCL}${SwapTotal}${VC} GB
$FrS        ${KS}Root $ES ${VC}Free: ${VCL}${RootFree}${VC} GB, Used: ${VCL}${RootUsed}${VC} GB, Total: ${VCL}${RootTotal}${VC} GB
$FrS     ${KS}Updates $ES ${VCL}$UpdateCount${VC} ${UpdateType}updates available.
$FrS    ${KS}Sessions $ES ${VCL}$SessionCount ${VC}sessions
$FrS   ${KS}Processes $ES ${VCL}$ProcessCount ${VC}running processes of ${VCL}$ProcessMax ${VC}maximum processes"
    if [[ $PhpVersion =~ ^[0-9.]+$ ]] ; then
        echo -e "$FrS    ${KS}PHP Info $ES ${VC}Version: ${VCL}$PhpVersion"
    fi
    echo -e "$PrHS$Sch2$HSB$Sch2$PHS$Sch1\e[0;37m"
}

while :; do
    case "$1" in
        -h|--help)
            DisplayHelp="true" ; shift ;;
        yum|YUM|Yum|Zypper|zypper|-U|--Updates|-Y)
            CountUpdates ; shift ;;
        -t|--Theme)
            shift; Theme=$1 
            case "$Theme" in
		original|Original) GatherInfo ; StartOriginalBlue ; GenerateOriginal256Color ;;
		modern|Modern) GatherInfo ; GenerateOriginal256Color ;;
		red|Red) GatherInfo ; StartRedTheme ; GenerateBasic16Color ;;
                blue|Blue) GatherInfo ; StartBlueTheme ; GenerateBasic16Color ;;
		blank|Blank|blanco|Blanco|Text|Clean|clean) GatherInfo ; GenerateBasic16Color ;;
		*) echo "you specified a non-existant theme." ; exit 2 ;;
	    esac
            shift ;;
        -*)
            echo "you specified a non-existant option. " ; exit 2 ;;
        *)
            break ;;
    esac
done

exit 0
