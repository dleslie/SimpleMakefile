SimpleMakefile
==============

A Makefile for Simplified C/C++/Scheme Development

Requirements
============

* GNU Make
* GCC/G++ or Clang
* etags (or edit Makefile.Setup.mk to point it at something else)
* (optionally) chibi-scheme

And some form of:

* sh
* find
* cat
* rm
* cp
* echo
* ln

Files
=====

* Makefile - the high-level configuration makefile that defines project libraries, includes, what compilers to use, et al

* Makefile.Setup.mk - the dispatcher Makefile, which sits in the root and forks off work to sub directories; also contains lower-level configuration variables.

* Makefile.Recursive.mk - for each subdirectory which you'd like to define further details for, create a Makefile that has the following:

```Makefile
# Defines the order in which to recursively build the subdirectories
SUBDIRS=system main asteroids units

# Includes Makefile.Recursive.mk
include ../Makefile.Recursive.mk

```

* Makefile.Build.mk - for each subdirectory which contains source files to build, and which may contain a full sub-tree of sources, create a Makefile that has the following:

```Makefile
# Omit this line if you want to build a static library and not a binary
BINFILE=$(UNITNAME)

# Includes Makefile.Build.mk
include ../../Makefile.Build.mk
```

Default Directories
===================

At the moment the following files and directories will be made during build:

* TAGS - Generated with etags against the found header files
* dist/ - Where built binaries will land
* build/debug/ - Where intermediate object files for debug builds will land, including dependency files
* build/release/ - Where intemediate object files for release builds will land, including dependency files

Dependency Checking
===================

This Makefile is configured to automatically build dependencies if such files do not exist, and if they do exist it will utilise them to build only those files which are necessary as well as refreshing the dependency files. 

Release builds will always perform a full clean and rebuild.

Chibi Scheme
============

The Makefile supports chibi-scheme FFI extensions. If any .stub files are found in the source structure then they will be catenated together and built as a single object file and linked into the binary or library.

If you don't use chibi-scheme then don't fret, you can either delete the relevant sections in Makefile.Build.mk or pretend that they don't exist.

Example Tree
============

The root directory would contain the following:

```
Makefile.Build.mk
Makefile.Setup.mk
Makefile.Recursive.mk
Makefile
```

The src directory recursively builds its subdirectories with specific rules, so its Makefile includes Makefile.Recursive.mk:

```Makefile
# src/Makefile
SUBDIRS=system main
include ../Makefile.Recursive.mk
```

The system directory is a static library, so its Makefile includes Makefile.Build.mk:

```Makefile
# src/system/Makefile
include ../../Makefile.Build.mk
```

Finally, the main directory is a binary which includes the system library, and so its Makefile includes Makefile.Build.mk:

```Makefile
# src/main/Makefile
BINFILE=$(UNITNAME)
include ../../Makefile.Build.mk
```

Every binary and library folder can contain any number of subfolders with source files. The Makefile uses find to locate all source files in the sub-tree.