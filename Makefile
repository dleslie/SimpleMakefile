# -*- makefile -*-

# This tells the Makefile where to find the source files
SUBDIRS=src

# VC_VERSION will be set as a preprocessor define
export VC_VERSION=$(shell git rev-parse HEAD)

# The following is how I configure a hobby project I'm working on

# ALLEGRO_LIBS=$(shell pkg-config --cflags --libs allegro-5 allegro_main-5 allegro_acodec-5 allegro_audio-5 allegro_color-5 allegro_font-5 allegro_image-5 allegro_memfile-5 allegro_physfs-5 allegro_primitives-5 allegro_ttf-5)
# PHYSICS_FS_LIBS=-lphysfs
# BOX2D_LIBS=-lBox2D

# And here's how you would inject it into the Make process

# export EXTRA_LIBS=-lstdc++ -lm $(ALLEGRO_LIBS) $(PHYSICS_FS_LIBS) $(BOX2D_LIBS)
# export EXTRA_CC=-DALLEGRO -Wno-write-strings
# export EXTRA_CPP=-DALLEGRO -Wno-write-strings

# This is how you get G++ and GCC to use the latest standards
# export CPP=g++ -std=c++11
# export CC=gcc -std=c11

# This is a bunch of magic to make Clang play nice with GNU std libs
export CPP=clang -std=c++11 -pthread -D__GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 -D__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 -D__GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 -D__GCC_HAVE_SYNC_COMPARE_AND_SWAP_8
export CC=clang -std=c++11 -pthread -D__GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 -D__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 -D__GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 -D__GCC_HAVE_SYNC_COMPARE_AND_SWAP_8

include Makefile.Setup.mk
