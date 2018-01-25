ifdef SOURCE

MYINCLUDE = ./include/

ECSRCDIR = $(HOME)/src/ecelerity/Core

ECPERL = /opt/msys/3rdParty/bin/perl \
  -I$(ECSRCDIR)/perl/lib

ECXS = $(ECSRCDIR)/modules/ecxs

ECXS_CFLAGS += -I$(ECSRCDIR)
ECXS_LFLAGS += -L$(ECSRCDIR)

RUNTESTS = \
  LD_LIBRARY_PATH=$(ECSRCDIR) \
  $(ECPERL) $(ECSRCDIR)/tests/runtests.pl \
  -e $(ECSRCDIR)/ecelerity -m $(ECSRCDIR)/modules

else

ECXS = /opt/msys/ecelerity/bin/ecxs

ECPERL = /opt/msys/3rdParty/bin/perl

RUNTESTS = /opt/msys/ecelerity/bin/ec_runtests.pl

endif

TARGETS = hello_world.so

default:	$(TARGETS)

hello_world.so:	hello_world.c
	$(ECPERL) $(ECXS) $(ECXS_CFLAGS)  -I./include/ $(ECXS_LFLAGS) -c -o $@ $^

install:
	cp *.so /opt/msys/ecelerity/libexec/validate/
	cp *.ecm /opt/msys/ecelerity/libexec/validate/
	ls /opt/msys/ecelerity/libexec/validate/

uninstall:
	rm /opt/msys/ecelerity/libexec/validate/hello_world.so
	rm /opt/msys/ecelerity/libexec/validate/hello_world.ecm
	ls /opt/msys/ecelerity/libexec/validate/

run:
	/opt/msys/ecelerity/sbin/ecelerity -d

.PHONY:	clean
clean:
	rm -f *.o
	rm -f *.so
	rm -f *.ecm

