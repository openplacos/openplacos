
all:
clean:

install:
	@echo "installing now !!!"
	
	install -d $(DESTDIR)/usr/lib/ruby/openplacos/
	install -d $(DESTDIR)/etc/default/
	install -d $(DESTDIR)/etc/dbus-1/system.d/
	install -d $(DESTDIR)/etc/init.d/
	
	install openplacos/setup_files/openplacos.conf $(DESTDIR)/etc/dbus-1/system.d/openplacos.conf
	install openplacos/setup_files/openplacos $(DESTDIR)/etc/init.d/openplacos
	
	@cp -R openplacos $(DESTDIR)/usr/lib/ruby/

