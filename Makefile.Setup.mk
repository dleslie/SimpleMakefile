# -*- makefile -*-

#SUBDIRS=
#export EXTRA_LIBS=
#export EXTRA_CC=
#export VC_VERSION="$(shell git rev-parse HEAD)"

# Output directory; CURDIR is a make constant
export BUILDDIR=$(CURDIR)/build
export DATADIR=$(CURDIR)/data
export OUTDIR=$(CURDIR)/dist
export OUTDATADIR=$(OUTDIR)/data
export BINDIR=$(OUTDIR)
export TAGS=$(CURDIR)/TAGS
export BREADCRUMBS=
export BUILDROOT=$(CURDIR)

EXTRA_COMMON=-DVERSION=\"$(VC_VERSION)\"
EXTRA_CC+=$(EXTRA_COMMON)
EXTRA_CPP+=$(EXTRA_COMMON)

export BUILD_CPP=$(CPP) $(EXTRA_CPP) -c
export BUILD_C=$(CC) $(EXTRA_CC) -c

export LINK_STATIC=ar -rs
export LINK_BIN=$(CPP)

export RELEASE_CPP=$(BUILD_CPP) -O3
export RELEASE_C=$(BUILD_C) -O3
export RELEASE_BIN=$(LINK_BIN)

export DEBUG_CPP=$(BUILD_CPP) -DDEBUG -g
export DEBUG_C=$(BUILD_C) -DDEBUG -g
export DEBUG_BIN=$(LINK_BIN) -rdynamic

export COPY=cp -u
export REMOVE=rm -f
export MAKE=make --no-print-directory
export ECHO=echo
export MKDIR=mkdir -p
export BASEDIR=$(CURDIR)
export ETAGS=etags -a -o $(TAGS) 
export FIND=find
export LN=ln -f -s 
export CD=cd 

#export CPPCHECK=cppcheck --quiet --inconclusive --enable=all 
export CPPCHECK=cppcheck --quiet --enable=all 

all:
	@$(ECHO) "You probably want one of debug, release, clean, clean_dist, deploy or stats"

debug: clean_tags
	@$(eval export BUILDDIR=$(BUILDDIR)/debug)
	@$(eval export BUILD_CPP=$(DEBUG_CPP))
	@$(eval export BUILD_C=$(DEBUG_C))
	@$(eval export LINK_BIN=$(DEBUG_BIN))
	@$(FIND) ./ -iname .cache -exec $(RM) -rf {} \;
	@$(MKDIR) $(INCLUDEDIR) $(BINDIR) $(LIBDIR)
	@$(foreach d, $(SUBDIRS), $(MAKE) -C $(d) &&) true;

release: clean check
	@$(eval export BUILDDIR=$(BUILDDIR)/release)
	@$(eval export LINK_BIN=$(RELEASE_BIN))
	@$(eval export BUILD_CPP=$(RELEASE_CPP))
	@$(eval export BUILD_C=$(RELEASE_C))
	@$(FIND) ./ -iname .cache -exec $(RM) -rf {} \;
	@$(MKDIR) $(INCLUDEDIR) $(BINDIR) $(LIBDIR)
	@$(foreach d, $(SUBDIRS), $(MAKE) -C $(d) &&) true;

check:
	@$(ECHO) CppCheck Started
	@$(CPPCHECK) $(SUBDIRS)
	@$(ECHO) CppCheck Completed

clean: clean_tags clean_dist
	@$(FIND) ./ -iname .cache -exec $(RM) -rf {} \;
	@$(ECHO) "[RM]  $(BUILDDIR)/debug";
	@$(REMOVE) -rf "$(BUILDDIR)/debug";
	@$(ECHO) "[RM]  $(BUILDDIR)/release";
	@$(REMOVE) -rf "$(BUILDDIR)/release";

clean_tags:
	@$(ECHO) "[RM]  $(TAGS)";
	@$(REMOVE) -r $(TAGS);

deploy: clean_dist
	@$(foreach d, $(SUBDIRS), $(MAKE) -C $(d) deploy &&) $(ECHO) Done;

stats:
	@$(FIND) ./ -name \*.c -or -name \*.cpp -or -name \*.h -or -name \*.hpp -or -name \*.scm -or -name Makefile\* | xargs wc -l -L -c
	@$(ECHO) "Listing: Lines, Bytes, Longest Line in File, Filename"

clean_dist:
	@$(ECHO) "[RM]  $(OUTDIR)";
	@$(REMOVE) -r $(OUTDIR)/*;
