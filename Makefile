
all:
clean:

install:
	@echo "installing now !!!"
	install -d $(DESTDIR)/usr/lib/ruby/openplacos/
	@cp -R usr/lib/ruby/openplacos $(DESTDIR)/usr/lib/ruby/

