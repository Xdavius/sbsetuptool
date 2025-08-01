PREFIX ?= /usr
ETCDIR ?= /etc
DESTDIR ?=

HELPER = $(DESTDIR)$(ETCDIR)/dkms/sign_helper.sh
DKMS_CONF = $(DESTDIR)$(ETCDIR)/dkms/dkms.conf
KEYDIR="/etc/share/secureboot-signing"
POSTINST_HOOK = $(DESTDIR)$(ETCDIR)/kernel/postinst.d/zz-sign-kernel
POSTINST_HEADERS_HOOK = $(DESTDIR)$(ETCDIR)/kernel/header_postinst.d/00-ensure_sign_file

RED='\033[0;31m'
YELLOW='\033[1;33m'
ORANGE='\033[38;5;208m'
GREEN='\033[0;32m'
RESET='\033[0m'

all:
	@echo -e "${YELLOW}[I] Rien à compiler. Utilise 'make install' pour installer les fichiers.${RESET}"

install:
	@echo -e "${YELLOW}[I] Installation...${RESET}"

	# Hook kernel post-install
	install -d $(DESTDIR)/etc/kernel/postinst.d
	install -m 755 zz-sign-kernel $(POSTINST_HOOK)
	install -m 755 zz-sign-modules $(DESTDIR)$(ETCDIR)/kernel/postinst.d/zz-sign-modules

	# Hook headers post-install
	install -d $(DESTDIR)/etc/kernel/header_postinst.d/
	install -m 755 00-ensure_sign_file $(POSTINST_HEADERS_HOOK)

	# sbsetuptool
	install -Dm 755 sbsetuptool $(DESTDIR)$(PREFIX)/bin/sbsetuptool

	@echo -e "${GREEN}[V] Installation terminée${RESET}"

uninstall:
	@echo -e "${YELLOW}[I] Désnstallation...${RESET}"
	# Suppression du script DKMS
	rm -f $(DESTDIR)$(ETCDIR)/dkms/framework.conf.d/dkms_key_path.conf

	# Suppression des clés
	if [ ! -d $(KEYDIR) ]; then \
	  rm -rf $(KEYDIR); \
	fi

	# Suppression des hook postinst
	rm -f $(POSTINST_HOOK)
	rm -f $(POSTINST_HEADERS_HOOK)
	rm -f $(DESTDIR)$(ETCDIR)/kernel/postinst.d/zz-sign-modules

	# Suppression sbsetuptool
	rm -f $(DESTDIR)$(PREFIX)/bin/sbsetuptool

	@eecho -e "${GREEN} Désinstallation terminée${RESET}"
