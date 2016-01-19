# paths
PREFIX      = /usr/local
BINDIR      = ${PREFIX}/bin
MANDIR      = ${PREFIX}/man
MAN1DIR     = ${MANDIR}/man1

BIN = shite
MANPAGE = ${BIN}.1

all:
	@echo test 
	@exit

install:
	@mkdir -p ${BINDIR}
	@mkdir -p ${MAN1DIR}

	@install -d ${BINDIR} ${MAN1DIR}
	@install -m 775 ${BIN} ${BINDIR}
	@install -m 444 ${MANPAGE} ${MAN1DIR}
	@echo "installed ${BIN}"

uninstall:
	@rm -f ${MAN1DIR}/${MANPAGE}
	@rm -rf ${DOCDIR}
	@rm -f ${BINDIR}/${BIN}
	@echo "uninstalled ${BIN}"
