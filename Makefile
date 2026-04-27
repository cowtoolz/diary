.POSIX:

PREFIX = /usr/local

install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	mkdir -p $(DESTDIR)$(PREFIX)/share/man/man1
	cp diary.sh $(DESTDIR)$(PREFIX)/bin/diary
	chmod 755 $(DESTDIR)$(PREFIX)/bin/diary
	cp diary.1 $(DESTDIR)$(PREFIX)/share/man/man1/diary.1
	chmod 644 $(DESTDIR)$(PREFIX)/share/man/man1/diary.1

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/diary
	rm -f $(DESTDIR)$(PREFIX)/share/man/man1/diary.1
