# paths
PREFIX      = /usr/local
BINDIR      = ${PREFIX}/bin
MANDIR      = ${PREFIX}/man
MAN1DIR     = ${MANDIR}/man1

BIN = shite
SRC = shite.sh
MANPAGE = ${BIN}.1

all: $(BIN)

$(BIN):
	cp $(SRC) $(BIN)

install: clean all
	mkdir -p $(BINDIR) 
	cp -f $(BIN) $(BINDIR)
	chmod 755 $(BINDIR)/$(BIN)
	mkdir -p $(MAN1DIR)
	cp -f $(MANPAGE) $(MAN1DIR) 
	chmod 644 $(MAN1DIR)/$(MANPAGE)

uninstall:
	@rm -f ${MAN1DIR}/${MANPAGE}
	@rm -f ${BINDIR}/${BIN}
	@echo "uninstalled ${BIN}"

clean:
	rm -rf $(BIN)
