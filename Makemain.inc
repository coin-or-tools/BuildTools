# Copyright (C) 2006, 2007 International Business Machines and others.
# All Rights Reserved.
# This file is distributed under the Eclipse Public License.

## $Id$

# Author:  Andreas Waechter           IBM    2006-04-13


########################################################################
#        Variables for documentation and data directories              #
########################################################################

# COIN overrides the default definitions of datadir and docdir.

datadir = @datarootdir@/coin/data
docdir  = @datarootdir@/coin/doc
pkgdatadir = $(datadir)/$(PACKAGE_NAME)
pkgdocdir = $(docdir)/$(PACKAGE_NAME)
doxydocdir = $(pkgdocdir)/doxydoc
doxyhtmldir = $(doxydocdir)

########################################################################
#                    Documentation installation                        #
########################################################################

DocFiles =  README AUTHORS LICENSE

COIN_HAS_DOXYGEN = @COIN_HAS_DOXYGEN_TRUE@TRUE
COIN_HAS_LATEX = @COIN_HAS_LATEX_TRUE@TRUE

# Needless to say, it's important that doxydocdir_nosub not be a target for
# autoconf substitution.

DOXYTAG_EDIT = sed -e 's|@docdir_nosub@|$(docdir)|g'

doxygen-docs: 
	if test "$(COIN_HAS_DOXYGEN)" = TRUE; then \
	  if test -d "doxydoc/"; then \
	    if test -f doxydoc/doxygen.conf ; then \
	      $(DOXYTAG_EDIT) \
	        doxydoc/doxygen.conf > doxydoc/doxygen.conf.tmp ; \
	      mv doxydoc/doxygen.conf.tmp doxydoc/doxygen.conf ; \
	    fi ; \
	    doxygen doxydoc/doxygen.conf;\
	  fi;\
	fi

pdf-doxygen-docs: doxygen-docs
	if test "$(COIN_HAS_DOXYGEN)" = TRUE; then \
	  if test -d "doxydoc/latex"; then \
       	    if test "$(COIN_HAS_LATEX)" = TRUE; then \
	      cd doxydoc/latex;\
	      $(MAKE) pdf;\
	      cd -;\
	    fi;\
	  fi;\
	fi

clean-doxygen-docs:
	if test -d "doxydoc"; then \
	  cd doxydoc ;\
	  rm -rf html latex *.log *.tag;\
	fi

install-doxygen-docs: doxygen-docs
	if test "$(COIN_HAS_DOXYGEN)" = TRUE; then \
	  if test -d "doxydoc"; then \
	    test -d "$(DESTDIR)$(doxydocdir)" || \
	         $(mkdir_p) "$(DESTDIR)$(doxydocdir)"; \
	    $(INSTALL_DATA) doxydoc/@coin_doxy_tagname@ \
	        "$(DESTDIR)$(doxydocdir)"; \
	    if test -f "doxydoc/latex/refman.pdf"; then \
	      $(INSTALL_DATA) doxydoc/latex/refman.pdf \
	          "$(DESTDIR)$(doxydocdir)";\
	    fi;\
	    if test -d "doxydoc/html"; then \
	      test -d "$(DESTDIR)$(doxyhtmldir)/search/" || \
	           $(mkdir_p) "$(DESTDIR)$(doxyhtmldir)/search/"; \
	      $(INSTALL_DATA) doxydoc/html/*.* \
	          "$(DESTDIR)$(doxyhtmldir)";\
	      $(INSTALL_DATA) doxydoc/html/search/*.* \
	          "$(DESTDIR)$(doxyhtmldir)/search";\
            fi;\
          fi;\
        fi

# It's not clear that uninstall-doc should also remove doxygen doc'n. Write
# the rules so that the last one will remove pkgdocdir (which should be empty
# by then).

uninstall-doxygen-docs:
	if test -d "$(DESTDIR)$(doxydocdir)"; then \
	  rm -rf "$(DESTDIR)$(doxydocdir)"; \
	fi
	rmdir $(DESTDIR)$(pkgdocdir) || true

install-doc: $(DocFiles)
	$(mkdir_p) "$(DESTDIR)$(pkgdocdir)"
	for file in $(DocFiles); do \
	  if test -f "$$file"; then dir=; else dir="$(srcdir)/"; fi; \
	  if test -f "$$dir$$file"; then \
	    $(INSTALL_DATA) "$$dir$$file" \
	        "$(DESTDIR)$(pkgdocdir)/$$file"; \
	  fi; \
	done

uninstall-doc:
	for file in $(DocFiles); do \
	  rm -f "$(DESTDIR)$(pkgdocdir)/$$file"; \
	done
	rmdir $(DESTDIR)$(pkgdocdir) || true

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

endif

.PHONY: install-doc uninstall-doc \
	doxygen-docs pdf-doxygen-docs clean-doxygen-docs \
	install-doxygen-docs uninstall-doxygen-docs
