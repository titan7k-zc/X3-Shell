CC ?= gcc
CFLAGS ?= -O2 -Wall -Wextra
LDFLAGS ?=
LDLIBS ?= -lm

PREFIX ?= /usr
BINDIR ?= $(PREFIX)/bin
UNITDIR ?= $(PREFIX)/lib/systemd/system

TARGET = x2-bright

.PHONY: all install uninstall clean

all: $(TARGET)

$(TARGET): x2-bright.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< $(LDLIBS)

install: $(TARGET)
	install -Dm755 $(TARGET) $(DESTDIR)$(BINDIR)/$(TARGET)
	install -Dm644 x2-bright.service \
		$(DESTDIR)$(UNITDIR)/x2-bright.service

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/$(TARGET)
	rm -f $(DESTDIR)$(UNITDIR)/x2-bright.service

clean:
	rm -f $(TARGET)