#
# deta
#
# Copyright (c) 2011 David Persson
#
# Distributed under the terms of the MIT License.
# Redistributions of files must retain the above copyright notice.
#

PREFIX ?= /usr/local

install: deta
	mkdir -p $(PREFIX)/bin/
	ln -s $(CURDIR)/deta.sh $(PREFIX)/bin/
	cp -p config/Envfile $(PREFIX)/Envfile

uninstall:
	rm $< $(PREFIX)/bin/deta.sh

.PHONY: install uninstall

