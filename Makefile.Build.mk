# -*- makefile -*-
#BINFILE=$(UNITNAME)

# Clear implicit build rules
.SUFFIXES:

####################
# Utility Variables
####################

UNITNAME=$(shell basename $(CURDIR))
TARGETDIR=$(BUILDDIR)/$(BREADCRUMBS)$(UNITNAME)/
SRCDIR=$(CURDIR)

BUILD_C+=-I$(SRCDIR)
BUILD_CPP+=-I$(SRCDIR)

####################
# Output Files
####################

CPPFILES=$(shell $(FIND) ./ -wholename \*.cpp)
CPPOFILES=$(addprefix $(TARGETDIR),$(CPPFILES:.cpp=.cpp.o))

CFILES=$(shell $(FIND) ./ -wholename \*.c)
COFILES=$(addprefix $(TARGETDIR),$(CFILES:.c=.c.o))

ifeq ($(BINFILE),)
LIBFILE=$(BUILDDIR)/lib$(UNITNAME).a
endif

ifneq ($(BINFILE),)
REALBINFILE=$(addprefix $(TARGETDIR),$(BINFILE))
$(shell $(RM) $(REALBINFILE))
else
REALBINFILE=
endif

EXISTINGLIBS=$(shell ls -at $(BUILDDIR)/*.a 2> /dev/null)

LINK_BIN+=-L$(BUILDDIR) $(EXISTINGLIBS)

OFILES=$(CPPOFILES) $(COFILES)

####################
# Dependencies
####################

HEADERS=$(shell $(FIND) $(SRCDIR) -wholename \*.h -or -wholename \*.hpp)
TAGS=$(HEADERS:=.t)

DEPENDENCIES=$(addprefix $(TARGETDIR),$(CPPFILES:.cpp=.cpp.d) $(CFILES:.c=.c.d))

####################
# Scheme
####################

STUBS=$(shell $(FIND) $(SRCDIR) -wholename \*.stub)
STUBFILE=$(TARGETDIR)$(UNITNAME).stub

ifneq ($(STUBS),)
COMPILED_STUB=$(addprefix $(TARGETDIR),$(UNITNAME).stub.o)
EXTRA_LIBS+=-lchibi-scheme
OFILES+=$(COMPILED_STUB)
else
COMPILED_STUB=
endif

####################
# Rules
####################

all: $(TAGS) $(LIBFILE) $(REALBINFILE) deploy done

-include $(DEPENDENCIES)

prepare:

done:

deploy: $(LIBFILE) $(REALBINFILE)
	@if [ -f "$(REALBINFILE)" ]; then                           \
		$(COPY) $(REALBINFILE) $(BINDIR);                   \
	fi
	@if [ -d "$(DATADIR)" ]; then                               \
		$(MKDIR) -p $(OUTDATADIR);                          \
		$(COPY) -ru $(DATADIR)/* $(OUTDATADIR);             \
	fi

$(REALBINFILE): $(OFILES)
	@if [ ! -z "$(REALBINFILE)" ]; then                                                                                         \
		$(ECHO) "[LNK] $(notdir $(REALBINFILE)): $(notdir $(OFILES) $(EXISTINGLIBS))";                        \
		$(CD) $(TARGETDIR);                                                                                                 \
		$(LINK_BIN) $(EXISTINGLIBS) $(EXTRA_LIBS) $(OFILES) $(EXISTINGLIBS) $(EXTRA_LIBS) -o $(REALBINFILE);  \
		$(CD) $(SRCDIR);                                                                                                    \
	fi

$(LIBFILE): $(OFILES)
	@if [ -d "$(TARGETDIR)" ]; then                                                                        \
		$(ECHO) "[AR]  $(LIBFILE)";                                           \
		$(CD) $(TARGETDIR);                                                                            \
		$(LINK_STATIC) $(LIBFILE) $(OFILES) $1> /dev/null; \
		$(CD) $(SRCDIR);                                                                               \
	fi

$(TARGETDIR)%.cpp.o: %.cpp 
	@$(ECHO) "[CPP] $<";
	@$(MKDIR) `dirname $@`
	@$(CD) $(TARGETDIR)
	@$(BUILD_CPP) -MMD -MF $(patsubst %.o,%.d,$@) -o $@ $(SRCDIR)/$<
	@$(CD) $(SRCDIR)

$(TARGETDIR)%.c.o: %.c
	@$(ECHO) "[CC]  $<";
	@$(MKDIR) `dirname $@`
	@$(CD) $(TARGETDIR)
	@$(BUILD_C) -MMD -MF $(patsubst %.o,%.d,$@) -o $@ $(SRCDIR)/$<
	@$(CD) $(SRCDIR)

%.stub.o: $(STUBS)
	@cat $(STUBS) >> $(STUBFILE)
	@$(ECHO) "[STB] $(STUBFILE)"
	@chibi-ffi $(STUBFILE)
	@$(ECHO) "[CC]  $(STUBFILE:.stub=.c)"
	@$(BUILD_C) -o $@ $(STUBFILE:.stub=.c)

%.h.t: %.h
	@$(ECHO) "[TAG] $<"
	@$(ETAGS) $<

%.hpp.t: %.hpp
	@$(ECHO) "[TAG] $<"
	@$(ETAGS) $<
