TARGET = m68hc11-elf
PREFIX = $(CURDIR)/dist
PROGPREFIX = $(TARGET)-


all: newlib

clean:
	rm -rf build/


## binutils

binutils: $(PREFIX)/bin/$(PROGPREFIX)ld

downloads/binutils-2.23.2.tar.gz:
	mkdir -p downloads
	wget -O $@ http://ftp.gnu.org/gnu/binutils/binutils-2.23.2.tar.gz

src/binutils-2.23.2/configure: downloads/binutils-2.23.2.tar.gz
	rm -rf src/binutils-2.23.2 && mkdir -p src
	tar -C src -xf downloads/binutils-2.23.2.tar.gz
	sed -i -e 's/@colophon/@@colophon/' -e 's/doc@cygnus.com/doc@@cygnus.com/' src/binutils-2.23.2/bfd/doc/bfd.texinfo
	touch -c $@

$(PREFIX)/bin/$(PROGPREFIX)ld: src/binutils-2.23.2/configure
	rm -rf build/binutils && mkdir -p build/binutils
	cd build/binutils && ../../src/binutils-2.23.2/configure --target=$(TARGET) --prefix=$(PREFIX) --program-prefix=$(PROGPREFIX) --disable-werror
	make -C build/binutils
	make -C build/binutils install


## GCC

gcc: $(PREFIX)/bin/$(PROGPREFIX)gcc

downloads/gcc-3.3.6.tar.gz:
	mkdir -p downloads
	wget -O $@ https://ftp.gnu.org/gnu/gcc/gcc-3.3.6/gcc-3.3.6.tar.gz

src/gcc-3.3.6/configure: downloads/gcc-3.3.6.tar.gz patches/gcc-3.3.6-s12x.patch
	rm -rf src/gcc-3.3.6 && mkdir -p src
	tar -C src -xf downloads/gcc-3.3.6.tar.gz
	patch -d src/gcc-3.3.6 -p1 <patches/gcc-3.3.6-s12x.patch
	touch -c $@

$(PREFIX)/bin/$(PROGPREFIX)gcc: $(PREFIX)/bin/$(PROGPREFIX)ld src/gcc-3.3.6/configure
	rm -rf build/gcc && mkdir -p build/gcc
	cd build/gcc && ../../src/gcc-3.3.6/configure --target=$(TARGET) --prefix=$(PREFIX) --program-prefix=$(PROGPREFIX) --enable-languages=c --disable-werror
	make -C build/gcc CFLAGS="-D_FORTIFY_SOURCE=0"
	make -C build/gcc install


## newlib

newlib: $(PREFIX)/$(TARGET)/include/stdlib.h

downloads/newlib-1.16.0.tar.gz:
	mkdir -p downloads
	wget -O $@ ftp://sourceware.org/pub/newlib/newlib-1.16.0.tar.gz

src/newlib-1.16.0/configure: downloads/newlib-1.16.0.tar.gz patches/newlib-1.16.0-s12x.patch
	rm -rf src/newlib-1.16.0 && mkdir -p src
	tar -C src -xf downloads/newlib-1.16.0.tar.gz
	patch -d src/newlib-1.16.0 -p1 <patches/newlib-1.16.0-s12x.patch
	touch -c $@

$(PREFIX)/$(TARGET)/include/stdlib.h: $(PREFIX)/bin/$(PROGPREFIX)gcc src/newlib-1.16.0/configure
	rm -rf build/newlib && mkdir -p build/newlib
	cd build/newlib && ../../src/newlib-1.16.0/configure --target=$(TARGET) --prefix=$(PREFIX) --program-prefix=$(PROGPREFIX) --disable-werror
	make -C build/newlib
	make -C build/newlib install
