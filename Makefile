# Installs to /usr/local/sbin
# Change variables to adjust locations
#
# Jun 24 2016 - Gustavo Neves

IDIR=/usr/local/bin
IFILE=$(IDIR)/FireMotD

BCIDIR=bash_completion.d
BCIFILE=$(BCIDIR)/FireMotD

BCODIR=/etc/bash_completion.d
BCOFILE=$(BCODIR)/FireMotD

all:

install:
	cp FireMotD $(IFILE)
	chmod 755 $(IFILE)

bash_completion:
	cp $(BCIFILE) $(BCOFILE)

uninstall:
	rm -f $(IFILE)
	rm -f $(BCOFILE)
