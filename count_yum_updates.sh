#!/bin/sh

# Script name:			count_yum_updates.sh
# Version:				v2.03.7.21
# Created on:			15/11/2014
# Author:				Willem D'Haese
# Purpose:				Bash script that will dynamically generate a message of they day for users logging in.
# On GitHub:			https://github.com/willemdh/generate_motd
# On OutsideIT:			http://outsideit.net/generate-motd
# Recent History:
#		18/11/2014 => if statement in case 0 updates available (else -1)
#		30/03/2015 => Cleanup, better compatibility with CentOS 7
#		13/04/2015 => Prep for GitHub release
#		15/04/2015 => 16 color version
#		21/07/2015 => Introduction of red and blue theme
# Copyright:
#		This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published
#		by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed 
#		in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
#		PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public 
#		License along with this program.  If not, see <http://www.gnu.org/licenses/>.

YumCount=`/usr/bin/yum -d 0 check-update 2>/dev/null | echo $(($(wc -l)-1))`
if [ $YumCount == -1 ]; then
        YumCount=0
fi
echo "$YumCount"
exit 0


