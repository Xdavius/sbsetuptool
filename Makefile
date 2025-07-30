PREFIX ?= /usr
ETCDIR ?= /etc
DESTDIR ?=

KEYDIR = $(DESTDIR)$(PREFIX)/share/secureboot-signing
HELPER = $(DESTDIR)$(ETCDIR)/dkms/sign_helper.sh
DKMS_CONF = $(DESTDIR)$(ETCDIR)/dkms/dkms.conf
CERT_PEM = $(KEYDIR)/MOK.pem
CERT_DER = $(KEYDIR)/MOK.der
POSTINST_HOOK = $(DESTDIR)$(ETCDIR)/kernel/postinst.d/zz-sign-kernel
POSTINST_HEADERS_HOOK = $(DESTDIR)$(ETCDIR)/kernel/header_postinst.d/00-ensure_sign_file

all:
	@echo "Rien à compiler. Utilise 'make install' pour installer les fichiers."

install:
	@echo "Installation des fichiers Secure Boot..."

	# Dossier de clé
	if [ ! -d $(KEYDIR) ]; then \
	  install -d $(KEYDIR); \
	fi

	# Créer la clé et le certificat s’ils n’existent pas déjà
	if [ ! -f $(KEYDIR)/MOK.priv ]; then \
	  openssl genrsa -out $(KEYDIR)/MOK.priv 2048; \
	  chmod 400 $(KEYDIR)/MOK.priv; \
	fi

	if [ ! -f $(KEYDIR)/MOK.der ]; then \
	  openssl req -new -x509 -sha256 -key $(KEYDIR)/MOK.priv \
	    -outform DER -out $(KEYDIR)/MOK.der -days 3650 \
	    -subj "/CN=Secure Boot Signing/O=Custom Debian/C=FR"; \
	fi

	if [ ! -f $(KEYDIR)/MOK.pem ]; then \
	  openssl x509 -inform der -in $(KEYDIR)/MOK.der -out $(KEYDIR)/MOK.pem; \
	fi

	# Script de clés DKMS
	if [ ! -d "$(DESTDIR)$(ETCDIR)/dkms/framework.conf.d" ]; then \
	  install -d "$(DESTDIR)$(ETCDIR)/dkms/framework.conf.d"; \
	fi

	echo 'PRIVATE_KEY="/usr/share/secureboot-signing/MOK.priv"' > $(DESTDIR)$(ETCDIR)/dkms/framework.conf.d/dkms_key_path.conf
	echo 'PUBLIC_CERT="/usr/share/secureboot-signing/MOK.der"' >> $(DESTDIR)$(ETCDIR)/dkms/framework.conf.d/dkms_key_path.conf

	# Hook kernel post-install
	install -d $(DESTDIR)/etc/kernel/postinst.d
	install -m 755 zz-sign-kernel $(POSTINST_HOOK)
	install -m 755 zz-sign-modules $(DESTDIR)$(ETCDIR)/kernel/postinst.d/zz-sign-modules

	# Hook headers post-install
	install -d $(DESTDIR)/etc/kernel/header_postinst.d/
	install -m 755 00-ensure_sign_file $(POSTINST_HEADERS_HOOK)
	install -Dm 755 sbsetuptool $(DESTDIR)$(PREFIX)/bin/sbsetuptool
	@echo "[✔] Installation complète"

uninstall:
	# Suppression du script DKMS
	rm -f $(DESTDIR)$(ETCDIR)/dkms/framework.conf.d/dkms_key_path.conf

	# Suppression des clés
	rm -rf $(KEYDIR)

	# Suppression des hook postinst
	rm -f $(POSTINST_HOOK)
	rm -f $(POSTINST_HEADERS_HOOK)
	rm -f $(DESTDIR)$(ETCDIR)/kernel/postinst.d/zz-sign-modules

	# Suppression sbsetuptool
	$(DESTDIR)$(PREFIX)/bin/sbsetuptool

	@echo "[✔] Désinstallation terminée"
