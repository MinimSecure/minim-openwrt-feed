# this is hackers makefile for local compilation and testing,
# it can be removed when no longer required
#

MINIM_COMMON := ../../common
CFLAGS += -Wall -ggdb -DTEST -I$(MINIM_COMMON)
VPATH += $(MINIM_COMMON)
LDLIBS += -lcrypt
CC := gcc

all: web_rpc

web_rpc : web_rpc.o minim_common.o

clean:
	rm -f *.o
