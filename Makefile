# Config name:  Makefile
# Version:      v2.01.180721
# Created on:   24/06/2016
# Author:       Willem D'Haese
# Contributors: Thomas Dietrich, Dmitry Romanenko
# Purpose:      Makefile for FireMotD installation
# On GitHub:    https://github.com/OutsideIT/FireMotD
# On OutsideIT: https://outsideit.net/FireMotD
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

IDIR=/usr/local/bin
IFILE=$(IDIR)/FireMotD
DDIR=/usr/share/firemotd

BCIDIR=bash_completion.d
BCIFILE=$(BCIDIR)/FireMotD

BCODIR=/etc/bash_completion.d
BCOFILE=$(BCODIR)/FireMotD

CRONSOURCE=cron.d/FireMotD
CRONDIR=/etc/cron.d
CRONFILE=$(CRONDIR)/FireMotD

all: install bash_completion cron

install:
	cp FireMotD $(IFILE)
	chmod 755 $(IFILE)
	mkdir -p $(DDIR)/{data,templates,themes}
	cp templates/* $(DDIR)/templates
	cp themes/* $(DDIR)/themes
	$(IDIR)/FireMotD -S

bash_completion:
	cp $(BCIFILE) $(BCOFILE)

cron:
	cp $(CRONSOURCE) $(CRONFILE)

uninstall:
	rm -f $(IFILE)
	rm -f $(BCOFILE)
	rm -f $(CRONFILE)
        rm -rf $(DDIR)
