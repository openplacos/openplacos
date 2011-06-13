
all:
clean:

install:
	@echo "installing now !!!"
	
	install -d $(DESTDIR)/usr/lib/ruby/openplacos/
	install -d $(DESTDIR)/etc/dbus-1/system.d/
	install -d $(DESTDIR)/etc/init.d/
	
	@cp setup_files/openplacos.conf $(DESTDIR)/etc/dbus-1/system.d/openplacos.conf
	@cp setup_files/openplacos $(DESTDIR)/etc/init.d/openplacos
	
	@cp COPYING $(DESTDIR)/usr/lib/ruby/openplacos/COPYING
	@cp README $(DESTDIR)/usr/lib/ruby/openplacos/README
	@cp Gemfile $(DESTDIR)/usr/lib/ruby/openplacos/Gemfile
	
	@cp -R server $(DESTDIR)/usr/lib/ruby/openplacos
	@cp -R clients $(DESTDIR)/usr/lib/ruby/openplacos
	@cp -R components $(DESTDIR)/usr/lib/ruby/openplacos
	@cp -R plugins $(DESTDIR)/usr/lib/ruby/openplacos
	@cp -R drivers $(DESTDIR)/usr/lib/ruby/openplacos

