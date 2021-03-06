# APPLE LOCAL file build machinery
# Apple GCC Compiler Makefile for use by buildit.  
#
# This makefile is intended only for use with B&I buildit. For "normal"
# builds use the conventional FSF top-level makefile.
#
# Usage:
#
#  1. Set BUILDIT_DIR to where you want the build to go.  Buildit uses
#     this to set up DSTROOT, OBJROOT, etc.
#
#     examples: 
#       export BUILDIT_DIR=/tmp/build_goes_here   [sh or bash]
#       setenv BUILDIT_DIR /tmp/build_goes_here   [csh or tcsh]
#
#  2. Run buildit.  Here's a brief general description generated by
#     running buildit --help (reformatted to fit in here):
#
#     Usage: buildit projectSourceDirectory [build options] \
#                    [-- other arguments]
#
#     Mandatory argument:
#       projectSourceDirectory      The root directory of project source
#                                   tree (can be absolute or relative
#                                   path to the project source tree)
#
#     Build options:
#       -release                    Use RC_CFLAGS (compiler flags) from
#                                   specified release (use release name
#                                   like Cheetah, Puma, Jaguar, ...)
#       -arch <archName>            Build with specified architectures(s)
#                                   (-arch can be multiply specified:
#                                    -arch ppc -arch i386)
#                                   (default is native architecture)
#       -noclean                    Disables deletion of {OBJ,SYM,DST}ROOT
#                                   before start of build
#       -noinstall                  Disables invocation of 'install' target
#       -noinstallhdrs              Disables invocation of 'installhdrs' target
#       -noinstallsrc               Disables invocation of 'installsrc' target
#       -noverify                   Disables verification of project DSTROOT
#                                   after build
#       -nosum                      Disables before-and-after checksumming
#                                   of project source
#       -noprebind                  Disables prebinding
#       -noperms                    Disables permissions setting on DSTROOT
#                                   after build
#       -merge <mergeDir>           Merges resulting DSTROOT into "mergeDir"
#       -target <buildTarget>       Specifies an alternate Make or Jam build
#                                   target (instead of "install")
#       -othercflags <cflags>       Specified cflags are appended to RC_CFLAGS
#                                   for build
#
#     Other arguments:
#       Other arguments can be passed to the makefile by putting them
#       at the end of the buildit argument list following a double dash ("--").
#      Arguments that contain whitespace should be enclosed in quotes.
#
#     examples: (assume $gcc3 is shell variable with gcc3 dir in it)
#
#       Creating a new root:
#         mkdir /tmp/my-build
#         cd /tmp/my-build
#         export BUILDIT_DIR=`pwd`
#         ~rc/bin/buildit -noverify -nosum -noinstallsrc -noinstallhdrs \
#                         -arch ppc -arch i386 $gcc3 BOOTSTRAP=
#
#       Rebuilding the previous root (assumes BUILDIT_DIR unchanged):
#         ~rc/bin/buildit -noverify -nosum -noinstallsrc -noinstallhdrs \
#                         -noclean -arch ppc -arch i386 $gcc3
#
# You can specify BOOTSTRAP= to stop the normal bootstapping of the
# compiler during it's build.
#
# You can specify TARGETS=ppc (or i386) to limit the build to just one
# target.  The default is for ppc and i386. 
#
#######################################################################
#
# ** AUTOMATIC BUILDS **
#
# Automatic builds strictly follow the B&I makefile API standards.
#

# Include the set of standard Apple makefile definitions.
ifndef CoreOSMakefiles
CoreOSMakefiles = $(MAKEFILEPATH)/CoreOS
endif
include $(CoreOSMakefiles)/Standard/Standard.make

# Enable Apple extensions to (gnu)make.
USE_APPLE_PB_SUPPORT = all

HOSTS = ppc i386 # `arch`
targets = echo $${TARGETS:-'ppc i386'}
TARGETS := $(shell $(targets))

RC_ARCHS = $(HOSTS)

SRCROOT = .

SRC = `cd $(SRCROOT) && pwd | sed s,/private,,`
OBJROOT = $(SRC)/obj
SYMROOT = $(OBJROOT)/../sym
DSTROOT = $(OBJROOT)/../dst

# Set BOOTSTRAP to null (either here on on the buildit cmd line) to
# disable a bootstrap build.

BOOTSTRAP = --bootstrap

# Set ENABLE_CHECKING to null (either here or on the buildit cmd line)
# to disable generating a compiler the has tree and rtl access checking
# code in it.

#ifneq ($(RC_RELEASE),)
#    ENABLE_CHECKING = --disable-checking
#else
#    ENABLE_CHECKING = --enable-checking
#endif
ENABLE_CHECKING=
ifeq ($(ENABLE_CHECKING),)
    ENABLE_CHECKING1 = --disable-checking
