
all:
clean:

install:
	@echo "installing now !!!"
	
	install -d $(DESTDIR)/usr/lib/ruby/openplacos/
	install -d $(DESTDIR)/etc/dbus-1/system.d/
	install -d $(DESTDIR)/etc/init.d/
	
	install setup_files/openplacos.conf $(DESTDIR)/etc/dbus-1/system.d/openplacos.conf
	install setup_files/openplacos $(DESTDIR)/etc/init.d/openplacos
	
	install COPYING $(DESTDIR)/usr/lib/ruby/openplacos/COPYING
	install README $(DESTDIR)/usr/lib/ruby/openplacos/README

	
	@cp -R server $(DESTDIR)/usr/lib/ruby/openplacos
	@cp -R client $(DESTDIR)/usr/lib/ruby/openplacos
	@cp -R components $(DESTDIR)/usr/lib/ruby/openplacos
	@cp -R drivers $(DESTDIR)/usr/lib/ruby/openplacos

