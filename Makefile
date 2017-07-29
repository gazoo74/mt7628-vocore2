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

TEXT_BASE = 0x00000000

ARCH := mips
CROSS_COMPILE := mipsel-unknown-linux-gnu-
CC := $(CROSS_COMPILE)$(CC)
OBJCOPY = $(CROSS_COMPILE)objcopy
CPPFLAGS += -D__KERNEL__ -DCONFIG_HAS_DEBUG_LL -DCONFIG_DEBUG_LL
CFLAGS += -std=c99 -Werror -Wextra -g
CFLAGS += -nostdinc
CFLAGS += -Iinclude
CFLAGS += -fno-builtin
CLFAGS += -mabi=32 -march=mips32r2 -Wa,-mips32r2 -Wa,--trap
LDFLAGS += -Ttext $(TEXT_BASE)
LDFLAGS += -nostdlib

MKIMAGE = mkimage
MKFLAGS += -A $(ARCH) -O u-boot -T standalone -C none -a $(TEXT_BASE) -e $(TEXT_BASE) -n "Standelone Image" 

.SECONDARY:
.PHONY: all
all: helloworld.img

helloworld: puts.o

.PHONY: help
help:
	@echo "U-Boot:"
	@echo "tftp \$${loadaddr} helloworld.img; bootm \$${loadaddr}"
	@echo ""
	@echo "Host:"
	@echo "ip addr add 192.168.1.3/24 dev enp0s25"
	@echo "picocom -b 115200 /dev/ttyACM0"

deploy-tftp undeploy-tftp:

.PHONY: clean
clean:
	rm -f *.o *.elf *.bin *.img

%.i: %.c
	$(PREPROCESS.S) $< > $@

%.elf: %
	ln -sf $< $@

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

%.img: %.bin
	$(MKIMAGE) $(MKFLAGS) -d $< $@

deploy-%:
	install -m 755 helloworld.img /srv/$*/

undeploy-%:
	rm -f /srv/$*/helloworld.img

