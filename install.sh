#

PLATFORM=`uname | cut -d _ -f 1 | tr '[:upper:]' '[:lower:]'`
# for cygwin
PLATFORM=cygwin
# for gitbash, sysgit, msys2, msys
PLATFORM=mingw64


#DESTDIR=C:
DESTDIR=
PREFIX=/usr
BINDIR=${PREFIX}/bin
LIBDIR=${PREFIX}/lib
MANDIR=${PREFIX}/share/man


PLATFORMFILE=src/platform/${PLATFORM}.sh


# install common
install-common () {
	install -v -d "${DESTDIR}${BINDIR}/"
	install -v -d "${DESTDIR}${LIBDIR}/password-store"
	install -v -d "${DESTDIR}${LIBDIR}/password-store/extensions"	
	install -v -d "${DESTDIR}${MANDIR}/man1" 
	install -m 0644 -v man/pass.1 "${DESTDIR}${MANDIR}/man1/pass.1"
	install -m 0644 -v man/tree.1 "${DESTDIR}${MANDIR}/man1/tree.1"
}


# install default pass
install-default () {
	trap 'rm -f src/.pass' EXIT; sed '/PLATFORM_FUNCTION_FILE/d;s:^SYSTEM_EXTENSION_DIR=.*:SYSTEM_EXTENSION_DIR="${LIBDIR}/password-store/extensions":' src/password-store.sh > src/.pass && \
	install -m 0755 -v src/.pass "${DESTDIR}${BINDIR}/pass"
}

# install platform patch
install-platform () {
	install -m 0644 -v "${PLATFORMFILE}" "${DESTDIR}${LIBDIR}/password-store/platform.sh"
	trap 'rm -f src/.pass' EXIT; sed 's:.*PLATFORM_FUNCTION_FILE.*:source "${LIBDIR}/password-store/platform.sh":;s:^SYSTEM_EXTENSION_DIR=.*:SYSTEM_EXTENSION_DIR="${LIBDIR}/password-store/extensions":' src/password-store.sh > src/.pass && \
	install -m 0755 -v src/.pass "${DESTDIR}${BINDIR}/pass"
}

# install binaries
install-binaries () {
	install -m 0755 -v bin/tree.exe "${DESTDIR}${BINDIR}/tree.exe"
}

install-common
install-platform
install-binaries

