# -*- makefile -*-
#SUBDIRS=core
UNITNAME=$(shell basename $(CURDIR))
OLD_BREADCRUMBS=$(BREADCRUMBS)

INCLUDE_PATHS=$(addprefix -I$(CURDIR)/,$(SUBDIRS))
BUILD_CPP+=$(INCLUDE_PATHS)
BUILD_C+=$(INCLUDE_PATHS)

all: set_crumbs
	@$(foreach d, $(SUBDIRS), \
$(ECHO) [BLD] $(d) \
&& $(MAKE) -C $(d) &&) true;

deploy: set_crumbs
	@$(foreach d, $(SUBDIRS), \
$(ECHO) [DPL] $(d) \
&& $(MAKE) -C $(d) deploy &&) true;

clean: set_crumbs
	@$(foreach d, $(SUBDIRS), \
$(ECHO) [CLN] $(d) \
&& $(MAKE) -C $(d) clean;)

set_crumbs:
	@$(eval export BREADCRUMBS=$(BREADCRUMBS)$(UNITNAME)/)

