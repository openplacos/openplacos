include Makefile.defs

all:
clean:

install:
	@echo "Start installing OpenplacOS"

	install -d $(DESTDIR)/$(INSTALLDIR)
	install -d $(DESTDIR)/$(DBUSCONFDIR)
	install -d $(DESTDIR)/$(DEFAULTCONFDIR)
	install -d $(DESTDIR)/$(INITDIR)
	install -d $(DESTDIR)/$(UDEVDIR)
	install -d $(DESTDIR)/$(BINDIR)


	@cp setup_files/openplacos $(DESTDIR)/$(INITDIR)/openplacos
	@cp setup_files/10-openplacos.rules $(DESTDIR)/$(UDEVDIR)/10-openplacos.rules

	@cp COPYING $(DESTDIR)/$(INSTALLDIR)/COPYING
	@cp README $(DESTDIR)/$(INSTALLDIR)/README
	@cp Gemfile $(DESTDIR)/$(INSTALLDIR)/Gemfile
	@cp Gemfile.lock $(DESTDIR)/$(INSTALLDIR)/Gemfile.lock

	@cp -R server $(DESTDIR)/$(INSTALLDIR)
	@cp -R clients $(DESTDIR)/$(INSTALLDIR)
	@cp -R components $(DESTDIR)/$(INSTALLDIR)
	@cp -R config $(DESTDIR)/$(INSTALLDIR)
	@cp -R setup_files $(DESTDIR)/$(INSTALLDIR)
	@cp -R utils $(DESTDIR)/$(INSTALLDIR)
	@cp    config/default.yaml $(DESTDIR)/$(DEFAULTCONFDIR)/openplacos
	@cp    setup_files/openplacos-server $(DESTDIR)/$(BINDIR)/openplacos-server

	@ln -s -f $(DESTDIR)/$(INSTALLDIR)/clients/CLI_client/opos-client.rb $(DESTDIR)/$(BINDIR)/openplacos
