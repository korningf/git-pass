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

SYSTEM_EXTENSION_DIR=${LIBDIR}/password-store/extensions

BASHCOMPDIR=${PREFIX}/share/bash-completion/completions
ZSHCOMPDIR=${PREFIX}/share/zsh/site-functions
FISHCOMPDIR=${PREFIX}/share/fish/vendor_completions.d



PLATFORMFILE=src/platform/${PLATFORM}.sh


# install common dirs
install-common () {
	install -v -d "${DESTDIR}${BINDIR}/"
	install -v -d "${DESTDIR}${LIBDIR}/password-store"
	install -v -d "${DESTDIR}${LIBDIR}/password-store/extensions"
	install -v -d "${DESTDIR}${MANDIR}/man1"
	install -v -d "${DESTDIR}${BASHCOMPDIR}"
	install -v -d "${DESTDIR}${FISHCOMPDIR}"
	install -v -d "${DESTDIR}${ZSHCOMPDIR}"
}

# install default pass (skip this)
install-default () {
	trap 'rm -f src/.pass' EXIT; sed '/PLATFORM_FUNCTION_FILE/d;s:^SYSTEM_EXTENSION_DIR=.*:SYSTEM_EXTENSION_DIR="${LIBDIR}/password-store/extensions":' src/password-store.sh > src/.pass && \
	install -m 0755 -v src/.pass "${DESTDIR}${BINDIR}/pass"
	install -m 0644 -v man/pass.1 "${DESTDIR}${MANDIR}/man1/pass.1"
}

# install platform patch (call this)
install-platform () {
	install -m 0644 -v "${PLATFORMFILE}" "${DESTDIR}${LIBDIR}/password-store/platform.sh"
	trap 'rm -f src/.pass' EXIT; sed 's:.*PLATFORM_FUNCTION_FILE.*:source "${LIBDIR}/password-store/platform.sh":;s:^SYSTEM_EXTENSION_DIR=.*:SYSTEM_EXTENSION_DIR="${LIBDIR}/password-store/extensions":' src/password-store.sh > src/.pass && \
	install -m 0755 -v src/.pass "${DESTDIR}${BINDIR}/pass"
	install -m 0644 -v man/pass.1 "${DESTDIR}${MANDIR}/man1/pass.1"	
}

# install shell completions
install-completions () {
	install -m 0644 -v src/completion/pass.bash-completion "${DESTDIR}${BASHCOMPDIR}/pass"
	install -m 0644 -v src/completion/pass.zsh-completion "${DESTDIR}${ZSHCOMPDIR}/_pass"
	install -m 0644 -v src/completion/pass.fish-completion "${DESTDIR}${FISHCOMPDIR}/pass.fish"
}

# install extensions
install-extensions () {	
	install -m 0755 -v src/extensions/file/file.bash "${DESTDIR}${LIBDIR}/password-store/extensions/file.bash"
	install -m 0644 -v src/extensions/file/pass-file.1 "${DESTDIR}${MANDIR}/man1/pass-file.1"
	install -m 0644 -v src/extensions/file/file.bash.completion "${DESTDIR}${BASHCOMPDIR}/pass-file"
}

# install binaries
install-binaries () {
	install -m 0755 -v bin/tree.exe "${DESTDIR}${BINDIR}/tree.exe"
	install -m 0644 -v man/tree.1 "${DESTDIR}${MANDIR}/man1/tree.1"
}

install-common
#install-default
install-platform
install-completions
install-extensions
install-binaries

