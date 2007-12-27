# Copyright (C) 2006 International Business Machines and others.
# All Rights Reserved.
# This file is distributed under the Common Public License.

## $Id: Makmaint.inc 5920 2006-05-02 05:51:22Z andreasw $

# Author:  Andreas Waechter           IBM    2006-04-13

########################################################################
#                    Documentation installation                        #
########################################################################

DocFiles =  README AUTHORS LICENSE
DocInstallDir = $(prefix)/share/doc/$(PACKAGE)

install-exec-am:
	test -z "$(DocInstallDir)" || $(mkdir_p) "$(DESTDIR)$(DocInstallDir)"
	for file in $(DocFiles); do \
	  if test -f "$$file"; then dir=; else dir="$(srcdir)/"; fi; \
	  if test -f "$$dir$$file"; then $(INSTALL_DATA) "$$dir$$file" "$(DESTDIR)$(DocInstallDir)/$$file"; fi; \
	done

uninstall-am:
	for file in $(DocFiles); do \
	  rm -f "$(DESTDIR)$(DocInstallDir)/$$file"; \
	done

########################################################################
#                         Maintainer Stuff                             #
########################################################################

if MAINTAINER_MODE

# Make sure acinclude is using most recent coin.m4
$(srcdir)/acinclude.m4: $(BUILDTOOLSDIR)/coin.m4
	cat $(LIBTOOLM4) $< > $@

# Make sure the autotools scripts are up to date
$(AUX_DIR)/install-sh: $(BUILDTOOLSDIR)/install-sh
	cp $< $@

$(AUX_DIR)/missing: $(BUILDTOOLSDIR)/missing
	cp $< $@

$(AUX_DIR)/config.guess: $(BUILDTOOLSDIR)/config.guess
	cp $< $@

$(AUX_DIR)/config.sub: $(BUILDTOOLSDIR)/config.sub
	cp $< $@

$(AUX_DIR)/depcomp: $(BUILDTOOLSDIR)/depcomp
	cp $< $@

$(AUX_DIR)/ltmain.sh: $(BUILDTOOLSDIR)/ltmain.sh
	cp $< $@

# Take care of updating externals (if Externals file exists)
if HAVE_EXTERNALS
$(top_builddir)/Makefile: .Externals-stamp

.Externals-stamp: $(srcdir)/Externals
	cd $(srcdir); svn propset svn:externals -F Externals .
	touch .Externals-stamp

update-externals: .Externals-stamp
	cd $(srcdir); svn update

endif

endif

if HAVE_EXTERNALS
EXTRA_DIST += Externals
DISTCLEANFILES += .Externals-stamp
endif

DISTCLEANFILES += $(VPATH_DISTCLEANFILES)
