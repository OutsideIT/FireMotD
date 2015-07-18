#!/bin/bash

# Script name:          colortest.sh
# Version:              v0.7.18
# Created on:           18/07/2015
# Author:               Willem D'Haese
# Purpose:              Bash script that will dynamically generate a message of they day for users logging in.
# On GitHub:            https://github.com/willemdh/generate_motd
# On OutsideIT:         http://outsideit.net/generate-motd
# Recent History:
#	18/07/2018 => Script creation
# Copyright:
#       This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published
#       by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed
#       in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
#       PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public
#       License along with this program.  If not, see <http://www.gnu.org/licenses/>.

for x in 0 1 4 5 7 8; do for i in `seq 30 37`; do for a in `seq 40 47`; do echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "; done; echo; done; done; echo "";
