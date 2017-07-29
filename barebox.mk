#!/usr/bin/make -f
#
# The MIT License (MIT)
#
# Copyright (c) 2017 Gaël PORTAY <gael.portay@savoirfairelinux.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in thec Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

.PHONY: all
all: import

include/asm include/linux include/asm-generic:
	mkdir -p $@

.PHONY: import
import: | include/asm include/linux barebox
	rsync -av \
	      barebox/arch/mips/include/asm \
	      barebox/include/linux \
	      barebox/include/asm-generic \
	      include/

barebox: barebox-2017.07.1
	ln -sf $< $@

barebox-2017.07.1: barebox-2017.07.1.tar.bz2
	tar xjf $<

barebox-2017.07.1.tar.bz2: 
	wget http://www.barebox.org/download/barebox-2017.07.1.tar.bz2

.PHONY: clean
clean:
	rm -Rf barebox/ barebox-*/

.PHONY: mrproper
mrproper: clean
	rm -f barebox-*.tar.bz2

