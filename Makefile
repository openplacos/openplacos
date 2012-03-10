
all:
clean:

install:
	@echo "installing now !!!"
	
	install -d $(DESTDIR)/usr/lib/ruby/openplacos/
	install -d $(DESTDIR)/etc/init.d/
	install -d $(DESTDIR)/etc/udev/rules.d/
	
	@cp setup_files/openplacos $(DESTDIR)/etc/init.d/openplacos
	@cp setup_files/10-openplacos.rules $(DESTDIR)/etc/udev/rules.d/10-openplacos.rules

	
	@cp COPYING $(DESTDIR)/usr/lib/ruby/openplacos/COPYING
	@cp README $(DESTDIR)/usr/lib/ruby/openplacos/README
	@cp Gemfile $(DESTDIR)/usr/lib/ruby/openplacos/Gemfile
	
	@cp -R server $(DESTDIR)/usr/lib/ruby/openplacos
	@cp -R clients $(DESTDIR)/usr/lib/ruby/openplacos
	@cp -R components $(DESTDIR)/usr/lib/ruby/openplacos
	@cp -R setup_files $(DESTDIR)/usr/lib/ruby/openplacos
