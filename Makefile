include Makefile.defs

all:
clean:

install:
	@echo "Start installing OpenplacOS"

	install -d $(DESTDIR)/$(INSTALLDIR)
	install -d $(DESTDIR)/$(DBUSCONFDIR)
	install -d $(DESTDIR)/$(INITDIR)/
	install -d $(DESTDIR)/$(UDEVDIR)/

	@cp setup_files/openplacos.conf $(DESTDIR)/$(DBUSCONFDIR)/openplacos.conf
	@cp setup_files/openplacos $(DESTDIR)/$(INITDIR)/openplacos
	ifeq ($(OS),Linux)
	  @cp setup_files/10-openplacos.rules $(DESTDIR)/$(UDEVDIR)/10-openplacos.rules
	endif

	@cp COPYING $(DESTDIR)/$(INSTALLDIR)/COPYING
	@cp README $(DESTDIR)/$(INSTALLDIR)/README
	@cp Gemfile $(DESTDIR)/$(INSTALLDIR)/Gemfile

	@cp -R server $(DESTDIR)/$(INSTALLDIR)
	@cp -R clients $(DESTDIR)/$(INSTALLDIR)
	@cp -R components $(DESTDIR)/$(INSTALLDIR)
	@cp -R plugins $(DESTDIR)/$(INSTALLDIR)
	@cp -R drivers $(DESTDIR)/$(INSTALLDIR)
	@cp -R setup_files $(DESTDIR)/$(INSTALLDIR)
