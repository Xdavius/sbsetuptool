# Variables d’installation
PREFIX ?= /usr
ETCDIR ?= /etc
DESTDIR ?=

# Langue (fr ou en)
LANG ?= fr

# Couleurs ANSI
RED     := \033[0;31m
GREEN   := \033[0;32m
YELLOW  := \033[1;33m
ORANGE  := \033[38;5;208m
CYAN    := \033[0;36m
RESET   := \033[0m

# Fonction de traduction :
# $(call msg, message_fr, message_en)
define msg
$(if $(filter $(LANG),fr),$(1),$(2))
endef

# Fonction log avec traduction
define log_success
	@if [ "$(LANG)" = "fr" ]; then \
		printf "$(GREEN)[✓]  $1$(RESET)\n"; \
	else \
		printf "$(GREEN)[✓]  $2$(RESET)\n"; \
	fi
endef

define log_error
	@if [ "$(LANG)" = "fr" ]; then \
		printf "$(RED)[✗]  $1$(RESET)\n"; \
	else \
		printf "$(RED)[✗]  $2$(RESET)\n"; \
	fi; false
endef

define log_warn
	@if [ "$(LANG)" = "fr" ]; then \
		printf "$(ORANGE)[!]  $1$(RESET)\n"; \
	else \
		printf "$(ORANGE)[!]  $2$(RESET)\n"; \
	fi
endef

define log_info
	@if [ "$(LANG)" = "fr" ]; then \
		printf "$(YELLOW)[ⓘ]  $1$(RESET)\n"; \
	else \
		printf "$(YELLOW)[ⓘ]  $2$(RESET)\n"; \
	fi
endef

# Chemins des fichiers
HELPER := $(DESTDIR)$(ETCDIR)/dkms/sign_helper.sh
DKMS_CONF := $(DESTDIR)$(ETCDIR)/dkms/dkms.conf
KEYDIR := "/etc/share/secureboot-signing"
POSTINST_HOOK := $(DESTDIR)$(ETCDIR)/kernel/postinst.d/zz-sign-kernel
POSTINST_HEADERS_HOOK := $(DESTDIR)$(ETCDIR)/kernel/header_postinst.d/00-ensure_sign_file

# Liste des fichiers nécessaires
REQUIRED_FILES := zz-sign-kernel zz-sign-modules 00-ensure_sign_file sbsetuptool

.PHONY: all check logo install uninstall

default: all

logo:
	@printf "$(CYAN)"
	@printf "███████╗██████╗ ███████╗███████╗████████╗██╗   ██╗██████╗ ████████╗ ██████╗  ██████╗ ██╗       \n"
	@printf "██╔════╝██╔══██╗██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗╚══██╔══╝██╔═══██╗██╔═══██╗██║       \n"
	@printf "███████╗██████╔╝███████╗█████╗     ██║   ██║   ██║██████╔╝   ██║   ██║   ██║██║   ██║██║       \n"
	@printf "╚════██║██╔══██╗╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝    ██║   ██║   ██║██║   ██║██║       \n"
	@printf "███████║██████╔╝███████║███████╗   ██║   ╚██████╔╝██║        ██║   ╚██████╔╝╚██████╔╝███████╗  \n"
	@printf "╚══════╝╚═════╝ ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝        ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝  \n"
	@printf "$(RESET)\n"

check:
	@for file in $(REQUIRED_FILES); do \
		if [ ! -f "$$file" ]; then \
			$(call log_error,"Fichier manquant : $$file","Missing file: $$file"); \
		fi; \
	done
	$(call log_success,\
		"Tous les fichiers requis sont présents.",\
		"All required files are present.")
	@printf "$(RESET)\n"

install: check logo
	$(call log_info,\
		"Installation...",\
		"Installing...")

	# Hook kernel post-install
	install -d $(DESTDIR)/etc/kernel/postinst.d
	install -m 755 zz-sign-kernel $(POSTINST_HOOK)
	install -m 755 zz-sign-modules $(DESTDIR)$(ETCDIR)/kernel/postinst.d/zz-sign-modules

	# Hook headers post-install
	install -d $(DESTDIR)/etc/kernel/header_postinst.d/
	install -m 755 00-ensure_sign_file $(POSTINST_HEADERS_HOOK)

	# sbsetuptool
	install -Dm 755 sbsetuptool $(DESTDIR)$(PREFIX)/bin/sbsetuptool

	$(call log_success,\
		"Installation terminée.",\
		"Installation complete.")
	@printf "$(RESET)\n"

uninstall: logo
	$(call log_info,\
		"Désinstallation...",\
		"Uninstalling...")

	# Suppression du script DKMS
	rm -f $(DESTDIR)$(ETCDIR)/dkms/framework.conf.d/dkms_key_path.conf

	# Suppression des hook postinst
	rm -f $(POSTINST_HOOK)
	rm -f $(POSTINST_HEADERS_HOOK)
	rm -f $(DESTDIR)$(ETCDIR)/kernel/postinst.d/zz-sign-modules

	# Suppression sbsetuptool
	rm -f $(DESTDIR)$(PREFIX)/bin/sbsetuptool

	$(call log_success,\
		"Désinstallation terminée.",\
		"Uninstall complete.")
	@printf "$(RESET)\n"

all: logo
	$(call log_warn,\
		"Rien à compiler. Utilise 'make install' pour installer les fichiers.",\
		"Nothing to compile. Use 'make install' to install the files.")
	@printf "$(RESET)\n"