else
    ifeq ($(ENABLE_CHECKING),--disable-checking)
	ENABLE_CHECKING1 = --disable-checking
    else
	ENABLE_CHECKING1 = --enable-checking
    endif
endif

VERSION =`fgrep version_string < $(SRCROOT)/gcc/version.c | \
                 sed -e 's/.*\"\([^ \"]*\)[ \"].*/\1/'`

ARCH = `arch`

PREFIX = /usr

std_include_dir = $(DSTROOT)/usr/include
gcc_hdr_dir     = $(std_include_dir)/gcc/darwin/$(VERSION)
gcc_man1_dir = $(DSTROOT)/usr/share/man/man1

# Order of buildit events.
# 1. installsrc
# 2. clean
# 3. installhdrs: installs $DSTROOT.hdrDst/ $DSTROOT.hdrObj/ $DSTROOT.hdrSym/
# 4. install: $DSTROOT.dst/ $DSTROOT.obj/ $DSTROOT.sym/

# DO_SYMLINKS set to 'yes' will all the full gcc3 installation which
# includes generating sym links in various places.  These sym links
# are in the same places with the same names as those generated by
# gcc2.  We may not want to clobber gcc2's sym links.  Thus setting
# DO_SYMLINKS to 'no' will suppress them.

DO_SYMLINKS = no

# DO_HDR_SYMLINKS is similar to DO_SYMLINKS but only controls the
# generation of the sym links for the headers in /usr/include.

DO_HDR_SYMLINKS = no

# OPTIMIZE controls the optimization level we build the compiler
# with.  The default is "yes", which is synomous with -O2.  

OPTIMIZE = 

#######################################################################

install: installhdrs build install_no_src
	@echo
	@echo ++++++++++++++
	@echo + Installing +
	@echo ++++++++++++++
	@echo
	if [ "$(DO_SYMLINKS)" = yes ]; then \
	  cd $(DSTROOT)/usr/libexec/gcc/darwin && \
	  for dir in *; do \
	    cd $(DSTROOT)/usr/libexec/gcc/darwin/$$dir && \
	    rm -f default && \
	    ln -s $(VERSION) default; \
	  done && \
	  cd $(DSTROOT)/usr/lib/gcc/darwin && \
	  rm -f default && \
	  ln -s $(VERSION) default; \
	fi

installhdrs: DSTROOT
	@echo
	@echo ++++++++++++++++++++++
	@echo + Installing headers +
	@echo ++++++++++++++++++++++
	@echo
	@echo +++ gccfast installs no headers +++
	@echo

# Note for future reference: Relative symlinks like the one above are
# always relative to the sym link.  So in the above ln -s
# $(std_include_dir)/machine is "in" the machine dir.  So we need to
# go "up" to $(std_include_dir) and then down to the actual
# machine/limits.

build: OBJROOT SYMROOT
	@echo
	@echo +++++++++
	@echo + build +
	@echo +++++++++
	@echo
	APPLE_CC=`if echo $(SRCROOT) | grep '[0-9]$$' >/dev/null; then \
		    vers_string -f cc 2>/dev/null | sed -e 's/[-A-Za-z_]*//' \
			| sed -e 's/\.[0-9.]*//'; \
		  else date +%Y%m%d%H%M%S; \
		  fi`; \
	export APPLE_CC; \
	export BISON=/usr/local/bin/bison-1.28; \
	./build_gcc --thins \
		--srcroot=$(SRC) \
		--dstroot=$(DSTROOT) \
		--objroot=$(OBJROOT) \
		--symroot=$(SYMROOT) \
		--cflags="$(RC_CFLAGS) $(OTHER_CFLAGS) -g" \
		--hosts="$(RC_ARCHS)" \
		--targets="$(TARGETS)" \
		--prefix="$(PREFIX)" \
		--symlinks=$(DO_SYMLINKS) \
		--optimize="$(OPTIMIZE)" \
		$(ENABLE_CHECKING1) \
		$(BOOTSTRAP)

