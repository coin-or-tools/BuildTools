# Copyright (C) 2006 International Business Machines and others.
# All Rights Reserved.
# This file is distributed under the Common Public License.

## $Id: Makmaint.inc 5920 2006-05-02 05:51:22Z andreasw $

# Author:  Andreas Waechter           IBM    2006-04-13

########################################################################
#                         Maintainer Stuff                             #
########################################################################

if MAINTAINER_MODE

BUILDTOOLSDIR=$(srcdir)/BuildTools

# Make sure acinclude is using most recent coin.m4
$(srcdir)/acinclude.m4: $(BUILDTOOLSDIR)/coin.m4
	cat $(LIBTOOLM4) $< > $@

# Make sure the autotools scripts are up to date
$(srcdir)/install-sh: $(BUILDTOOLSDIR)/install-sh
	cp $< $@

$(srcdir)/missing: $(BUILDTOOLSDIR)/missing
	cp $< $@

$(srcdir)/config.guess: $(BUILDTOOLSDIR)/config.guess
	cp $< $@

$(srcdir)/config.sub: $(BUILDTOOLSDIR)/config.sub
	cp $< $@

$(srcdir)/depcomp: $(BUILDTOOLSDIR)/depcomp
	cp $< $@

$(srcdir)/ltmain.sh: $(BUILDTOOLSDIR)/ltmain.sh
	cp $< $@
endif