install_no_src:
	@echo
	@echo ++++++++++++++++++
	@echo + install_no_src +
	@echo ++++++++++++++++++
	@echo
	APPLE_CC=`if echo $(SRCROOT) | grep '[0-9]$$' >/dev/null; then \
		    vers_string -f cc 2>/dev/null | sed -e 's/[-A-Za-z_]*//' \
			| sed -e 's/\.[0-9.]*//'; \
		  else date +%Y%m%d%H%M%S; \
		  fi`; \
	export APPLE_CC; \
	export BISON=/usr/local/bin/bison-1.28; \
	./build_gcc --fats \
	    --srcroot=$(SRC) \
	    --dstroot=$(DSTROOT) \
	    --objroot=$(OBJROOT) \
	    --symroot=$(SYMROOT) \
	    --cflags="$(RC_CFLAGS) $(OTHER_CFLAGS)" \
	    --hosts="$(RC_ARCHS)" \
	    --targets="$(TARGETS)" \
	    --prefix="$(PREFIX)" \
	    --symlinks=$(DO_SYMLINKS)
	rm    -rf $(DSTROOT)/usr/include/gcc/darwin/$(VERSION)
	ln -s 3.3 $(DSTROOT)/usr/include/gcc/darwin/$(VERSION)
	rm    -rf $(DSTROOT)/usr/include/gcc/darwin/3.3
	mkdir -p  $(DSTROOT)/usr/include/gcc/darwin/3.3
	rm    -rf $(DSTROOT)/usr/lib/gcc/darwin/$(VERSION)
	ln -s 3.3 $(DSTROOT)/usr/lib/gcc/darwin/$(VERSION)
	rm    -rf $(DSTROOT)/usr/lib/gcc/darwin/3.3
	mkdir -p  $(DSTROOT)/usr/lib/gcc/darwin/3.3
	if echo $(TARGETS) | fgrep "i386" >/dev/null ; then \
		rm    -rf $(DSTROOT)/usr/libexec/gcc/darwin/i386/$(VERSION) ;\
		ln -s 3.3 $(DSTROOT)/usr/libexec/gcc/darwin/i386/$(VERSION) ;\
		rm    -rf $(DSTROOT)/usr/libexec/gcc/darwin/i386/3.3 ;\
		mkdir -p  $(DSTROOT)/usr/libexec/gcc/darwin/i386/3.3 ;\
		install -s -m a+rx $(DSTROOT)/usr/bin/gcc-$(VERSION) $(DSTROOT)/usr/libexec/gcc/darwin/i386/$(VERSION)/driver ;\
	fi
	install -s -m a+rx $(DSTROOT)/usr/bin/gcc-$(VERSION) $(DSTROOT)/usr/libexec/gcc/darwin/ppc/$(VERSION)/driver
	install    -m a+rx $(SYMROOT)/ppc/usr/bin/gcc-$(VERSION)  $(SYMROOT)/ppc/lib/ppc/driver
	if [ -d $(SYMROOT)/i386/usr/bin/gcc-$(VERSION) ] ; then \
		install    -m a+rx $(SYMROOT)/i386/usr/bin/gcc-$(VERSION) $(SYMROOT)/i386/lib/i386/driver ; \
	fi
	rm -rf $(DSTROOT)/Developer
	rm -rf $(DSTROOT)/usr/bin
	rm -rf $(DSTROOT)/usr/libexec/gcc/darwin/i386/3.3/cc1*
	rm -rf $(DSTROOT)/usr/libexec/gcc/darwin/i386/3.3/cpp
	rm -rf $(DSTROOT)/usr/libexec/gcc/darwin/i386/3.3/gcov
	rm -rf $(DSTROOT)/usr/libexec/gcc/darwin/i386/3.3/specs

# 3.3-fast hackery (above)


installsrc: SRCROOT
	@echo
	@echo ++++++++++++++++++++++
	@echo + Installing sources +
	@echo ++++++++++++++++++++++
	@echo
	if [ $(SRCROOT) != . ]; then \
	  $(PAX) -rw . $(SRCROOT); \
	fi
	find -d "$(SRCROOT)" \( -type d -a -name CVS -o \
	                        -type f -a -name .DS_Store \) \
	  -exec rm -rf {} \;

#######################################################################

clean:
	@echo
	@echo ++++++++++++
	@echo + Cleaning +
	@echo ++++++++++++
	@echo
	@if [ -d $(OBJROOT) -a "$(OBJROOT)" != / ]; then \
	  echo '*** DELETING ' $(OBJROOT); \
	  rm -rf $(OBJROOT); \
	fi
	@if [ -d $(SYMROOT) -a "$(SYMROOT)" != / ]; then \
	  echo '*** DELETING ' $(SYMROOT); \
	  rm -rf $(SYMROOT); \
	fi
	@if [ -d $(DSTROOT) -a "$(DSTROOT)" != / ]; then \
	  echo '*** DELETING ' $(DSTROOT); \
	  rm -rf $(DSTROOT); \
	fi

#######################################################################

OBJROOT SYMROOT DSTROOT KEYMGR_OBJ:
	mkdir -p $($@)

#######################################################################

SRCROOT:
	@if [ -n "$($@)" ]; \
	then \
		exit 0; \
	else \
		echo Must define $@; \
		exit 1; \
	fi
